import 'package:equatable/equatable.dart';

class RegistrarGastoState extends Equatable {
  final bool guardando;
  final bool exito;
  final String? error;
  final String? imagePath; // Ruta de la imagen seleccionada
  final String? imageUrl; // URL de la imagen subida a Firebase
  final bool subiendoImagen; // Estado de carga de imagen

  const RegistrarGastoState({
    this.guardando = false,
    this.exito = false,
    this.error,
    this.imagePath,
    this.imageUrl,
    this.subiendoImagen = false,
  });

  RegistrarGastoState copyWith({
    bool? guardando,
    bool? exito,
    String? error,
    String? imagePath,
    String? imageUrl,
    bool? subiendoImagen,
  }) {
    return RegistrarGastoState(
      guardando: guardando ?? this.guardando,
      exito: exito ?? this.exito,
      error: error,
      imagePath: imagePath,
      imageUrl: imageUrl,
      subiendoImagen: subiendoImagen ?? this.subiendoImagen,
    );
  }

  @override
  List<Object?> get props => [
    guardando,
    exito,
    error,
    imagePath,
    imageUrl,
    subiendoImagen,
  ];
}
