import 'package:flutter/material.dart';
import 'package:subscription_manager_flutter/screens/dashboard_screen.dart';
import 'package:subscription_manager_flutter/screens/login_screen.dart';
import 'package:subscription_manager_flutter/services/auth_storage.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';

class SubscriptionPreviewScreen extends StatelessWidget {
  const SubscriptionPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          children: [
            _OnboardingPage(),
            const _DashboardPage(),
            const _SubscriptionDetailsPage(),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  _OnboardingPage();

  Future<void> _handleGetStarted(BuildContext context) async {
    final authStorage = AuthStorage();
    final token = await authStorage.readToken();

    if (!context.mounted) return;

    // Get the navigator reference while context is still valid
    final navigator = Navigator.of(context);

    if (token != null && token.isNotEmpty) {
      // User is already logged in, navigate to dashboard
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => DashboardScreen(
            onLogout: () async {
              await authStorage.clearToken();
              // Use the root navigator to navigate
              if (ctx.mounted) {
                Navigator.of(ctx, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(
                    builder: (loginCtx) => LoginScreen(
                      onLoggedIn: (token) {
                        if (loginCtx.mounted) {
                          Navigator.of(loginCtx, rootNavigator: true)
                              .pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => DashboardScreen(
                                onLogout: () {},
                                onOpenSettings: (_) {},
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              }
            },
            onOpenSettings: (_) {},
          ),
        ),
      );
    } else {
      // User needs to login
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => LoginScreen(
            onLoggedIn: (token) async {
              // Navigate to dashboard after successful login
              if (ctx.mounted) {
                Navigator.of(ctx, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(
                    builder: (dashCtx) => DashboardScreen(
                      onLogout: () async {
                        await authStorage.clearToken();
                        if (dashCtx.mounted) {
                          Navigator.of(dashCtx, rootNavigator: true)
                              .pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(
                                onLoggedIn: (_) {},
                              ),
                            ),
                          );
                        }
                      },
                      onOpenSettings: (_) {},
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              const _StripedCircle(size: 210),
              Positioned(
                left: 6,
                top: 8,
                child: _InfoBubble(
                  title: '12',
                  subtitle: 'Active Plans',
                  color: AppColors.textPrimary,
                  textColor: Colors.white,
                ),
              ),
              Positioned(
                right: 8,
                bottom: 12,
                child: _InfoBubble(
                  title: r'$328',
                  subtitle: 'Monthly',
                  color: AppColors.accent,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Track every subscription\nwith clarity and control',
            textAlign: TextAlign.center,
            style: textTheme.displaySmall?.copyWith(height: 1.2),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Stay ahead of renewals, spot overlaps, and\noptimize your monthly spend in seconds.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const Spacer(),
          Material(
            color: AppColors.primary,
            borderRadius: AppRadii.md,
            child: InkWell(
              onTap: () => _handleGetStarted(context),
              borderRadius: AppRadii.md,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: AppRadii.md,
                  boxShadow: AppShadows.soft,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Build My Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: textTheme.titleMedium
                      ?.copyWith(color: AppColors.textPrimary),
                  children: const [
                    TextSpan(text: 'Hello, '),
                    TextSpan(
                      text: 'Morgan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' 👋'),
                  ],
                ),
              ),
              Row(
                children: const [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.surface,
                    child: Icon(Icons.notifications_none,
                        size: 20, color: AppColors.textPrimary),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=80&q=60',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Monthly Spend', style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(r'$428.50', style: textTheme.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Down \$48.20 vs last month',
            style: textTheme.labelMedium?.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Smart Insights', style: textTheme.titleMedium),
              Text('View All', style: textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: const [
              Expanded(
                child: _InsightCard(
                  title: 'Unused Trials',
                  subtitle: '3 ending soon',
                  value: '€42 saved',
                  icon: Icons.timelapse,
                  backgroundColor: Color(0xFFE9ECFF),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _InsightCard(
                  title: 'Top Category',
                  subtitle: 'Streaming',
                  value: '€118 / mo',
                  icon: Icons.play_circle_outline,
                  backgroundColor: Color(0xFFFFF4D6),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Renewals', style: textTheme.titleMedium),
              Text('See All', style: textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SubscriptionRow(
            title: 'Netflix',
            subtitle: 'Renews on 12 Feb',
            price: r'$15.99',
            change: '2 days left',
            icon: Icons.movie_filter_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          const _SubscriptionRow(
            title: 'Notion',
            subtitle: 'Renews on 16 Feb',
            price: r'$8.00',
            change: '6 days left',
            icon: Icons.note_alt_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          const _SubscriptionRow(
            title: 'Spotify',
            subtitle: 'Renews on 20 Feb',
            price: r'$11.99',
            change: '10 days left',
            icon: Icons.headphones_outlined,
          ),
        ],
      ),
    );
  }
}

class _SubscriptionDetailsPage extends StatelessWidget {
  const _SubscriptionDetailsPage();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.arrow_back,
                    size: 20, color: AppColors.textPrimary),
              ),
              Text(
                'Subscription Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.more_horiz,
                    size: 20, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.play_circle_filled, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Netflix Premium', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Streaming · Family plan',
                        style: textTheme.labelMedium),
                  ],
                ),
              ),
              const Icon(Icons.star_border, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: const [
              _Tag(label: 'Renewing', color: Color(0xFFE3F7F3)),
              _Tag(label: 'Monthly', color: Color(0xFFF2F3F7)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _TabLabel(title: 'Overview', selected: true),
              _TabLabel(title: 'Billing', selected: false),
              _TabLabel(title: 'Activity', selected: false),
              _TabLabel(title: 'Support', selected: false),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Text('About Subscription', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enjoy 4K streaming, offline downloads, and\ncustom profiles for your household.',
            style: textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Usage Forecast', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: const [
              _PredictionFilter(label: 'All', selected: false),
              _PredictionFilter(label: '1W', selected: true),
              _PredictionFilter(label: '1M', selected: false),
              _PredictionFilter(label: '6M', selected: false),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: AppRadii.md,
              color: AppColors.surface,
              boxShadow: AppShadows.subtle,
            ),
            child: const _LineChartPlaceholder(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.md,
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next Payment', style: textTheme.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(r'$15.99',
                    style: textTheme.displaySmall?.copyWith(fontSize: 24)),
                const SizedBox(height: AppSpacing.xs),
                Text('Auto-renew on Feb 12, 8:00 AM',
                    style: textTheme.labelMedium),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: null,
                        child: const Text('Upgrade'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: null,
                        child: const Text('Pause Plan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _StripedCircle extends StatelessWidget {
  const _StripedCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StripedCirclePainter(),
    );
  }
}

class _StripedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = const Color(0xFFE7E4F7)
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, circlePaint);

    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(clipPath);

    final stripePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    const spacing = 14.0;
    for (double y = -size.height; y < size.height * 2; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + size.width),
        stripePaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoBubble extends StatelessWidget {
  const _InfoBubble({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.backgroundColor,
  });

  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surface,
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('Monthly impact', style: textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _SubscriptionRow extends StatelessWidget {
  const _SubscriptionRow({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.change,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String price;
  final String change;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.md,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.background,
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: textTheme.labelMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(change,
                  style:
                      textTheme.labelMedium?.copyWith(color: AppColors.accent)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.lg,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.title, required this.selected});

  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? AppColors.textPrimary : AppColors.muted,
      ),
    );
  }
}

class _PredictionFilter extends StatelessWidget {
  const _PredictionFilter({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: selected ? AppColors.textPrimary : Colors.transparent,
        borderRadius: AppRadii.lg,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _LineChartPlaceholder extends StatelessWidget {
  const _LineChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF1F7),
                borderRadius: AppRadii.sm,
              ),
              child: const Text(
                r'$183',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          CustomPaint(
            size: const Size(double.infinity, 100),
            painter: _LineChartPainter(),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.35, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height * 0.55);
    path.lineTo(size.width * 0.7, size.height * 0.65);
    path.lineTo(size.width * 0.85, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.55);

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
