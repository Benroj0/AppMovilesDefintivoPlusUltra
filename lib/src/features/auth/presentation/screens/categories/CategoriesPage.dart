import 'package:flutter/material.dart';
import 'bloc/CategoriesEvent.dart';
import 'CategoriesContent.dart';

class CategoriesPage extends StatelessWidget {
  final CategoryType categoryType;

  const CategoriesPage({Key? key, required this.categoryType})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CategoriesContent(categoryType: categoryType);
  }
}
