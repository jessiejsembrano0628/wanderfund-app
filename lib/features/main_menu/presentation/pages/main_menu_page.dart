import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../travel_funds/data/models/travel_fund_model.dart';
import '../../../travel_funds/presentation/providers/travel_fund_provider.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  bool _redirectingToLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = _userId(context.read<AuthProvider>());
      if (userId != null && userId.isNotEmpty) {
        context.read<TravelFundProvider>().loadFunds(userId: userId);
      }
    });
  }

  String? _userId(AuthProvider authProvider) {
    final detailsUserId = authProvider.userDetails?.userId;
    if (detailsUserId != null && detailsUserId.isNotEmpty) return detailsUserId;
    final restoredUserId = authProvider.user?.id;
    return restoredUserId?.isNotEmpty == true ? restoredUserId : null;
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logoutAndRedirect();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _logoutAndRedirect() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _redirectToLoginIfNeeded(TravelFundProvider provider) {
    if (!provider.isAuthenticationError || _redirectingToLogin) return;
    _redirectingToLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _logoutAndRedirect();
    });
  }

  Future<void> _openCreatePage() async {
    final created = await Navigator.of(
      context,
    ).pushNamed('/create-travel-fund');
    if (created == true && mounted) {
      await _refreshFunds();
      final message = context.read<TravelFundProvider>().actionMessage;
      if (message != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _refreshFunds() async {
    final userId = _userId(context.read<AuthProvider>());
    if (userId != null && userId.isNotEmpty) {
      await context.read<TravelFundProvider>().loadFunds(userId: userId);
    }
  }

  Future<void> _showJoinDialog() async {
    final provider = context.read<TravelFundProvider>();
    final responseMessage = await showDialog<String>(
      context: context,
      builder: (_) => _JoinTravelFundDialog(
        onSubmit: (inviteCode) =>
            provider.joinTravelFund(inviteCode: inviteCode),
      ),
    );
    if (responseMessage != null && mounted) {
      await _refreshFunds();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(responseMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final firstName = authProvider.userDetails?.firstName.trim();
    final restoredName = authProvider.user?.name.trim();
    final userName = firstName?.isNotEmpty == true ? firstName : restoredName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WanderFund'),
        actions: [
          // IconButton(
          //   onPressed: _handleLogout,
          //   tooltip: 'Logout',
          //   icon: const Icon(Icons.logout),
          // ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.of(context).pushNamed('/profile');
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Consumer<TravelFundProvider>(
        builder: (context, provider, _) {
          _redirectToLoginIfNeeded(provider);
          return RefreshIndicator(
            onRefresh: _refreshFunds,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (provider.isLoading) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: constraints.maxHeight,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }
                if (provider.errorMessage != null) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: constraints.maxHeight,
                        child: _MessageState(
                          message: provider.errorMessage!,
                          actionLabel: 'Retry',
                          onAction: _refreshFunds,
                          extraActions: [
                            FilledButton.icon(
                              onPressed: _openCreatePage,
                              icon: const Icon(Icons.add),
                              label: const Text('Create fund'),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _showJoinDialog,
                              icon: const Icon(Icons.group_add),
                              label: const Text('Join fund'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                if (provider.funds.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: constraints.maxHeight,
                        child: _EmptyFundsView(
                          onCreate: _openCreatePage,
                          onJoin: _showJoinDialog,
                        ),
                      ),
                    ],
                  );
                }

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  children: [
                    Text(
                      'Welcome, ${userName?.isNotEmpty == true ? userName : 'there'}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose a travel fund to view its ledger.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _openCreatePage,
                            icon: const Icon(Icons.add),
                            label: const Text('Create fund'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showJoinDialog,
                            icon: const Icon(Icons.group_add),
                            label: const Text('Join fund'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...provider.funds.map(
                      (fund) => _TravelFundCard(
                        fund: fund,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed('/ledger', arguments: fund.publicId),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _JoinTravelFundDialog extends StatefulWidget {
  final Future<String?> Function(String inviteCode) onSubmit;

  const _JoinTravelFundDialog({required this.onSubmit});

  @override
  State<_JoinTravelFundDialog> createState() => _JoinTravelFundDialogState();
}

class _JoinTravelFundDialogState extends State<_JoinTravelFundDialog> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  String? _validationError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final inviteCode = _controller.text.trim();
    if (inviteCode.isEmpty) {
      setState(() => _validationError = 'Invite code is required');
      return;
    }

    setState(() => _isSubmitting = true);
    final responseMessage = await widget.onSubmit(inviteCode);
    if (!mounted) return;
    Navigator.of(context).pop(responseMessage);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join travel fund'),
      content: TextField(
        controller: _controller,
        enabled: !_isSubmitting,
        onChanged: (_) {
          if (_validationError != null) {
            setState(() => _validationError = null);
          }
        },
        decoration: InputDecoration(
          labelText: 'Invite code',
          hintText: 'Paste the invite UUID',
          border: const OutlineInputBorder(),
          errorText: _validationError,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: Text(_isSubmitting ? 'Joining...' : 'Join'),
        ),
      ],
    );
  }
}

class _TravelFundCard extends StatelessWidget {
  final TravelFund fund;
  final VoidCallback onTap;

  const _TravelFundCard({required this.fund, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = fund.status.toUpperCase() == 'ACTIVE';
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund.travelFundName.isEmpty
                          ? "Travel Fund"
                          : fund.travelFundName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Role: ${fund.role.isEmpty ? 'Member' : fund.role}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isActive ? Colors.green : Colors.orange)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        fund.status.isEmpty ? 'UNKNOWN' : fund.status,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isActive
                              ? Colors.green.shade700
                              : Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFundsView extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const _EmptyFundsView({required this.onCreate, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You are not a member of any travel fund yet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create fund'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onJoin,
              icon: const Icon(Icons.group_add),
              label: const Text('Join fund'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Widget>? extraActions;

  const _MessageState({
    required this.message,
    this.actionLabel,
    this.onAction,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
            if (extraActions != null) ...[
              const SizedBox(height: 10),
              ...extraActions!,
            ],
          ],
        ),
      ),
    );
  }
}
