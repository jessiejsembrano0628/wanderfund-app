import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

const _canvasColor = Color(0xFFF4F1EA);
const _surfaceColor = Color(0xFFFFFFFF);
const _primaryTextColor = Color(0xFF2C2C2C);
const _secondaryTextColor = Color(0xFF8C8275);
const _brandColor = Color(0xFF4A7C59);
const _accentColor = Color(0xFFC46B4A);

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  final _aboutKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _howItWorksKey = GlobalKey();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final shouldShow = _scrollController.offset > 300;
    if (shouldShow == _showBackToTop) return;
    setState(() => _showBackToTop = shouldShow);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _scrollTo(GlobalKey sectionKey) async {
    _scaffoldKey.currentState?.closeEndDrawer();
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    final sectionContext = sectionKey.currentContext;
    if (sectionContext == null || !sectionContext.mounted) return;
    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      alignment: 0.04,
    );
  }

  void _launchApp() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isInitialized || authProvider.isLoading) return;
    Navigator.of(
      context,
    ).pushNamed(authProvider.isAuthenticated ? '/menu' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final canLaunch = authProvider.isInitialized && !authProvider.isLoading;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _canvasColor,
      appBar: AppBar(
        backgroundColor: _canvasColor,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 24,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: _brandColor,
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 9, height: 9),
            ),
            SizedBox(width: 10),
            Text(
              'WanderFund',
              style: TextStyle(
                color: _primaryTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Open navigation menu',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu_rounded),
              color: _primaryTextColor,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      endDrawer: _buildDrawer(canLaunch),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              tooltip: 'Back to top',
              backgroundColor: _brandColor,
              foregroundColor: Colors.white,
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              ),
              child: const Icon(Icons.keyboard_arrow_up_rounded),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          key: const Key('landing-scroll-view'),
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(constraints.maxWidth),
              _buildFeatures(constraints.maxWidth),
              _buildHowItWorks(),
              _buildCallToAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(bool canLaunch) {
    return Drawer(
      backgroundColor: _surfaceColor,
      width: 320,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.explore_outlined, color: _brandColor),
                  SizedBox(width: 10),
                  Text(
                    'WanderFund',
                    style: TextStyle(
                      color: _primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _drawerLink('About', 'nav-about', _aboutKey),
              _drawerLink('Features', 'nav-features', _featuresKey),
              _drawerLink('How It Works', 'nav-how-it-works', _howItWorksKey),
              const Spacer(),
              FilledButton.icon(
                key: const Key('drawer-launch'),
                onPressed: canLaunch ? _launchApp : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _brandColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.arrow_outward_rounded),
                label: const Text('Sign In / Launch App'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerLink(String label, String keyName, GlobalKey sectionKey) {
    return ListTile(
      key: Key(keyName),
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(
          color: _primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
      onTap: () => _scrollTo(sectionKey),
    );
  }

  Widget _buildHero(double availableWidth) {
    final isWide = availableWidth >= 820;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow(label: 'TRAVEL BETTER, TOGETHER'),
        const SizedBox(height: 22),
        Text(
          'Group Travel Expenses, Made Calm & Transparent',
          style: TextStyle(
            color: _primaryTextColor,
            fontFamily: 'serif',
            fontSize: isWide ? 52 : 40,
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'WanderFund is a minimalist shared ledger for friends, families, and barkadas. Keep contributions, expenses, and approvals transparent in one place, without messy spreadsheet calculations, lost receipts, or awkward payment chasing.',
          style: TextStyle(
            color: _secondaryTextColor,
            fontSize: 17,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 28),
        _LaunchButton(
          key: const Key('hero-launch'),
          label: 'Start a Travel fund',
          onPressed: _launchApp,
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            Icon(Icons.check_circle_outline, size: 18, color: _brandColor),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Every contribution. Every receipt. One shared view.',
                style: TextStyle(color: _secondaryTextColor, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );

    final preview = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ScreenshotFrame(
          key: Key('dashboard-preview'),
          assetPath: 'assets/Travel Fund.png',
          label: 'Boracay trip dashboard',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE6E0D6)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.place_outlined, size: 17, color: _accentColor),
              SizedBox(width: 6),
              Text(
                'BORACAY 2027',
                style: TextStyle(
                  color: _primaryTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      key: _aboutKey,
      color: _canvasColor,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 24,
        vertical: isWide ? 64 : 42,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 6, child: copy),
                    const SizedBox(width: 56),
                    Expanded(flex: 4, child: Center(child: preview)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    copy,
                    const SizedBox(height: 44),
                    Center(child: preview),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFeatures(double availableWidth) {
    final isWide = availableWidth >= 820;
    return Container(
      key: _featuresKey,
      color: _surfaceColor,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 24,
        vertical: isWide ? 76 : 54,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Eyebrow(label: 'MADE FOR THE WHOLE GROUP'),
              const SizedBox(height: 16),
              const Text(
                'Everything Your Group Needs to Stay Aligned',
                style: TextStyle(
                  color: _primaryTextColor,
                  fontFamily: 'serif',
                  fontSize: 38,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 46),
              _FeatureShowcase(
                isWide: isWide,
                number: '01',
                title: 'Shared Ledgers & Real-Time Balances',
                description:
                    'Track running funds, contributions, and expenses effortlessly in your local currency. See cash-ins, purchases, and approvals together, with a clear record of who paid what.',
                assetPath: 'assets/Transactions.png',
                imageLabel: 'Transaction ledger with balances and approvals',
                imageKey: const Key('ledger-preview'),
                icon: Icons.account_balance_wallet_outlined,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: isWide ? 48 : 34),
                child: const Divider(color: Color(0xFFE8E2D8), height: 1),
              ),
              _FeatureShowcase(
                isWide: isWide,
                number: '02',
                title: 'Frictionless Joining',
                description:
                    'Bring your group together instantly with a unique invite code. Drop it straight into your group chat and everyone can join the same travel fund in moments.',
                assetPath: 'assets/Join Travel Fund.png',
                imageLabel: 'Join Travel Fund invite-code dialog',
                imageKey: const Key('join-preview'),
                icon: Icons.group_add_outlined,
                reverse: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    const steps = [
      (
        '01',
        'Create your Travel fund',
        'Set up your trip and choose a base currency for your group.',
      ),
      (
        '02',
        'Invite your travel group',
        'Share your unique invite code right in your group chat.',
      ),
      (
        '03',
        'Keep the ledger moving',
        'Log expenses as you go and see clearly who paid what.',
      ),
    ];

    return Container(
      key: _howItWorksKey,
      color: const Color(0xFFE7EDE5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Eyebrow(label: 'THREE SIMPLE STEPS'),
              const SizedBox(height: 16),
              const Text(
                'How It Works',
                style: TextStyle(
                  color: _primaryTextColor,
                  fontFamily: 'serif',
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 760;
                  final children = steps
                      .map(
                        (step) => _StepItem(
                          number: step.$1,
                          title: step.$2,
                          description: step.$3,
                        ),
                      )
                      .toList();
                  if (!isWide) {
                    return Column(
                      children: [
                        for (var index = 0; index < children.length; index++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: index == children.length - 1 ? 0 : 28,
                            ),
                            child: children[index],
                          ),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var index = 0; index < children.length; index++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == children.length - 1 ? 0 : 32,
                            ),
                            child: children[index],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      color: _brandColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              final message = const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Make room for the good parts of going together.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 32,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Start your shared travel fund with WanderFund.',
                    style: TextStyle(color: Color(0xFFE2EAE1), fontSize: 16),
                  ),
                ],
              );
              final button = _LaunchButton(
                key: const Key('footer-launch'),
                label: 'Get Started / Sign In',
                onPressed: _launchApp,
                foregroundColor: _brandColor,
                backgroundColor: Colors.white,
              );
              return isWide
                  ? Row(
                      children: [
                        Expanded(child: message),
                        const SizedBox(width: 32),
                        button,
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [message, const SizedBox(height: 24), button],
                    );
            },
          ),
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String label;

  const _Eyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _brandColor,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _LaunchButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color foregroundColor;
  final Color backgroundColor;

  const _LaunchButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.foregroundColor = Colors.white,
    this.backgroundColor = _brandColor,
  });

  @override
  Widget build(BuildContext context) {
    final isReady = context.select<AuthProvider, bool>(
      (provider) => provider.isInitialized && !provider.isLoading,
    );
    return FilledButton.icon(
      onPressed: isReady ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: const Color(0xFFB7C4B8),
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.arrow_forward_rounded, size: 19),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _ScreenshotFrame extends StatelessWidget {
  final String assetPath;
  final String label;

  const _ScreenshotFrame({
    super.key,
    required this.assetPath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: _primaryTextColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          assetPath,
          key: Key('image-$label'),
          width: 286,
          fit: BoxFit.fitWidth,
          semanticLabel: label,
        ),
      ),
    );
  }
}

class _FeatureShowcase extends StatelessWidget {
  final bool isWide;
  final String number;
  final String title;
  final String description;
  final String assetPath;
  final String imageLabel;
  final Key imageKey;
  final IconData icon;
  final bool reverse;

  const _FeatureShowcase({
    required this.isWide,
    required this.number,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.imageLabel,
    required this.imageKey,
    required this.icon,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: _brandColor),
        const SizedBox(height: 20),
        Text(
          number,
          style: const TextStyle(
            color: _accentColor,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: _primaryTextColor,
            fontFamily: 'serif',
            fontSize: 30,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(
            color: _secondaryTextColor,
            fontSize: 16,
            height: 1.65,
          ),
        ),
      ],
    );
    final image = Center(
      child: _ScreenshotFrame(
        key: imageKey,
        assetPath: assetPath,
        label: imageLabel,
      ),
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text,
          const SizedBox(height: 28),
          image,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: reverse ? image : text),
        const SizedBox(width: 72),
        Expanded(child: reverse ? text : image),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            color: _accentColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _primaryTextColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: _secondaryTextColor,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}