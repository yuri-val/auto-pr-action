#!/usr/bin/env bash
# OpenAI chat completions. Reads PROMPT_FILE, DIFF_FILE, MODEL, API_KEY and
# writes the description to OUT_FILE.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

body_file="${RUNNER_TEMP}/openai_request.json"
resp_file="${RUNNER_TEMP}/openai_response.json"

# gpt-5 and later (and the o-series) are reasoning models: they spend
# completion tokens on reasoning before the answer — reasoning_effort "low"
# plus a 4096 budget keeps summaries fast. Older models reject the parameter.
reasoning_re='^(o[1-9]|gpt-([5-9]|[1-9][0-9]))'
if [[ "$MODEL" =~ $reasoning_re ]]; then effort="low"; else effort=""; fi

jq -n \
  --arg model "$MODEL" \
  --arg effort "$effort" \
  --rawfile prompt "$PROMPT_FILE" \
  --rawfile diff "$DIFF_FILE" \
  '{
    model: $model,
    messages: [
      { role: "system", content: $prompt },
      { role: "user", content: $diff }
    ],
    max_completion_tokens: 4096
  } + (if $effort != "" then { reasoning_effort: $effort } else {} end)' > "$body_file"

post_json "OpenAI" https://api.openai.com/v1/chat/completions "$body_file" "$resp_file" \
  -H "Authorization: Bearer ${API_KEY}"

jq -r '.choices[0].message.content // empty' "$resp_file" > "$OUT_FILE"
require_text "OpenAI" "$OUT_FILE" "finish_reason: $(jq -r '.choices[0].finish_reason // "unknown"' "$resp_file")"
jq -r '"usage: \(.usage.prompt_tokens // 0) input / \(.usage.completion_tokens // 0) output tokens"' "$resp_file"
