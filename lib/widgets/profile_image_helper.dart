import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider? getProfileImageProvider(String photo) {
  if (photo.isEmpty) return null;
  
  final cleanPhoto = photo.trim();
  
  if (cleanPhoto.startsWith('data:image') || 
      (!cleanPhoto.contains('/') && !cleanPhoto.contains('\\') && cleanPhoto.length > 100)) {
    try {
      final String base64Str = cleanPhoto.contains(',') ? cleanPhoto.split(',')[1] : cleanPhoto;
      return MemoryImage(base64Decode(base64Str));
    } catch (_) {
      return null;
    }
  }
  
  if (cleanPhoto.startsWith('http://') || cleanPhoto.startsWith('https://')) {
    return NetworkImage(cleanPhoto);
  }
  
  try {
    return FileImage(File(cleanPhoto));
  } catch (_) {
    return null;
  }
}
