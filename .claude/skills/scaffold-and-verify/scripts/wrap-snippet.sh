#!/usr/bin/env bash
# wrap-snippet.sh — Wraps a raw code snippet into a complete Angular component
# or React component file suitable for tsc verification.
#
# Usage:
#   ./wrap-snippet.sh <framework> <raw-snippet-file> <output-file>
#
# The script detects whether the snippet is:
#   a) A complete component (has @Component or export default) → passed through as-is
#   b) A class body fragment (method/property only) → wrapped in a minimal component
#   c) A template/HTML snippet → wrapped in the template of a component
#
# Output is written to <output-file>, ready for verify-snippet.sh

set -euo pipefail

FRAMEWORK="${1:-}"
RAW_FILE="${2:-}"
OUTPUT_FILE="${3:-}"

if [[ -z "$FRAMEWORK" || -z "$RAW_FILE" || -z "$OUTPUT_FILE" ]]; then
  echo "Usage: $0 <framework> <raw-snippet-file> <output-file>"
  exit 1
fi

if [[ ! -f "$RAW_FILE" ]]; then
  echo "ERROR: Raw snippet file not found: $RAW_FILE"
  exit 1
fi

CONTENT=$(cat "$RAW_FILE")

case "$FRAMEWORK" in
  angular)
    # Detect if it's already a complete component
    if echo "$CONTENT" | grep -q "@Component"; then
      cp "$RAW_FILE" "$OUTPUT_FILE"
      echo "WRAP_TYPE: complete-component"

    # Detect if it's a class body fragment (has ngOnInit, constructor, or common lifecycle)
    elif echo "$CONTENT" | grep -qE "ngOnInit|constructor|@ViewChild|@Input|@Output|this\\."; then
      cat > "$OUTPUT_FILE" << WRAPPER
import { Component, OnInit, ViewChild, Input, Output, EventEmitter } from '@angular/core';
import {
  IgxGridComponent, IgxColumnComponent, IgxComboComponent,
  IgxSelectComponent, IgxInputGroupComponent, IgxDatePickerComponent,
  IgxTreeGridComponent, IgxHierarchicalGridComponent,
  FilteringLogic, FilteringExpressionsTree, IFilteringExpression,
  SortingDirection, ISortingExpression,
  IgxBooleanFilteringOperand, IgxStringFilteringOperand, IgxNumberFilteringOperand,
} from 'igniteui-angular';

@Component({
  selector: 'igx-verify',
  template: \`<igx-grid [data]="data" [autoGenerate]="true"></igx-grid>\`,
})
export class VerifyComponent implements OnInit {
  public data: any[] = [];

${CONTENT}
}
WRAPPER
      echo "WRAP_TYPE: class-body-fragment"

    # Otherwise treat as expression/statement level — wrap in a method
    else
      cat > "$OUTPUT_FILE" << WRAPPER
import { Component, OnInit } from '@angular/core';
import { IgxGridComponent } from 'igniteui-angular';

@Component({
  selector: 'igx-verify',
  template: \`<igx-grid [data]="data" [autoGenerate]="true" #grid></igx-grid>\`,
})
export class VerifyComponent implements OnInit {
  public data: any[] = [];

  @ViewChild('grid', { static: true })
  public grid!: IgxGridComponent;

  public ngOnInit(): void {
${CONTENT}
  }
}
WRAPPER
      echo "WRAP_TYPE: statement-fragment"
    fi
    ;;

  react)
    if echo "$CONTENT" | grep -qE "export default|React\.FC|: React\."; then
      cp "$RAW_FILE" "$OUTPUT_FILE"
      echo "WRAP_TYPE: complete-component"
    else
      cat > "$OUTPUT_FILE" << WRAPPER
import React, { useState, useEffect, useRef } from 'react';
import { IgrGrid, IgrColumn, IgrGridModule } from 'igniteui-react-grids';
IgrGridModule.register();

const VerifyComponent: React.FC = () => {
  const [data, setData] = useState<any[]>([]);

${CONTENT}

  return <IgrGrid data={data} autoGenerate={true}></IgrGrid>;
};

export default VerifyComponent;
WRAPPER
      echo "WRAP_TYPE: fragment"
    fi
    ;;

  *)
    echo "ERROR: Unknown framework '$FRAMEWORK'"
    exit 1
    ;;
esac
