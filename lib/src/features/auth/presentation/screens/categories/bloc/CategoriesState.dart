import 'package:equatable/equatable.dart';
import 'CategoriesEvent.dart';

 class CategoriesState extends Equatable {
  final List<Category> allCategories;
  final List<Category> customCategories;
  final bool loading;
  final String? error;

  const CategoriesState({
    this.allCategories = const [],
    this.customCategories = const [],
    this.loading = false,
    this.error,
  });

  // Obtener categorías por tipo
  List<Category> getCategoriesByType(CategoryType type) {
    return allCategories.where((category) => category.type == type).toList();
  }

  // Obtener categorías personalizadas por tipo
  List<Category> getCustomCategoriesByType(CategoryType type) {
    return customCategories.where((category) => category.type == type).toList();
  }

  CategoriesState copyWith({
    List<Category>? allCategories,
    List<Category>? customCategories,
    bool? loading,
    String? error,
  }) {
    return CategoriesState(
      allCategories: allCategories ?? this.allCategories,
      customCategories: customCategories ?? this.customCategories,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [allCategories, customCategories, loading, error];
}
