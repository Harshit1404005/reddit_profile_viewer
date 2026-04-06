import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class SplashPage extends StatelessWidget {
  final VoidCallback onInitialized;

  const SplashPage({super.key, required this.onInitialized});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.05),
              ),
            ).animate().fadeIn(duration: 2.seconds).blur(begin: const Offset(120, 120), end: const Offset(120, 120)),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            right: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withOpacity(0.05),
              ),
            ).animate().fadeIn(duration: 2.seconds).blur(begin: const Offset(120, 120), end: const Offset(120, 120)),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Identity Cluster
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Ring
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                        .scale(begin: const Offset(1.1, 1.1), end: const Offset(1.15, 1.15), duration: 2.seconds, curve: Curves.easeInOut)
                        .then().scale(begin: const Offset(1.15, 1.15), end: const Offset(1.1, 1.1)),

                      // Glass Core
                      GlassPanel(
                        borderRadius: 80,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.rocket,
                              color: AppTheme.primary,
                              size: 48,
                            ).animate().scale(delay: 400.ms).fadeIn(),
                            Container(
                              height: 40,
                              width: 2,
                              color: AppTheme.primary.withOpacity(0.3),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            FaIcon(
                              FontAwesomeIcons.microchip,
                              color: AppTheme.secondary,
                              size: 48,
                            ).animate().scale(delay: 600.ms).fadeIn(),
                          ],
                        ),
                      ).animate().shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.1)),
                      
                      // Orbiting point
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppTheme.tertiary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.surface, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.tertiary.withOpacity(0.4),
                                blurRadius: 10,
                              )
                            ],
                          ),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                        .custom(
                          duration: 4.seconds,
                          builder: (context, value, child) => Transform.rotate(
                            angle: value * 2 * 3.14159,
                            child: child,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Branding
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineLarge,
                    children: const [
                      TextSpan(text: 'Reddit'),
                      TextSpan(text: 'Scope', style: TextStyle(color: AppTheme.primary)),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
                
                Text(
                  'UNDERSTAND ANY REDDIT USER',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 4.0,
                    color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ).animate().fadeIn(delay: 1.seconds),
              ],
            ),
          ),
          
          // System Indicators
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 240,
                child: Column(
                  children: [
                    // Loader Track
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.33,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.secondary],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 1.5.seconds, color: Colors.white.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('INITIALIZING ENGINE', style: Theme.of(context).textTheme.labelSmall),
                        Text('v4.0.2-alpha', style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ).animate().callback(
            delay: 3.seconds,
            callback: (_) => onInitialized(),
          ),
    );
  }
}
