#!/usr/bin/env bash
# query-gateway.sh — Query the Infragistics AI Agent Gateway
#
# Usage:
#   ./query-gateway.sh <productType> <input> [sessionId]
#
# productType: igniteui | appbuilder | reveal | ultimate | master
#   Use "master" to route to invokeMasterAgent (cross-product queries).
#   Any other value routes to invokeByProductType.
#
# Examples:
#   ./query-gateway.sh igniteui "How does IgxGridComponent virtual scrolling work?" "session-blog-001"
#   ./query-gateway.sh master "Compare IgniteUI and AppBuilder data binding patterns" "session-blog-001"
#
# Environment:
#   GATEWAY_TOKEN — required. PAT token in format: mcp-<kid>.<secret>
#                   Set in .env or export before running.
#   GATEWAY_BASE_URL — optional. Defaults to https://ai-agent-gateway.infragistics.com

set -euo pipefail

PRODUCT_TYPE="${1:-}"
INPUT="${2:-}"
SESSION_ID="${3:-session-$(date +%s)}"

if [[ -z "$PRODUCT_TYPE" || -z "$INPUT" ]]; then
  echo "ERROR: productType and input are required" >&2
  echo "Usage: $0 <productType> <input> [sessionId]" >&2
  exit 1
fi

if [[ -z "${GATEWAY_TOKEN:-}" ]]; then
  echo "ERROR: GATEWAY_TOKEN environment variable is not set" >&2
  echo "Set it with: export GATEWAY_TOKEN=mcp-<kid>.<secret>" >&2
  exit 1
fi

BASE_URL="${GATEWAY_BASE_URL:-https://ai-agent-gateway.infragistics.com}"

if [[ "$PRODUCT_TYPE" == "master" ]]; then
  ENDPOINT="$BASE_URL/api/agents/invokeMasterAgent"
  PAYLOAD=$(printf '{"input": %s, "sessionId": %s}' \
    "$(echo "$INPUT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read().strip()))')" \
    "$(echo "$SESSION_ID" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read().strip()))')")
else
  ENDPOINT="$BASE_URL/api/agents/invokeByProductType"
  PAYLOAD=$(python3 -c "
import json, sys
print(json.dumps({
  'input': sys.argv[1],
  'productType': sys.argv[2],
  'sessionId': sys.argv[3]
}))" "$INPUT" "$PRODUCT_TYPE" "$SESSION_ID")
fi

RESPONSE=$(curl -sf \
  -X POST "$ENDPOINT" \
  -H "Authorization: Bearer $GATEWAY_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  -w "\n__HTTP_STATUS__%{http_code}")

HTTP_STATUS=$(echo "$RESPONSE" | tail -n1 | sed 's/__HTTP_STATUS__//')
BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_STATUS" == "429" ]]; then
  echo "ERROR: Rate limit exceeded. Wait and retry." >&2
  exit 2
fi

if [[ "$HTTP_STATUS" != "200" ]]; then
  echo "ERROR: Gateway returned HTTP $HTTP_STATUS" >&2
  echo "$BODY" >&2
  exit 1
fi

echo "$BODY" | python3 -c "
import json, sys

data = json.load(sys.stdin)

print('=== GATEWAY RESPONSE ===')
print(f'Title:      {data.get(\"title\", \"(no title)\")}')
print(f'Session:    {data.get(\"sessionId\", \"\")}')
confidence = data.get('confidenceLevel', 0)
flag = ' *** LOW CONFIDENCE — treat with caution ***' if confidence < 60 else ''
print(f'Confidence: {confidence}{flag}')
print()
print('--- Output ---')
print(data.get('output', ''))
print()
citations = data.get('citations', [])
if citations:
  print('--- Citations ---')
  for c in citations:
    print(f'  {c}')
print('=== END RESPONSE ===')
"
