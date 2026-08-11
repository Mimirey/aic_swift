import 'package:flutter/material.dart';

enum TaskSheetStage { collapsed, peek, full }

class MapTaskPage extends StatefulWidget {
  const MapTaskPage({super.key});

  @override
  State<MapTaskPage> createState() => _MapTaskPageState();
}

class _MapTaskPageState extends State<MapTaskPage> {
  final _sheetController = DraggableScrollableController();
  TaskSheetStage _stage = TaskSheetStage.collapsed;

  static const _collapsedSize = 0.16;
  static const _peekSize = 0.5;
  static const _fullSize = 1.0;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    final size = _sheetController.size;
    final newStage = size >= 0.85
        ? TaskSheetStage.full
        : size >= 0.35
            ? TaskSheetStage.peek
            : TaskSheetStage.collapsed;
    if (newStage != _stage) setState(() => _stage = newStage);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}