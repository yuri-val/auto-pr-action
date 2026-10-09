#!/usr/bin/env bash
# Shared by the provider scripts: one JSON POST with a hard timeout and retries.
#
#   post_json <label> <url> <body_file> <response_file> [curl header args...]
#
# Exits the script with a readable ::error:: on transport failures and HTTP
# errors, logging the API's own error message (e.g. context_length_exceeded).

post_json() {
  local label="$1" url="$2" body_file="$3" resp_file="$4"
  shift 4

  # --max-time bounds a hung request (otherwise the job waits for the 6h
  # limit); --retry covers 429/5xx and transient network errors.
  local http_code
  http_code=$(curl -sS --max-time 300 --retry 3 --retry-delay 5 --retry-all-errors \
    -o "$resp_file" -w '%{http_code}' -X POST "$url" \
    -H "Content-Type: application/json" "$@" \
    -d @"$body_file") || {
    echo "::error::${label} API request failed (curl transport error)"
    exit 1
  }

  if [ "$http_code" -ge 400 ]; then
    echo "::error::${label} API returned HTTP ${http_code}: $(jq -r '.error.message // .error // .' "$resp_file" 2>/dev/null | head -c 800)"
    exit 1
  fi
}

# Fails with a readable error when the extracted description is empty.
require_text() {
  local label="$1" text_file="$2" detail="$3"
  if [ ! -s "$text_file" ] || [ "$(tr -d '[:space:]' < "$text_file")" = "null" ] || [ -z "$(tr -d '[:space:]' < "$text_file")" ]; then
    echo "::error::${label} returned an empty response${detail:+ ($detail)}"
    exit 1
  fi
}
