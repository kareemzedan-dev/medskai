import 'package:flutter/material.dart';

enum ViewMode { grid, list }

class ViewModeToggle extends StatelessWidget {
  final ViewMode mode;
  final ValueChanged<ViewMode> onChanged;

  const ViewModeToggle({Key? key, required this.mode, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.grid_view, color: mode == ViewMode.grid ? Theme.of(context).primaryColor : Colors.grey),
          onPressed: () => onChanged(ViewMode.grid),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
        ),
        IconButton(
          icon: Icon(Icons.view_list, color: mode == ViewMode.list ? Theme.of(context).primaryColor : Colors.grey),
          onPressed: () => onChanged(ViewMode.list),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
