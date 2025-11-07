import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CategoryType { gastos, ingresos }

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final CategoryType type;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
  });
}

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesEvent extends CategoriesEvent {}

class AddCategoryEvent extends CategoriesEvent {
  final String name;
  final IconData icon;
  final Color color;
  final CategoryType type;

  const AddCategoryEvent({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  @override
  List<Object?> get props => [name, icon, color, type];
}

class RemoveCategoryEvent extends CategoriesEvent {
  final String categoryId;

  const RemoveCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class ClearErrorEvent extends CategoriesEvent {}

class ClearCategoriesEvent extends CategoriesEvent {}
