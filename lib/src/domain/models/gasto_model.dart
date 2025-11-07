import 'package:cloud_firestore/cloud_firestore.dart';

class Gasto {
  final String id;
  final String descripcion;
  final double importe;
  final String idCategoria;
  final DateTime fecha;
  final String? urlArchivo; // Opcional, para la foto

  Gasto({
    required this.id,
    required this.descripcion,
    required this.importe,
    required this.idCategoria,
    required this.fecha,
    this.urlArchivo,
  });

  /// Factory constructor: El "Traductor"
  /// Esto crea una instancia de Gasto desde un documento de Firestore.
  factory Gasto.fromSnapshot(DocumentSnapshot doc) {
    // Obtenemos los datos del documento
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Gasto(
      // Obtenemos el ID del documento en sí
      id: doc.id, 
      
      // Obtenemos los campos, con valores por defecto
      descripcion: data['descripcion'] ?? '',
      importe: (data['importe'] ?? 0.0).toDouble(), // Aseguramos que sea double
      idCategoria: data['id_categoria'] ?? '',
      
      // Convertimos el Timestamp de Firestore a un DateTime de Dart
      fecha: (data['fecha'] as Timestamp? ?? Timestamp.now()).toDate(),
      
      // Obtenemos el campo opcional
      urlArchivo: data['url_archivo'], 
    );
  }
}