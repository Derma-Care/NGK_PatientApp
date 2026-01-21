import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

Widget procedureImageWidget(String? image) {
  // ✅ Case 1: null or empty → default image
  if (image == null || image.isEmpty) {
    return _defaultImage();
  }

  // ✅ Case 2: Base64 image
  if (!image.contains(r':\') && !image.startsWith('http')) {
    try {
      final base64Str = image.contains(',') ? image.split(',').last : image;

      return Image.memory(
        base64Decode(base64Str),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultImage(),
      );
    } catch (_) {
      return _defaultImage();
    }
  }

  // ❌ Case 3: Local file path (fakepath etc.) → default image
  if (image.contains(r':\')) {
    return _defaultImage();
  }

  // ✅ Case 4: Network image
  if (image.startsWith('http')) {
    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _defaultImage(),
    );
  }

  // 🔁 Final fallback
  return _defaultImage();
}

Widget _defaultImage() {
  return Image.asset(
    'assets/ic_launcher.png',
    fit: BoxFit.cover,
  );
}
