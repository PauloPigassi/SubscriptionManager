import 'package:flutter/material.dart';

class StellarWisePreviewScreen extends StatelessWidget {
  const StellarWisePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: PageView(
          children: const [
            _OnboardingPage(),
            _DashboardPage(),
            _StockDetailsPage(),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              const _StripedCircle(size: 210),
              Positioned(
                left: 0,
                top: 0,
                child: _InfoBubble(
                  title: '100%',
                  subtitle: 'Trusted',
                  color: const Color(0xFF1F2545),
                  textColor: Colors.white,
                ),
              ),
              Positioned(
                right: 8,
                bottom: 10,
                child: _InfoBubble(
                  title: '100%',
                  subtitle: 'Secure',
                  color: const Color(0xFF6EC1E4),
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Your Gateway to\nFinancial Prosperity\nWill Start Here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Color(0xFF1D1E25),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "From tracking your portfolio's to receiving\nintelligent investment suggestions.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1D1E25),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Start Investing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.double_arrow_rounded, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Color(0xFF1D1E25), fontSize: 18),
                  children: [
                    TextSpan(text: 'Morning, '),
                    TextSpan(
                      text: 'Alex',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' 👋'),
                  ],
                ),
              ),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFF0F1F5),
                    child: Icon(Icons.notifications_none, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=80&q=60',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            r'$228,845.88',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D1E25),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '↑ \$2,736.04 (+12% vs last month)',
            style: TextStyle(color: Colors.indigo.shade400, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'My Portfolio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                'See All',
                style: TextStyle(fontSize: 13, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _PortfolioCard(
                  title: 'Daily Living',
                  subtitle: 'Etherium',
                  balance: '\$402.00',
                  icon: Icons.local_fire_department_outlined,
                  backgroundColor: Color(0xFFE3DDFC),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _PortfolioCard(
                  title: 'Education',
                  subtitle: 'Bitcoin',
                  balance: '\$258.00',
                  icon: Icons.currency_bitcoin,
                  backgroundColor: Color(0xFFFFF6CC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Trending Stocks',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                'See All',
                style: TextStyle(fontSize: 13, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _StockRow(
            title: 'Stellar',
            subtitle: 'SII',
            price: '\$92.75',
            change: '15.29%',
            icon: Icons.waves,
          ),
          const SizedBox(height: 12),
          const _StockRow(
            title: 'Galactic',
            subtitle: 'GCG',
            price: '\$210.20',
            change: '24.30%',
            icon: Icons.blur_circular,
          ),
          const SizedBox(height: 12),
          const _StockRow(
            title: 'AeroWave',
            subtitle: 'AWD',
            price: '\$310.70',
            change: '14.66%',
            icon: Icons.brightness_5,
          ),
        ],
      ),
    );
  }
}

class _StockDetailsPage extends StatelessWidget {
  const _StockDetailsPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFF0F1F5),
                child: Icon(Icons.arrow_back, size: 20),
              ),
              Text(
                'Stock Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFF0F1F5),
                child: Icon(Icons.more_horiz, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF1D1E25),
                child: Icon(Icons.auto_awesome, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Stellar Innovations Inc.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Space technology company',
                      style: TextStyle(color: Colors.black45, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.star_border, color: Colors.black38),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: const [
              _Pill(label: 'Trending', color: Color(0xFFDFF5E8)),
              _Pill(label: 'Space Tech', color: Color(0xFFF2F2F2)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _TabLabel(title: 'Overview', selected: true),
              _TabLabel(title: 'Details', selected: false),
              _TabLabel(title: 'Documents', selected: false),
              _TabLabel(title: 'Market News', selected: false),
            ],
          ),
          const Divider(height: 24),
          const Text(
            'About Company',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Stellar Innovations Inc. (SII) is a cutting-edge tech\n'
            'company focused on developing innovative solutions\n'
            'for space exploration and satellite communication.',
            style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Market Prediction',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _PredictionFilter(label: 'All', selected: false),
              _PredictionFilter(label: '1Day', selected: true),
              _PredictionFilter(label: '1Week', selected: false),
              _PredictionFilter(label: '1Month', selected: false),
              _PredictionFilter(label: '1Year', selected: false),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const _LineChartPlaceholder(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Price',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 6),
                const Text(
                  r'$92.75',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Closed: Feb 28, 8:00 PM GMT',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D1E25),
                          disabledBackgroundColor: const Color(0xFF1D1E25),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Buy Now'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1D1E25),
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Sell Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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

    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(clipPath);

    final stripePaint = Paint()
      ..color = const Color(0xFF5B5CE2)
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
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
          const SizedBox(height: 4),
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

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({
    required this.title,
    required this.subtitle,
    required this.balance,
    required this.icon,
    required this.backgroundColor,
  });

  final String title;
  final String subtitle;
  final String balance;
  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 18, color: const Color(0xFF1D1E25)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 12),
          Text(
            balance,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          const Text(
            'Total Balance',
            style: TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF0F1F5),
            child: Icon(icon, size: 18, color: const Color(0xFF1D1E25)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                '↑ $change',
                style: TextStyle(fontSize: 12, color: Colors.green.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
        color: selected ? const Color(0xFF1D1E25) : Colors.black38,
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
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1D1E25) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: selected ? Colors.white : Colors.black54,
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
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF1F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                r'$1,832',
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
      ..color = const Color(0xFF1D1E25)
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
