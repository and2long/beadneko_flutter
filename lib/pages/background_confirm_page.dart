import 'dart:typed_data';

import 'package:beadneko/i18n/i18n.dart';
import 'package:beadneko/pages/editor_page.dart';
import 'package:beadneko/store.dart';
import 'package:beadneko/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BackgroundConfirmPage extends StatefulWidget {
  const BackgroundConfirmPage({super.key});

  @override
  State<BackgroundConfirmPage> createState() => _BackgroundConfirmPageState();
}

class _BackgroundConfirmPageState extends State<BackgroundConfirmPage>
    with TickerProviderStateMixin {
  bool _requested = false;
  late final AnimationController _processingController;
  late final AnimationController _resultController;

  @override
  void initState() {
    super.initState();
    _processingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final store = context.read<BeadProjectProvider>();
        if (store.originalImage != null) {
          store.removeBackground().catchError((error) {
            ToastUtil.show(S.of(context).backgroundRemoveFailed);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _processingController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.backgroundRemoveTitle)),
      body: SafeArea(
        child: Consumer<BeadProjectProvider>(
          builder: (context, store, _) {
            final image = store.backgroundRemovedImage ?? store.originalImage;
            final isProcessing = store.isRemovingBackground;
            final content = image == null
                ? Center(
                    child: Text(strings.backgroundRemoveNoImage),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _PreviewImage(
                            image: image,
                            isProcessing: isProcessing,
                            processingAnimation: _processingController,
                            resultAnimation: _resultController,
                          ),
                        ),
                      ),
                      if (isProcessing)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(strings.backgroundRemoveProcessing),
                              ),
                            ],
                          ),
                        ),
                      if (store.backgroundRemovalError != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                          child: Text(
                            strings.backgroundRemoveFailed,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  store.clearProject();
                                  Navigator.of(context).pop();
                                },
                                child: Text(strings.backgroundRemoveCancel),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: store.isRemovingBackground
                                    ? null
                                    : () async {
                                        await store.processImage();
                                        if (context.mounted) {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (_) => const EditorPage(),
                                            ),
                                          );
                                        }
                                      },
                                child: Text(strings.backgroundRemoveConfirm),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: content,
            );
          },
        ),
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({
    required this.image,
    required this.isProcessing,
    required this.processingAnimation,
    required this.resultAnimation,
  });

  final Uint8List image;
  final bool isProcessing;
  final Animation<double> processingAnimation;
  final Animation<double> resultAnimation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _ImageSurface(image: image),
        if (isProcessing)
          _ProcessingOverlay(animation: processingAnimation)
        else
          _RotatingRing(
            animation: resultAnimation,
            strokeWidth: 3,
            ringColor: Colors.tealAccent,
            glowColor: Colors.tealAccent,
            size: 240,
          ),
      ],
    );
  }
}

class _ImageSurface extends StatelessWidget {
  const _ImageSurface({required this.image});

  final Uint8List image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: Image.memory(image, fit: BoxFit.contain),
      ),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              _RotatingRing(
                animation: animation,
                strokeWidth: 4,
                ringColor: Colors.pinkAccent,
                glowColor: Colors.white,
                size: 200,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).backgroundRemoveProcessing,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RotatingRing extends StatelessWidget {
  const _RotatingRing({
    required this.animation,
    required this.strokeWidth,
    required this.ringColor,
    required this.glowColor,
    required this.size,
  });

  final Animation<double> animation;
  final double strokeWidth;
  final Color ringColor;
  final Color glowColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: animation,
      child: CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(
          strokeWidth: strokeWidth,
          ringColor: ringColor,
          glowColor: glowColor,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.strokeWidth,
    required this.ringColor,
    required this.glowColor,
  });

  final double strokeWidth;
  final Color ringColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          ringColor.withValues(alpha: 0.0),
          glowColor.withValues(alpha: 0.9),
          ringColor.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawArc(rect, 0, 5.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.glowColor != glowColor;
  }
}
