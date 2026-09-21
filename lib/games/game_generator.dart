import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _DashedRoundedBorder extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  const _DashedRoundedBorder({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      for (
        double distance = 0;
        distance < metric.length;
        distance += dashLength + gapLength
      ) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            (distance + dashLength).clamp(0, metric.length),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorder oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      radius != oldDelegate.radius ||
      dashLength != oldDelegate.dashLength ||
      gapLength != oldDelegate.gapLength;
}

class GameGeneratorPage extends StatelessWidget {
  final String title;
  final String description;

  final Color primaryColor;
  final Color uploadColor;
  final Color uploadButtonColor;
  final Color generateButtonColor;

  final VoidCallback onUpload;
  final VoidCallback onGenerate;

  const GameGeneratorPage({
    super.key,
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.uploadColor,
    required this.uploadButtonColor,
    required this.generateButtonColor,
    required this.onUpload,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white.withValues(alpha: 0.5),
            size: 27,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ================= CONTENT =================
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),

                      // TITLE
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // DESCRIPTION
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF888888),
                        ),
                      ),

                      const SizedBox(height: 82),

                      // ================= UPLOAD =================
                      GestureDetector(
                        onTap: onUpload,
                        child: CustomPaint(
                          foregroundPainter: _DashedRoundedBorder(
                            color: primaryColor,
                            strokeWidth: 1.5,
                            dashLength: 7,
                            gapLength: 5,
                            radius: 15,
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: uploadColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Container(
                                width: 175,
                                height: 47,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: uploadButtonColor,
                                  borderRadius: BorderRadius.circular(11),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x40000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Drop your material here\n'
                                  '(PDF, Img, Docx.)',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    height: 1.15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // ================= GENERATE =================
                      SizedBox(
                        width: 115,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: onGenerate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: generateButtonColor,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Generate',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
