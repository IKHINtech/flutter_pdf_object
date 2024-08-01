import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class PDFViewerWithResizableOverlay extends StatefulWidget {
  final String url;

  PDFViewerWithResizableOverlay({required this.url});

  @override
  _PDFViewerWithResizableOverlayState createState() =>
      _PDFViewerWithResizableOverlayState();
}

class _PDFViewerWithResizableOverlayState
    extends State<PDFViewerWithResizableOverlay> {
  String? localPath;
  Offset offset = Offset(0, 0); // Initial position of the draggable widget
  double scale = 1.0; // Initial scale of the draggable widget
  double previousScale = 1.0;
  final double minScale = 0.5;
  final double maxScale = 2.0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final response = await http.get(Uri.parse(widget.url));
    final bytes = response.bodyBytes;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/temp.pdf');
    await file.writeAsBytes(bytes, flush: true);

    setState(() {
      localPath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Viewer with Resizable Overlay')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              localPath != null
                  ? PDFView(
                      nightMode: true,
                      filePath: localPath!,
                      onViewCreated: (controller) {},
                    )
                  : Center(child: CircularProgressIndicator()),
              Positioned(
                left: offset.dx,
                top: offset.dy,
                child: GestureDetector(
                  onScaleStart: (details) {
                    previousScale = scale;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      // Mengubah skala widget
                      scale = (previousScale * details.scale)
                          .clamp(minScale, maxScale);

                      // Mengubah posisi offset widget dengan memperhatikan skala
                      offset = _adjustOffsetToBounds(
                        Offset(
                          offset.dx + details.focalPointDelta.dx,
                          offset.dy + details.focalPointDelta.dy,
                        ),
                        constraints,
                      );
                    });
                  },
                  child: Transform.scale(
                    scale: scale,
                    child: _buildDraggableWidget(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDraggableWidget() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.blue.withOpacity(0.5),
      child: Center(
        child: Text(
          'Drag Me',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Offset _adjustOffsetToBounds(Offset offset, BoxConstraints constraints) {
    double dx = offset.dx;
    double dy = offset.dy;

    // Membatasi pergerakan agar tidak keluar dari sisi kiri dan atas
    dx = dx < 0 ? 0 : dx;
    dy = dy < 0 ? 0 : dy;

    // Membatasi pergerakan agar tidak keluar dari sisi kanan dan bawah
    if (dx + 100 * scale > constraints.maxWidth) {
      dx = constraints.maxWidth - 100 * scale;
    }
    if (dy + 100 * scale > constraints.maxHeight) {
      dy = constraints.maxHeight - 100 * scale;
    }

    return Offset(dx, dy);
  }
}
