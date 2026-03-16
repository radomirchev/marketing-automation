# Ignite UI import reference

Correct import paths for the most common components. Use these when `verify-snippet.sh` returns "Cannot find module" or "has no exported member" errors.

## Angular — `igniteui-angular`

All components, directives, pipes, and services are exported from the top-level package:

```typescript
import {
  // Grid
  IgxGridModule,
  IgxGridComponent,
  IgxColumnComponent,
  IgxColumnGroupComponent,
  IgxGridRow,
  IgxGridCell,

  // Tree Grid
  IgxTreeGridModule,
  IgxTreeGridComponent,

  // Hierarchical Grid
  IgxHierarchicalGridModule,
  IgxHierarchicalGridComponent,
  IgxRowIslandComponent,

  // Pivot Grid
  IgxPivotGridModule,
  IgxPivotGridComponent,

  // Grid features
  FilteringLogic,
  FilteringExpressionsTree,
  IFilteringExpression,
  IgxBooleanFilteringOperand,
  IgxStringFilteringOperand,
  IgxNumberFilteringOperand,
  IgxDateFilteringOperand,
  SortingDirection,
  ISortingExpression,
  IGroupingExpression,

  // Form controls
  IgxComboModule,
  IgxComboComponent,
  IgxSimpleComboModule,
  IgxSimpleComboComponent,
  IgxSelectModule,
  IgxSelectComponent,
  IgxSelectItemComponent,
  IgxInputGroupModule,
  IgxInputGroupComponent,
  IgxInputDirective,
  IgxLabelDirective,

  // Date/Time
  IgxDatePickerModule,
  IgxDatePickerComponent,
  IgxTimePickerModule,
  IgxTimePickerComponent,
  IgxDateRangePickerModule,
  IgxDateRangePickerComponent,
  IgxCalendarModule,
  IgxCalendarComponent,

  // Navigation
  IgxTabsModule,
  IgxTabsComponent,
  IgxTabItemComponent,
  IgxStepperModule,
  IgxStepperComponent,
  IgxStepComponent,
  IgxAccordionModule,
  IgxAccordionComponent,
  IgxExpansionPanelModule,
  IgxExpansionPanelComponent,

  // Lists and data display
  IgxListModule,
  IgxListComponent,
  IgxListItemComponent,
  IgxCardModule,
  IgxCardComponent,

  // Overlays
  IgxDialogModule,
  IgxDialogComponent,
  IgxSnackbarModule,
  IgxSnackbarComponent,
  IgxTooltipModule,
  IgxTooltipDirective,
  IgxTooltipTargetDirective,

  // Buttons and actions
  IgxButtonModule,
  IgxButtonDirective,
  IgxRippleModule,
  IgxRippleDirective,
  IgxChipsModule,
  IgxChipComponent,
  IgxChipsAreaComponent,

  // Indicators
  IgxBadgeModule,
  IgxBadgeComponent,
  IgxAvatarModule,
  IgxAvatarComponent,
  IgxIconModule,
  IgxIconComponent,
  IgxProgressBarModule,
  IgxLinearProgressBarComponent,
  IgxCircularProgressBarComponent,

  // Form elements
  IgxSliderModule,
  IgxSliderComponent,
  IgxSwitchModule,
  IgxSwitchComponent,
  IgxCheckboxModule,
  IgxCheckboxComponent,
  IgxRadioModule,
  IgxRadioComponent,
  IgxRadioGroupDirective,

  // Layout
  IgxDragDropModule,
  IgxDividerModule,
  IgxDividerDirective,
  IgxBannerModule,
  IgxBannerComponent,

  // Navigation chrome
  IgxNavbarModule,
  IgxNavbarComponent,
  IgxNavigationDrawerModule,
  IgxNavigationDrawerComponent,
  IgxBottomNavModule,
  IgxBottomNavComponent,

  // Services
  IgxOverlayService,
  AbsoluteScrollStrategy,
  AutoPositionStrategy,
  ConnectedPositioningStrategy,
  GlobalPositionStrategy,
} from 'igniteui-angular';
```

## React — split packages

React uses separate sub-packages:

```typescript
// Grids
import { IgrGrid, IgrColumn, IgrGridModule } from 'igniteui-react-grids';
import { IgrTreeGrid, IgrTreeGridModule } from 'igniteui-react-grids';
import { IgrHierarchicalGrid, IgrRowIsland, IgrHierarchicalGridModule } from 'igniteui-react-grids';

// Charts
import { IgrCategoryChart, IgrCategoryChartModule } from 'igniteui-react-charts';
import { IgrDataChart, IgrDataChartModule } from 'igniteui-react-charts';
import { IgrPieChart, IgrPieChartModule } from 'igniteui-react-charts';

// Inputs
import { IgrCombo, IgrComboModule } from 'igniteui-react-inputs';
import { IgrSelect, IgrSelectModule } from 'igniteui-react-inputs';
import { IgrDatePicker, IgrDatePickerModule } from 'igniteui-react-inputs';

// Layouts
import { IgrCard, IgrCardModule } from 'igniteui-react-layouts';
import { IgrTabs, IgrTab, IgrTabsModule } from 'igniteui-react-layouts';

// Must call .register() before using each module
IgrGridModule.register();
IgrCategoryChartModule.register();
// etc.
```

## Common naming patterns

Angular uses `Igx` prefix. React uses `Igr` prefix.

| Concept | Angular | React |
|---|---|---|
| Data grid | `IgxGridComponent` | `IgrGrid` |
| Grid column | `IgxColumnComponent` | `IgrColumn` |
| Combo box | `IgxComboComponent` | `IgrCombo` |
| Date picker | `IgxDatePickerComponent` | `IgrDatePicker` |
| Category chart | `IgxCategoryChartComponent` | `IgrCategoryChart` |
| Icon | `IgxIconComponent` | `IgrIcon` |

## Properties that commonly get the name wrong

| Wrong | Correct (Angular) | Note |
|---|---|---|
| `[rowVirtualize]` | `[rowVirtualization]` | boolean, default false |
| `[columnVirtualize]` | `[columnVirtualization]` | boolean, default false |
| `[primaryKey]` | `[primaryKey]` | string, not `[key]` |
| `[filterMode]` | `[filterMode]` | FilterMode enum, not string |
| `(onRowClick)` | `(rowClick)` | Event emitters dropped `on` prefix in v13+ |
| `(onSelection)` | `(rowSelectionChanging)` | Renamed in v13 |
| `[showToolbar]` | use `<igx-grid-toolbar>` child | Toolbar is now a child component |
