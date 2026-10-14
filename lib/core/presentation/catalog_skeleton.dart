import 'package:flutter/material.dart';
import 'app_theme.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});
  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.stop();
    } else {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-2 + controller.value * 4, 0),
          end: Alignment(-1 + controller.value * 4, 0),
          colors: const [
            Color(0x00FFFFFF),
            Color(0x99FFFFFF),
            Color(0x00FFFFFF),
          ],
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class SkeletonBlock extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.line,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class CatalogSkeleton extends StatelessWidget {
  final bool horizontal;
  const CatalogSkeleton({super.key, this.horizontal = false});
  @override
  Widget build(BuildContext context) {
    final useList =
        horizontal ||
        MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(14) > 18;
    Widget card() => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.all(14),
      child: useList
          ? const Row(
              children: [
                SkeletonBlock(width: 86, height: 108, radius: 12),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBlock(height: 14),
                      SizedBox(height: 8),
                      SkeletonBlock(width: 100, height: 14),
                      SizedBox(height: 16),
                      SkeletonBlock(width: 75, height: 18),
                    ],
                  ),
                ),
              ],
            )
          : const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: SkeletonBlock(height: 150, radius: 12),
                  ),
                ),
                SizedBox(height: 16),
                SkeletonBlock(height: 14),
                SizedBox(height: 8),
                SkeletonBlock(width: 100, height: 14),
                SizedBox(height: 16),
                SkeletonBlock(width: 75, height: 18),
              ],
            ),
    );
    return Semantics(
      label: 'Cargando productos',
      liveRegion: true,
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: Shimmer(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBlock(width: 150, height: 10),
                        SizedBox(height: 20),
                        SkeletonBlock(width: 230, height: 34),
                        SizedBox(height: 10),
                        SkeletonBlock(width: 270, height: 34),
                        SizedBox(height: 18),
                        SkeletonBlock(width: 250, height: 13),
                        SizedBox(height: 32),
                        SkeletonBlock(width: 140, height: 10),
                        SizedBox(height: 14),
                        Row(
                          children: [
                            SkeletonBlock(width: 70, height: 40, radius: 24),
                            SizedBox(width: 8),
                            SkeletonBlock(width: 85, height: 40, radius: 24),
                            SizedBox(width: 8),
                            SkeletonBlock(width: 85, height: 40, radius: 24),
                          ],
                        ),
                        SizedBox(height: 24),
                        SkeletonBlock(width: 110, height: 24),
                      ],
                    ),
                  ),
                ),
                if (useList)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: 4,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, _) => card(),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid.builder(
                      itemCount: 6,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 280,
                            mainAxisExtent: 280,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                          ),
                      itemBuilder: (_, _) => card(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
