import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:khatabook/data/models/contact.dart';
import 'package:khatabook/data/models/transaction.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class PdfService {
  static Future<void> generateContactTransactionsPdf(
      Contact contact,
      List<AppTransaction> transactions,
      double willGive,
      double willGet,
      ) async {
    final pdf = pw.Document();

    try {
      // Load a standard font
      final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
      final ttf = pw.Font.ttf(fontData);

      // Define fonts
      final normalFont = ttf;
      final boldFont = ttf;

      // Format date as "15 Apr 2025"
      final dateFormatter = DateFormat('dd MMM yyyy');
      final timeFormatter = DateFormat('h:mm a');

      // Create PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            _buildHeader(normalFont, boldFont, contact),
            _buildTransactionTable(
              normalFont,
              boldFont,
              transactions,
              dateFormatter,
              timeFormatter,
            ),
          ],
        ),
      );

      // Save the PDF
      final output = await _savePdfFile(pdf, '${_sanitizeFileName(contact.name)}_transactions.pdf');

      if (output != null) {
        // Open the PDF file
        await OpenFile.open(output.path);
      }
    } catch (e) {
      print('Error generating PDF: $e');
      // You might want to re-throw or handle this error
      rethrow;
    }
  }

  // Helper function to sanitize text by removing emojis and special characters
  static String _sanitizeText(String text) {
    // Remove emojis and other problematic characters
    return text.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
  }

  // Helper function to sanitize file names
  static String _sanitizeFileName(String fileName) {
    // Remove emojis and other problematic characters
    String sanitized = fileName.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
    // Replace invalid file name characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    // Trim and ensure we have a valid name
    sanitized = sanitized.trim();
    return sanitized.isEmpty ? 'transaction_report' : sanitized;
  }

  static pw.Widget _buildHeader(pw.Font normalFont, pw.Font boldFont, Contact contact) {
    // Sanitize contact name
    final sanitizedName = _sanitizeText(contact.name);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Transaction Report',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 24,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated on: ${DateFormat('dd MMM yyyy, h:mm a').format(DateTime.now())}',
          style: pw.TextStyle(
            font: normalFont,
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                width: 40,
                height: 40,
                decoration: const pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: PdfColors.white,
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  _getInitials(sanitizedName),
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    sanitizedName,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 18,
                      color: PdfColors.blue900,
                    ),
                  ),
                  if (contact.phone != null && contact.phone!.isNotEmpty)
                    pw.Text(
                      contact.phone!,
                      style: pw.TextStyle(
                        font: normalFont,
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildTransactionTable(
      pw.Font normalFont,
      pw.Font boldFont,
      List<AppTransaction> transactions,
      DateFormat dateFormatter,
      DateFormat timeFormatter,
      ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Transaction History',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 18,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2), // Date & Time
              1: const pw.FlexColumnWidth(2), // Description
              2: const pw.FlexColumnWidth(1), // You Gave
              3: const pw.FlexColumnWidth(1), // You Got
            },
            children:[
             pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.blue50,
              ),
              children: [
                _buildTableCell('Date & Time', normalFont, bold: true, align: pw.Alignment.center),
                _buildTableCell('Description', normalFont, bold: true, align: pw.Alignment.center),
                _buildTableCell('You Gave', normalFont, bold: true, align: pw.Alignment.center),
                _buildTableCell('You Got', normalFont, bold: true, align: pw.Alignment.center),
              ],
            ),
            ...transactions.map((transaction) {
              DateTime date;
              try {
                if (transaction.date is String) {
                  date = (transaction.date);
                } else if (transaction.date is DateTime) {
                  date = transaction.date;
                } else {
                  date = DateTime.now(); // Fallback
                }
              } catch (e) {
                date = DateTime.now(); // Fallback if parsing fails
              }

              final formattedDate = dateFormatter.format(date);

              DateTime createdAt;
              try {
                createdAt = transaction.createdAt;
              } catch (e) {
                createdAt = date; // Fallback to the date
              }

              final formattedTime = timeFormatter.format(createdAt);
              final isDebit = transaction.type == 'debit';

              // Sanitize description
              String description = transaction.description ?? '-';
              description = _sanitizeText(description);

              return pw.TableRow(
                children: [
                  _buildTableCell(
                    '$formattedDate\n$formattedTime',
                    normalFont,
                    align: pw.Alignment.centerLeft,
                  ),
                  _buildTableCell(
                    description,
                    normalFont,
                    align: pw.Alignment.centerLeft,
                  ),
                  _buildTableCell(
                    isDebit ? '₹ ${transaction.amount.toStringAsFixed(2)}' : '',
                    normalFont,
                    color: PdfColors.red,
                    align: pw.Alignment.centerRight,
                  ),
                  _buildTableCell(
                    !isDebit ? '₹ ${transaction.amount.toStringAsFixed(2)}' : '',
                    normalFont,
                    color: PdfColors.green,
                    align: pw.Alignment.centerRight,
                  ),
                ],
              );
            }).toList(),
    ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(
      String text,
      pw.Font font, {
        bool bold = false,
        PdfColor color = PdfColors.black,
        pw.Alignment align = pw.Alignment.centerLeft,
      }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: align,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          color: color,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  // New implementation without permission_handler
  static Future<File?> _savePdfFile(pw.Document pdf, String fileName) async {
   if(Platform.isAndroid)
    {
      try {
        // Get the temporary directory
        final tempDir = await getTemporaryDirectory();
        final tempPath = tempDir.path;
        final tempFile = File('$tempPath/$fileName');

        // Save the PDF to the temporary file
        await tempFile.writeAsBytes(await pdf.save());

        // Use flutter_file_dialog which handles permissions internally
        final params = SaveFileDialogParams(
          data: await tempFile.readAsBytes(),
          fileName: fileName,
        );

        final filePath = await FlutterFileDialog.saveFile(params: params);

        if (filePath != null) {
          return File(filePath);
        }

        return null;
      } catch (e) {
        print('Error saving PDF: $e');
        return null;
      }
    }
  }
}