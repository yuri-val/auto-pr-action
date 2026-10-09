#!/usr/bin/env bash
# OpenRouter (OpenAI-compatible chat completions). Reads PROMPT_FILE,
# DIFF_FILE, MODEL, API_KEY and writes the description to OUT_FILE.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

body_file="${RUNNER_TEMP}/openrouter_request.json"
resp_file="${RUNNER_TEMP}/openrouter_response.json"

# `reasoning.effort` is OpenRouter's unified knob: reasoning models think
# briefly, the rest ignore it. No temperature — several reasoning models
# behind the router reject a custom one.
jq -n \
  --arg model "$MODEL" \
  --rawfile prompt "$PROMPT_FILE" \
  --rawfile diff "$DIFF_FILE" \
  '{
    model: $model,
    messages: [
      { role: "system", content: $prompt },
      { role: "user", content: $diff }
    ],
    reasoning: { effort: "low" },
    max_tokens: 4096
  }' > "$body_file"

post_json "OpenRouter" https://openrouter.ai/api/v1/chat/completions "$body_file" "$resp_file" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "HTTP-Referer: https://github.com/yuri-val/auto-pr-action" \
  -H "X-Title: auto-pr-action"

jq -r '.choices[0].message.content // empty' "$resp_file" > "$OUT_FILE"
require_text "OpenRouter" "$OUT_FILE" "finish_reason: $(jq -r '.choices[0].finish_reason // "unknown"' "$resp_file")"
jq -r '"usage: \(.usage.prompt_tokens // 0) input / \(.usage.completion_tokens // 0) output tokens"' "$resp_file"
