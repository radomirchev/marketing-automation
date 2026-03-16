#!/usr/bin/env bash
# validate-brief.sh — Check a topic brief JSON/YAML has required fields
#
# Usage:
#   ./validate-brief.sh <brief-file>
#
# The brief file must be JSON with these required fields:
#   topic, framework, angle, keywords (array), depth, word_count, product_type
#
# Exit codes:
#   0 = valid
#   1 = invalid (missing or empty required fields)

set -euo pipefail

BRIEF_FILE="${1:-}"

if [[ -z "$BRIEF_FILE" ]]; then
  echo "ERROR: provide a brief file path" >&2
  echo "Usage: $0 <brief.json>" >&2
  exit 1
fi

if [[ ! -f "$BRIEF_FILE" ]]; then
  echo "ERROR: file not found: $BRIEF_FILE" >&2
  exit 1
fi

python3 -c "
import json, sys

required = {
  'topic': str,
  'framework': str,
  'angle': str,
  'keywords': list,
  'depth': str,
  'word_count': str,
  'product_type': str,
}

valid_frameworks = {'angular', 'react', 'web-components', 'blazor', 'cross-framework'}
valid_angles = {'tutorial', 'deep-dive', 'comparison', 'announcement', 'tips'}
valid_depths = {'beginner', 'intermediate', 'advanced'}
valid_product_types = {'igniteui', 'appbuilder', 'reveal', 'ultimate', 'master'}

with open(sys.argv[1]) as f:
  brief = json.load(f)

errors = []

for field, ftype in required.items():
  val = brief.get(field)
  if val is None:
    errors.append(f'  MISSING: {field}')
  elif ftype == str and not val.strip():
    errors.append(f'  EMPTY: {field}')
  elif ftype == list and len(val) == 0:
    errors.append(f'  EMPTY list: {field}')

fw = brief.get('framework', '')
if fw and fw not in valid_frameworks:
  errors.append(f'  INVALID framework: \"{fw}\" — must be one of: {sorted(valid_frameworks)}')

angle = brief.get('angle', '')
if angle and angle not in valid_angles:
  errors.append(f'  INVALID angle: \"{angle}\" — must be one of: {sorted(valid_angles)}')

depth = brief.get('depth', '')
if depth and depth not in valid_depths:
  errors.append(f'  INVALID depth: \"{depth}\" — must be one of: {sorted(valid_depths)}')

pt = brief.get('product_type', '')
if pt and pt not in valid_product_types:
  errors.append(f'  INVALID product_type: \"{pt}\" — must be one of: {sorted(valid_product_types)}')

if errors:
  print('Brief validation FAILED:')
  for e in errors:
    print(e)
  sys.exit(1)
else:
  print('Brief validation PASSED')
  print(f'  Topic:        {brief[\"topic\"]}')
  print(f'  Framework:    {brief[\"framework\"]}')
  print(f'  Angle:        {brief[\"angle\"]}')
  print(f'  Keywords:     {brief[\"keywords\"]}')
  print(f'  Depth:        {brief[\"depth\"]}')
  print(f'  Word count:   {brief[\"word_count\"]}')
  print(f'  Product type: {brief[\"product_type\"]}')
" "$BRIEF_FILE"
