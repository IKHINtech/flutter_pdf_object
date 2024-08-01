import 'package:flutter/material.dart';
import 'package:flutter_pdf_object/flutter_pdf_object.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PDFViewerWithResizableOverlay(
              url:
                  "https://apisdigisign.pelitabangsa.ac.id/media/digisign/document_original/SK_PEMBIMBING_SKRIPSI_TA_2020-2021_-_Donny_Maulana_S.Kom_M.M.S.I.pdf"),
        ),
      ),
    );
  }
}
