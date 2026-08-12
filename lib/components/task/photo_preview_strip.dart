import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPreviewStrip extends StatelessWidget {
  final List<XFile> photos;
  final int maxVisible;
  final ValueChanged<int> onTapPhoto;
  const PhotoPreviewStrip({super.key, required this.photos, this.maxVisible = 3, required this.onTapPhoto});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    final visibleCount = photos.length > maxVisible ? maxVisible : photos.length;
    final hiddenCount = photos.length - visibleCount;

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visibleCount,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final thumbnail = GestureDetector(
            onTap: ()=> onTapPhoto(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(File(photos[index].path), width: 60, height: 60, fit: BoxFit.cover),
            ),
          );

          final isLastVisible = index == visibleCount - 1;
          if (isLastVisible && hiddenCount > 0) {
            return Stack(
              children: [
                thumbnail,
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.black.withOpacity(0.45),
                      alignment: Alignment.center,
                      child: Text('+$hiddenCount',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            );
          }
          return thumbnail;
        },
      ),
    );
  }
}