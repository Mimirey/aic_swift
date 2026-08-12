import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoViewerSheet extends StatefulWidget {
  final List<XFile> photos;
  final int initialIndex;
  final ValueChanged<int> onDelete;
  const PhotoViewerSheet({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.onDelete,
  });

  @override
  State<PhotoViewerSheet> createState() => _PhotoViewerSheetState();
}

class _PhotoViewerSheetState extends State<PhotoViewerSheet> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }

  void _handleDelete() {
    widget.onDelete(_currentIndex);
    if (widget.photos.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      if (_currentIndex >= widget.photos.length) {
        _currentIndex = widget.photos.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        actions: [
          IconButton(
            onPressed: _handleDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(child: Image.file(File(widget.photos[index].path))),
          );
        },
      ),
    );
  }
}

Future<void> showPhotoViewer(
  BuildContext context,
  List<XFile> photos,
  int initialIndex, {
  required ValueChanged<int> onDelete,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionsBuilder: (context, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      pageBuilder: (context, __, ___) => PhotoViewerSheet(
        photos: photos,
        initialIndex: initialIndex,
        onDelete: onDelete,
      ),
    ),
  );
}
