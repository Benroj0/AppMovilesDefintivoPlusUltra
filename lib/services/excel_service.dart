import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExcelService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Exportar datos de gastos e ingresos a Excel según el período seleccionado
  Future<void> exportToExcel({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('🔄 ExcelService: Iniciando exportación para período: $period');

      // 1. Determinar las fechas según el período
      final dates = _calculateDateRange(period, startDate, endDate);
      final DateTime filterStartDate = dates['start']!;
      final DateTime filterEndDate = dates['end']!;

      print(
        '📅 ExcelService: Exportando desde ${filterStartDate.toIso8601String()} hasta ${filterEndDate.toIso8601String()}',
      );

      // 2. Obtener datos de Firebase
      final gastosData = await _getGastosData(filterStartDate, filterEndDate);
      final ingresosData = await _getIngresosData(
        filterStartDate,
        filterEndDate,
      );
      final categoriasData = await _getCategoriasData();

      print(
        '📊 ExcelService: ${gastosData.length} gastos, ${ingresosData.length} ingresos encontrados',
      );

      // 3. Crear el archivo Excel
      final excel = Excel.createExcel();

      // Eliminar la hoja por defecto
      excel.delete('Sheet1');

      // 4. Crear hojas para gastos e ingresos
      _createGastosSheet(excel, gastosData, categoriasData);
      _createIngresosSheet(excel, ingresosData, categoriasData);
      await _createResumenSheet(
        excel,
        gastosData,
        ingresosData,
        categoriasData,
        period,
      );

      // 5. Guardar y compartir el archivo
      await _saveAndShareExcel(excel, period);

      print('✅ ExcelService: Exportación completada exitosamente');
    } catch (e) {
      print('❌ ExcelService: Error en exportación: $e');
      rethrow;
    }
  }

  /// Calcular el rango de fechas según el período seleccionado
  Map<String, DateTime> _calculateDateRange(
    String period,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final DateTime now = DateTime.now();

    switch (period) {
      case 'Mes actual':
        return {
          'start': DateTime(now.year, now.month, 1),
          'end': DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        };
      case 'Últimos 30 días':
        return {'start': now.subtract(const Duration(days: 30)), 'end': now};
      case 'Últimos 90 días':
        return {'start': now.subtract(const Duration(days: 90)), 'end': now};
      case 'Últimos 365 días':
        return {'start': now.subtract(const Duration(days: 365)), 'end': now};
      case 'Costumbre':
        return {
          'start': startDate ?? now.subtract(const Duration(days: 30)),
          'end': endDate ?? now,
        };
      default:
        return {'start': now.subtract(const Duration(days: 30)), 'end': now};
    }
  }

  /// Obtener datos de gastos filtrados por fecha
  Future<List<Map<String, dynamic>>> _getGastosData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final gastosSnapshot = await _firestoreService.obtenerGastosStream().first;

    return gastosSnapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .where((data) {
          final fecha = (data['fecha'] as Timestamp).toDate();
          return fecha.isAfter(
                startDate.subtract(const Duration(seconds: 1)),
              ) &&
              fecha.isBefore(endDate.add(const Duration(seconds: 1)));
        })
        .toList();
  }

  /// Obtener datos de ingresos filtrados por fecha
  Future<List<Map<String, dynamic>>> _getIngresosData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final ingresosSnapshot = await _firestoreService
        .obtenerIngresosStream()
        .first;

    return ingresosSnapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .where((data) {
          final fecha = (data['fecha'] as Timestamp).toDate();
          return fecha.isAfter(
                startDate.subtract(const Duration(seconds: 1)),
              ) &&
              fecha.isBefore(endDate.add(const Duration(seconds: 1)));
        })
        .toList();
  }

  /// Obtener datos de categorías para mapear nombres
  Future<Map<String, String>> _getCategoriasData() async {
    final categoriasSnapshot = await _firestoreService
        .obtenerCategoriasStream()
        .first;

    Map<String, String> categoriasMap = {};

    // Agregar categorías personalizadas de Firebase
    for (var doc in categoriasSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      categoriasMap[doc.id] = data['nombre'] ?? 'Sin nombre';
    }

    // Agregar categorías predeterminadas
    categoriasMap.addAll({
      'comida_default': 'Comida',
      'transporte_default': 'Transporte',
      'servicios_default': 'Servicios',
      'entretenimiento_default': 'Entretenimiento',
      'salud_default': 'Salud',
      'otros_gastos_default': 'Otros',
      'salario_default': 'Salario',
      'negocio_default': 'Negocio',
      'freelance_default': 'Freelance',
      'inversiones_default': 'Inversiones',
      'otros_ingresos_default': 'Otros',
    });

    return categoriasMap;
  }

  /// Crear hoja de gastos en Excel
  void _createGastosSheet(
    Excel excel,
    List<Map<String, dynamic>> gastos,
    Map<String, String> categorias,
  ) {
    final sheet = excel['Gastos'];

    // Headers
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Fecha');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
      'Categoría',
    );
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Monto');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue(
      'Descripción',
    );

    // Estilo para headers
    for (int i = 1; i <= 4; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i - 1, rowIndex: 0),
      );
      cell.cellStyle = CellStyle(bold: true);
    }

    // Datos
    for (int i = 0; i < gastos.length; i++) {
      final gasto = gastos[i];
      final row = i + 2; // Empezar en fila 2 (después del header)

      // Fecha
      final fecha = (gasto['fecha'] as Timestamp).toDate();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row - 1))
          .value = TextCellValue(
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}',
      );

      // Categoría
      final categoryName =
          categorias[gasto['id_categoria']] ??
          gasto['concepto'] ??
          'Sin categoría';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row - 1))
          .value = TextCellValue(
        categoryName,
      );

      // Descripción
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row - 1))
          .value = TextCellValue(
        gasto['descripcion'] ?? 'Gasto',
      );

      // Monto
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row - 1))
          .value = DoubleCellValue(
        gasto['importe']?.toDouble() ?? 0.0,
      );
    }

    // Total
    if (gastos.isNotEmpty) {
      final totalRow = gastos.length + 2;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRow))
          .value = TextCellValue(
        'TOTAL:',
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRow))
          .cellStyle = CellStyle(
        bold: true,
      );

      final totalAmount = gastos.fold<double>(
        0.0,
        (sum, gasto) => sum + (gasto['importe']?.toDouble() ?? 0.0),
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRow))
          .value = DoubleCellValue(
        totalAmount,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRow))
          .cellStyle = CellStyle(
        bold: true,
      );
    }
  }

  /// Crear hoja de ingresos en Excel
  void _createIngresosSheet(
    Excel excel,
    List<Map<String, dynamic>> ingresos,
    Map<String, String> categorias,
  ) {
    final sheet = excel['Ingresos'];

    // Headers
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Fecha');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
      'Categoría',
    );
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Monto');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue(
      'Descripción',
    );

    // Estilo para headers
    for (int i = 1; i <= 4; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i - 1, rowIndex: 0),
      );
      cell.cellStyle = CellStyle(bold: true);
    }

    // Datos
    for (int i = 0; i < ingresos.length; i++) {
      final ingreso = ingresos[i];
      final row = i + 2; // Empezar en fila 2 (después del header)

      // Fecha
      final fecha = (ingreso['fecha'] as Timestamp).toDate();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row - 1))
          .value = TextCellValue(
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}',
      );

      // Categoría
      final categoryName =
          categorias[ingreso['id_categoria']] ??
          ingreso['concepto'] ??
          'Sin categoría';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row - 1))
          .value = TextCellValue(
        categoryName,
      );

      // Concepto
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row - 1))
          .value = TextCellValue(
        ingreso['concepto'] ?? 'Ingreso',
      );

      // Monto
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row - 1))
          .value = DoubleCellValue(
        ingreso['importe']?.toDouble() ?? 0.0,
      );
    }

    // Total
    if (ingresos.isNotEmpty) {
      final totalRow = ingresos.length + 2;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRow))
          .value = TextCellValue(
        'TOTAL:',
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRow))
          .cellStyle = CellStyle(
        bold: true,
      );

      final totalAmount = ingresos.fold<double>(
        0.0,
        (sum, ingreso) => sum + (ingreso['importe']?.toDouble() ?? 0.0),
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRow))
          .value = DoubleCellValue(
        totalAmount,
      );
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRow))
          .cellStyle = CellStyle(
        bold: true,
      );
    }
  }

  /// Crear hoja de resumen en Excel
  Future<void> _createResumenSheet(
    Excel excel,
    List<Map<String, dynamic>> gastos,
    List<Map<String, dynamic>> ingresos,
    Map<String, String> categorias,
    String period,
  ) async {
    final sheet = excel['Resumen'];

    // Título
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      'RESUMEN FINANCIERO',
    );
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
    );

    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
      'Período: $period',
    );
    sheet.cell(CellIndex.indexByString('A2')).cellStyle = CellStyle(bold: true);

    // Totales
    final totalGastos = gastos.fold<double>(
      0.0,
      (sum, gasto) => sum + (gasto['importe']?.toDouble() ?? 0.0),
    );
    final totalIngresos = ingresos.fold<double>(
      0.0,
      (sum, ingreso) => sum + (ingreso['importe']?.toDouble() ?? 0.0),
    );
    final balance = totalIngresos - totalGastos;

    sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue(
      'Total Ingresos:',
    );
    sheet.cell(CellIndex.indexByString('B4')).value = DoubleCellValue(
      totalIngresos,
    );
    sheet.cell(CellIndex.indexByString('C4')).value = TextCellValue('S/');

    sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue(
      'Total Gastos:',
    );
    sheet.cell(CellIndex.indexByString('B5')).value = DoubleCellValue(
      totalGastos,
    );
    sheet.cell(CellIndex.indexByString('C5')).value = TextCellValue('S/');

    sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Balance:');
    sheet.cell(CellIndex.indexByString('B6')).value = DoubleCellValue(balance);
    sheet.cell(CellIndex.indexByString('C6')).value = TextCellValue('S/');

    // Estilo para el balance
    sheet.cell(CellIndex.indexByString('A6')).cellStyle = CellStyle(bold: true);
    sheet.cell(CellIndex.indexByString('B6')).cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: balance >= 0 ? ExcelColor.green : ExcelColor.red,
    );

    // Estadísticas adicionales
    sheet.cell(CellIndex.indexByString('A8')).value = TextCellValue(
      'Número de gastos:',
    );
    sheet.cell(CellIndex.indexByString('B8')).value = IntCellValue(
      gastos.length,
    );

    sheet.cell(CellIndex.indexByString('A9')).value = TextCellValue(
      'Número de ingresos:',
    );
    sheet.cell(CellIndex.indexByString('B9')).value = IntCellValue(
      ingresos.length,
    );

    if (gastos.isNotEmpty) {
      sheet.cell(CellIndex.indexByString('A10')).value = TextCellValue(
        'Gasto promedio:',
      );
      sheet.cell(CellIndex.indexByString('B10')).value = DoubleCellValue(
        totalGastos / gastos.length,
      );
      sheet.cell(CellIndex.indexByString('C10')).value = TextCellValue('S/');
    }

    if (ingresos.isNotEmpty) {
      sheet.cell(CellIndex.indexByString('A11')).value = TextCellValue(
        'Ingreso promedio:',
      );
      sheet.cell(CellIndex.indexByString('B11')).value = DoubleCellValue(
        totalIngresos / ingresos.length,
      );
      sheet.cell(CellIndex.indexByString('C11')).value = TextCellValue('S/');
    }
  }

  /// Guardar y compartir el archivo Excel
  Future<void> _saveAndShareExcel(Excel excel, String period) async {
    // Obtener directorio de documentos
    final Directory directory = await getApplicationDocumentsDirectory();
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName =
        'Monexa_${period.replaceAll(' ', '_')}_$timestamp.xlsx';
    final String filePath = '${directory.path}/$fileName';

    // Guardar archivo
    final file = File(filePath);
    final excelBytes = excel.save();
    if (excelBytes != null) {
      await file.writeAsBytes(excelBytes);

      // Compartir archivo
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Reporte financiero de Monexa - $period',
        subject: 'Reporte financiero Monexa',
      );

      print('✅ ExcelService: Archivo guardado y compartido: $fileName');
    } else {
      throw Exception('No se pudo generar el archivo Excel');
    }
  }
}
