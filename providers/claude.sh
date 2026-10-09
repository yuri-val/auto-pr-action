#!/usr/bin/env bash
# Anthropic Messages API. Reads PROMPT_FILE, DIFF_FILE, MODEL, API_KEY (and
# optionally WORKSPACE_ID) and writes the description to OUT_FILE.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

body_file="${RUNNER_TEMP}/claude_request.json"
resp_file="${RUNNER_TEMP}/claude_response.json"

# Current models (Opus 4.5+, the 5.x family) take output_config.effort; older
# ones (Haiku 4.5, Sonnet 4.5, 3.x) reject it. Thinking is on by default on
# current models and counts toward max_tokens, so leave room beyond the
# description. No temperature: current models reject non-default sampling.
effort_re='^claude-(opus-4-[5-9]|(opus|sonnet|haiku|fable|mythos)-([5-9]|[1-9][0-9]))'
if [[ "$MODEL" =~ $effort_re ]]; then effort="low"; else effort=""; fi

jq -n \
  --arg model "$MODEL" \
  --arg effort "$effort" \
  --rawfile prompt "$PROMPT_FILE" \
  --rawfile diff "$DIFF_FILE" \
  '{
    model: $model,
    max_tokens: 8000,
    system: $prompt,
    messages: [ { role: "user", content: $diff } ]
  } + (if $effort != "" then { output_config: { effort: $effort } } else {} end)' > "$body_file"

headers=(-H "x-api-key: ${API_KEY}" -H "anthropic-version: 2023-06-01")
# Keys that are not scoped to a workspace must name one on every request.
if [ -n "${WORKSPACE_ID:-}" ]; then
  headers+=(-H "anthropic-workspace-id: ${WORKSPACE_ID}")
fi

post_json "Claude" https://api.anthropic.com/v1/messages "$body_file" "$resp_file" "${headers[@]}"

stop_reason=$(jq -r '.stop_reason // "unknown"' "$resp_file")
if [ "$stop_reason" = "refusal" ]; then
  echo "::error::Claude declined to write the description ($(jq -r '.stop_details.category // "no category"' "$resp_file"))"
  exit 1
fi

# Read text blocks by type: a response can begin with thinking blocks.
jq -r '[.content[] | select(.type == "text") | .text] | join("")' "$resp_file" > "$OUT_FILE"
require_text "Claude" "$OUT_FILE" "stop_reason: ${stop_reason}"
jq -r '"usage: \(.usage.input_tokens // 0) input / \(.usage.output_tokens // 0) output tokens"' "$resp_file"
