import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final Reference ref = _storage.ref().child('users/$userId/profile/$fileName');
      
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting profile image: $e');
    }
  }

  // Upload service image
  Future<String> uploadServiceImage(String barberId, String serviceId, File imageFile) async {
    try {
      final String fileName = 'service_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final Reference ref = _storage.ref().child('barbers/$barberId/services/$serviceId/$fileName');
      
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading service image: $e');
      rethrow;
    }
  }

  // Upload product image
  Future<String> uploadProductImage(String barberId, String productId, File imageFile) async {
    try {
      final String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final Reference ref = _storage.ref().child('barbers/$barberId/products/$productId/$fileName');
      
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading product image: $e');
      rethrow;
    }
  }

  // Upload document
  Future<String> uploadDocument(String userId, String documentType, File file) async {
    try {
      final String fileName = '${documentType}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final Reference ref = _storage.ref().child('users/$userId/documents/$fileName');
      
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'application/pdf'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading document: $e');
      rethrow;
    }
  }

  // Delete file
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }
} 