import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Selecciona una imagen desde la galería o cámara
  Future<XFile?> pickImage({required ImageSource source}) async {
    try {
      // Solicitar permisos según la fuente
      bool permissionGranted = false;

      if (source == ImageSource.camera) {
        final cameraPermission = await Permission.camera.request();
        permissionGranted = cameraPermission.isGranted;
      } else {
        final photosPermission = await Permission.photos.request();
        permissionGranted = photosPermission.isGranted;
      }

      if (!permissionGranted) {
        throw Exception(
          'Permiso denegado para acceder a ${source == ImageSource.camera ? 'la cámara' : 'la galería'}',
        );
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      return image;
    } catch (e) {
      throw Exception('Error al seleccionar imagen: $e');
    }
  }

  /// Sube una imagen a Firebase Storage y retorna la URL de descarga
  Future<String> uploadImage({
    required File imageFile,
    required String folder,
  }) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Generar nombre único para el archivo
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final String filePath = '$folder/${user.uid}/$fileName';

      // Crear referencia al archivo en Storage
      final Reference ref = _storage.ref().child(filePath);

      // Subir el archivo
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Esperar a que termine la subida
      final TaskSnapshot snapshot = await uploadTask;

      // Obtener la URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Elimina una imagen de Firebase Storage usando su URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }

  /// Muestra modal para seleccionar fuente de imagen
  Future<XFile?> showImageSourceModal() async {
    // Esta función será llamada desde la UI para mostrar el modal de selección
    // La implementación del modal estará en el widget correspondiente
    return null;
  }
}
