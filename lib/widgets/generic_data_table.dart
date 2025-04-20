import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:ige_hospital/provider/colors_provider.dart';

typedef EntityRenderer<T> = Widget Function(T entity);

class ColumnDefinition<T> {
  final String title;
  final dynamic Function(T entity) valueGetter;
  final int flex;
  final bool isWidget;

  ColumnDefinition({
    required this.title,
    required this.valueGetter,
    this.flex = 1,
    this.isWidget = false,
  });
}

class GenericDataTable<T> extends StatefulWidget {
  final List<T> data;
  final List<ColumnDefinition<T>> columns;
  final ColourNotifier notifier;
  final int visibleColumnCount;
  final int pageSize;
  final int currentPage;
  final Function(int) onPageChanged;
  final Widget Function(int, int, Function(int)) paginationBuilder;
  final EntityRenderer<T>? expansionBuilder;
  final T Function(T)? onEdit;
  final Function(T)? onDelete;
  final Function(T)? onView;
  final bool showActions;
  final bool multipleExpansion;
  final bool forceRebuild;

  const GenericDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.notifier,
    required this.visibleColumnCount,
    required this.pageSize,
    required this.currentPage,
    required this.onPageChanged,
    required this.paginationBuilder,
    this.expansionBuilder,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.showActions = true,
    this.multipleExpansion = true,
    this.forceRebuild = false,
  });

  @override
  State<GenericDataTable<T>> createState() => _GenericDataTableState<T>();
}

class _GenericDataTableState<T> extends State<GenericDataTable<T>> {
  late List<ExpandableColumn<dynamic>> headers;
  late List<ExpandableRow> rows;

  @override
  void initState() {
    super.initState();
    createDataSource();
  }

  @override
  void didUpdateWidget(GenericDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recreate data source if data list changed or force rebuild is true
    if (widget.data != oldWidget.data || widget.forceRebuild) {
      createDataSource();
    }
  }

  void createDataSource() {
    // Create headers from column definitions
    headers = widget.columns.map((column) {
      return ExpandableColumn<dynamic>(
        columnTitle: column.title,
        columnFlex: column.flex,
      );
    }).toList();

    // Add actions column if needed
    if (widget.showActions && (widget.onEdit != null || widget.onDelete != null || widget.onView != null)) {
      headers.add(ExpandableColumn<Widget>(
        columnTitle: "Actions",
        columnFlex: 2,
      ));
    }

    // Create rows from data
    rows = widget.data.map<ExpandableRow>((entity) {
      List<ExpandableCell<dynamic>> cells = widget.columns.map((column) {
        // For widget cells, we need to cast as Widget
        if (column.isWidget) {
          return ExpandableCell<Widget>(
            columnTitle: column.title,
            value: column.valueGetter(entity) as Widget,
          );
        }

        // For regular values
        return ExpandableCell<dynamic>(
          columnTitle: column.title,
          value: column.valueGetter(entity),
        );
      }).toList();

      // Add actions cell if needed
      if (widget.showActions && (widget.onEdit != null || widget.onDelete != null || widget.onView != null)) {
        cells.add(ExpandableCell<Widget>(
          columnTitle: "Actions",
          value: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onView != null)
                IconButton(
                  icon: Icon(Icons.visibility, color: widget.notifier.getIconColor),
                  onPressed: () => widget.onView!(entity),
                  tooltip: "View Details",
                ),
              if (widget.onEdit != null)
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => widget.onEdit!(entity),
                  tooltip: "Edit",
                ),
              if (widget.onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.onDelete!(entity),
                  tooltip: "Delete",
                ),
            ],
          ),
        ));
      }

      return ExpandableRow(cells: cells);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure data source is up-to-date
    if (widget.forceRebuild) {
      createDataSource();
    }

    return ExpandableTheme(
      data: ExpandableThemeData(
        context,
        contentPadding: const EdgeInsets.all(15),
        expandedBorderColor: widget.notifier.getBorderColor,
        paginationSize: 48,
        headerHeight: 76,
        headerColor: widget.notifier.getPrimaryColor,
        headerBorder: BorderSide(
          color: widget.notifier.getBgColor,
          width: 8,
        ),
        evenRowColor: widget.notifier.getContainer,
        oddRowColor: widget.notifier.getBgColor,
        rowBorder: BorderSide(
          color: widget.notifier.getBorderColor,
          width: 0.3,
        ),
        headerTextMaxLines: 4,
        headerSortIconColor: widget.notifier.getMainText,
        headerTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: widget.notifier.getMainText,
        ),
        rowTextStyle: TextStyle(
          color: widget.notifier.getMainText,
        ),
        expansionIcon: Icon(
          Icons.keyboard_arrow_down,
          color: widget.notifier.getIconColor,
        ),
        editIcon: Icon(
          Icons.edit,
          color: widget.notifier.getMainText,
        ),
      ),
      child: ExpandableDataTable(
        headers: headers,
        rows: rows,
        multipleExpansion: widget.multipleExpansion,
        isEditable: false,
        visibleColumnCount: widget.visibleColumnCount,
        pageSize: widget.pageSize,
        onPageChanged: widget.onPageChanged,
        renderExpansionContent: widget.expansionBuilder != null
            ? (row) => _buildExpansionContent(row)
            : null,
        renderCustomPagination: widget.paginationBuilder,
      ),
    );
  }

  Widget _buildExpansionContent(ExpandableRow row) {
    // Find the original entity that corresponds to this row
    int index = rows.indexOf(row);
    if (index == -1 || index >= widget.data.length) {
      return const SizedBox(); // Fallback
    }

    // Get the entity and build the expansion content
    final entity = widget.data[index];
    return widget.expansionBuilder!(entity);
  }
}