import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../travel_funds/presentation/providers/travel_fund_provider.dart';
import '../../../travel_funds/presentation/widgets/travel_fund_invite_dialog.dart';
import '../providers/ledger_provider.dart';
import '../../data/models/ledger_model.dart';

class LedgerPage extends StatefulWidget {
  final String publicId;

  const LedgerPage({super.key, required this.publicId});

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  bool _redirectingToLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LedgerProvider>().loadLedger(publicId: widget.publicId);
    });
  }

  void _redirectToLoginIfNeeded(LedgerProvider provider) {
    if (!provider.isAuthenticationError || _redirectingToLogin) return;
    _redirectingToLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _logoutAndRedirect();
    });
  }

  Future<void> _logoutAndRedirect() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _openMembersDialog() async {
    final provider = context.read<LedgerProvider>();
    await provider.loadMembers(publicId: widget.publicId);
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final currentEmail = authProvider.userDetails?.email.trim() ?? '';
    final currentID = authProvider.userDetails?.userId.trim() ?? '';
    final members = provider.members;

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Members'),
          content: SizedBox(
            width: double.maxFinite,
            child: members.isEmpty
                ? const Text('No members found.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: members.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isCurrentUser = (member.id == currentID);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Expanded(child: Text(member.name)),
                            if (isCurrentUser)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  '(You)',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: member.role.isNotEmpty
                            ? Text(member.role)
                            : null,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openInviteCodeDialog() async {
    final provider = context.read<TravelFundProvider>();
    final inviteCode = await provider.getTravelFundInviteCode(
      publicId: widget.publicId,
    );
    if (!mounted) return;
    if (inviteCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.actionErrorMessage ?? 'Unable to get the invite code.',
          ),
        ),
      );
      return;
    }
    await showTravelFundInviteDialog(
      context: context,
      inviteCode: inviteCode,
      title: 'Travel fund invite code',
    );
  }

  Future<void> _openJoinRequestsPage() async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => JoinRequestsPage(publicId: widget.publicId),
      ),
    );
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openCreateTransactionPage({
    required bool canCreateTransactions,
  }) async {
    if (!canCreateTransactions) return;
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => CreateTransactionPage(
          publicId: widget.publicId,
          canCreateTransactions: canCreateTransactions,
        ),
      ),
    );
    if (!mounted || message == null) return;
    await context.read<LedgerProvider>().loadLedger(publicId: widget.publicId);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openTransactionApprovalPage({required bool canManageRequests}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionApprovalPage(
          publicId: widget.publicId,
          canManageRequests: canManageRequests,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final travelFunds = context.watch<TravelFundProvider>().funds;
    final canManageRequests = travelFunds.any(
      (fund) =>
          fund.publicId == widget.publicId &&
          fund.role.trim().toLowerCase() == 'main',
    );
    final canCreateTransactions = travelFunds.any(
      (fund) =>
          fund.publicId == widget.publicId &&
          fund.status.trim().toUpperCase() == 'ACTIVE',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Fund Ledger'),
        actions: [
          IconButton(
            onPressed: canCreateTransactions
                ? () => _openCreateTransactionPage(
                    canCreateTransactions: canCreateTransactions,
                  )
                : null,
            icon: const Icon(Icons.add_card_outlined),
            tooltip: canCreateTransactions
                ? 'Create transaction'
                : 'Transactions are disabled for inactive funds',
          ),
          IconButton(
            onPressed: () => _openTransactionApprovalPage(
              canManageRequests: canManageRequests,
            ),
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: 'Transaction approvals',
          ),
          if (canManageRequests)
            IconButton(
              onPressed: _openJoinRequestsPage,
              icon: const Icon(Icons.person_add_alt_1),
              tooltip: 'Join requests',
            ),
          TextButton.icon(
            onPressed: _openMembersDialog,
            icon: const Icon(Icons.people_outline),
            label: const Text('Members'),
          ),
          PopupMenuButton<String>(
            tooltip: 'More actions',
            onSelected: (action) {
              if (action == 'invite_code') _openInviteCodeDialog();
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'invite_code',
                child: Row(
                  children: [
                    Icon(Icons.key_outlined),
                    SizedBox(width: 12),
                    Text('Get invite code'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<LedgerProvider>(
        builder: (context, provider, _) {
          _redirectToLoginIfNeeded(provider);
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return _MessageState(
              message: provider.errorMessage!,
              actionLabel: 'Retry',
              onAction: () => provider.loadLedger(publicId: widget.publicId),
            );
          }
          final ledger = provider.ledger;
          if (ledger == null) {
            return const _MessageState(message: 'No ledger data available.');
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadLedger(publicId: widget.publicId),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _BalanceCard(balance: ledger.runningBalance),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction history',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (ledger.transactions.isEmpty)
                  const _MessageState(message: 'No transactions yet.')
                else
                  ...ledger.transactions.map(
                    (transaction) => _TransactionCard(transaction: transaction),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CreateTransactionPage extends StatefulWidget {
  final String publicId;
  final bool canCreateTransactions;

  const CreateTransactionPage({
    super.key,
    required this.publicId,
    this.canCreateTransactions = false,
  });

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'PHP');
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  String _action = 'IN';
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!widget.canCreateTransactions || _submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final message = await context.read<LedgerProvider>().createTransaction(
      publicId: widget.publicId,
      action: _action,
      amount: double.parse(_amountController.text.trim()),
      currency: _currencyController.text.trim().toUpperCase(),
      description: _descriptionController.text.trim(),
      referenceId: _referenceController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (message == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to submit transaction request.')),
      );
      return;
    }
    Navigator.of(context).pop(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create transaction')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (!widget.canCreateTransactions) ...[
                Text(
                  'Transactions are disabled for inactive funds.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                initialValue: _action,
                decoration: const InputDecoration(
                  labelText: 'Transaction type',
                ),
                items: const [
                  DropdownMenuItem(value: 'IN', child: Text('Cash in')),
                  DropdownMenuItem(value: 'OUT', child: Text('Cash out')),
                  DropdownMenuItem(
                    value: 'REIMBURSEMENT',
                    child: Text('Reimbursement request'),
                  ),
                ],
                onChanged: _submitting || !widget.canCreateTransactions
                    ? null
                    : (value) {
                        if (value != null) setState(() => _action = value);
                      },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                enabled: widget.canCreateTransactions && !_submitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount <= 0)
                    return 'Enter an amount greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currencyController,
                enabled: widget.canCreateTransactions && !_submitting,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Currency'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a currency code'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                enabled: widget.canCreateTransactions && !_submitting,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceController,
                enabled: widget.canCreateTransactions && !_submitting,
                decoration: const InputDecoration(labelText: 'Reference ID'),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submitting || !widget.canCreateTransactions
                    ? null
                    : _submit,
                icon: _submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_submitting ? 'Submitting' : 'Submit request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionApprovalPage extends StatefulWidget {
  final String publicId;
  final bool canManageRequests;

  const TransactionApprovalPage({
    super.key,
    required this.publicId,
    this.canManageRequests = false,
  });

  @override
  State<TransactionApprovalPage> createState() =>
      _TransactionApprovalPageState();
}

class _TransactionApprovalPageState extends State<TransactionApprovalPage> {
  static const _statuses = ['REQUESTED', 'APPROVED', 'REJECTED'];

  String _selectedStatus = 'REQUESTED';
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final error = await context
        .read<LedgerProvider>()
        .loadTransactionApprovalRequests(
          publicId: widget.publicId,
          status: _selectedStatus,
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _errorMessage = error;
    });
  }

  Future<void> _openDetails(TransactionEntry request) async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => TransactionRequestDetailsPage(
          publicId: widget.publicId,
          request: request,
          canManageRequests: widget.canManageRequests,
        ),
      ),
    );
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction approvals')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: _statuses
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (status) {
                if (status == null) return;
                setState(() => _selectedStatus = status);
                _loadRequests();
              },
            ),
          ),
          Expanded(
            child: Consumer<LedgerProvider>(
              builder: (context, provider, _) {
                if (_loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_errorMessage != null) {
                  return _MessageState(
                    message: _errorMessage!,
                    actionLabel: 'Retry',
                    onAction: _loadRequests,
                  );
                }
                final requests = provider.transactionApprovalRequests;
                if (requests.isEmpty) {
                  return const _MessageState(
                    message: 'No transaction requests to review.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final amountColor = request.amount >= 0
                          ? Colors.green.shade700
                          : Colors.red.shade700;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      request.description.isEmpty
                                          ? 'Transaction request'
                                          : request.description,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  Text(
                                    _formatMoney(request.amount),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: amountColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                'Transaction ID: ${request.id.isEmpty ? 'Unavailable' : request.id}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Requested by ${request.initiatedBy.isEmpty ? 'Unknown' : request.initiatedBy}',
                              ),
                              if (request.createdAt != null)
                                Text(_formatDateTime(request.createdAt!)),
                              if (request.referenceId.isNotEmpty)
                                Text('Reference: ${request.referenceId}'),
                              if (request.status.toUpperCase() == 'REJECTED' &&
                                  request.rejectReason.trim().isNotEmpty)
                                Text('Reject reason: ${request.rejectReason}'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Chip(label: Text(request.status)),
                                  const Spacer(),
                                  FilledButton.tonalIcon(
                                    onPressed: () => _openDetails(request),
                                    icon: const Icon(Icons.visibility_outlined),
                                    label: const Text('View details'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionRequestDetailsPage extends StatefulWidget {
  final String publicId;
  final TransactionEntry request;
  final bool canManageRequests;

  const TransactionRequestDetailsPage({
    super.key,
    required this.publicId,
    required this.request,
    this.canManageRequests = false,
  });

  @override
  State<TransactionRequestDetailsPage> createState() =>
      _TransactionRequestDetailsPageState();
}

class _TransactionRequestDetailsPageState
    extends State<TransactionRequestDetailsPage> {
  bool _processing = false;

  Future<String?> _askRejectionReason() async {
    return showDialog<String>(
      context: context,
      builder: (_) => const _RejectTransactionDialog(),
    );
  }

  Future<void> _submitDecision(String status, {String reason = ''}) async {
    final request = widget.request;
    if (request.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction ID is unavailable.')),
      );
      return;
    }
    setState(() => _processing = true);
    final message = await context
        .read<LedgerProvider>()
        .updateTransactionApproval(
          publicId: widget.publicId,
          transactionId: request.id,
          status: status,
          reason: reason,
        );
    if (!mounted) return;
    setState(() => _processing = false);
    if (message == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update transaction request.')),
      );
      return;
    }
    Navigator.of(context).pop(message);
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value.isEmpty ? 'Not provided' : value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final isRequested = request.status.toUpperCase() == 'REQUESTED';
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            request.description.isEmpty
                ? 'Transaction request'
                : request.description,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _formatMoney(request.amount),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: request.amount < 0
                  ? Colors.red.shade700
                  : Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          _detailRow(context, 'Transaction ID', request.id),
          const Divider(height: 1),
          _detailRow(context, 'Reference ID', request.referenceId),
          const Divider(height: 1),
          _detailRow(context, 'Description', request.description),
          const Divider(height: 1),
          _detailRow(
            context,
            'Created',
            request.createdAt == null
                ? ''
                : _formatDateTime(request.createdAt!),
          ),
          const Divider(height: 1),
          _detailRow(context, 'Amount', _formatMoney(request.amount)),
          const Divider(height: 1),
          _detailRow(context, 'Initiated by', request.initiatedBy),
          const Divider(height: 1),
          _detailRow(context, 'Status', request.status),
          if (request.status.toUpperCase() == 'REJECTED' &&
              request.rejectReason.trim().isNotEmpty) ...[
            const Divider(height: 1),
            _detailRow(context, 'Reject reason', request.rejectReason),
          ],
          if (isRequested && request.id.isEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Approval is unavailable because this response has no transaction ID.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: isRequested && widget.canManageRequests
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _processing || request.id.isEmpty
                          ? null
                          : () async {
                              final reason = await _askRejectionReason();
                              if (reason != null && mounted) {
                                await _submitDecision(
                                  'REJECTED',
                                  reason: reason,
                                );
                              }
                            },
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _processing || request.id.isEmpty
                          ? null
                          : () => _submitDecision('APPROVED'),
                      icon: _processing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _RejectTransactionDialog extends StatefulWidget {
  const _RejectTransactionDialog();

  @override
  State<_RejectTransactionDialog> createState() =>
      _RejectTransactionDialogState();
}

class _RejectTransactionDialogState extends State<_RejectTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  String _reason = '';

  void _reject() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_reason.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject transaction'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          autofocus: true,
          maxLines: 3,
          onChanged: (value) => _reason = value,
          decoration: const InputDecoration(labelText: 'Reason for rejection'),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter a rejection reason'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _reject, child: const Text('Reject request')),
      ],
    );
  }
}

class JoinRequestsPage extends StatefulWidget {
  final String publicId;

  const JoinRequestsPage({super.key, required this.publicId});

  @override
  State<JoinRequestsPage> createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends State<JoinRequestsPage> {
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final provider = context.read<LedgerProvider>();
    await provider.loadJoinRequests(publicId: widget.publicId);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _updateRequest(JoinRequest request, String status) async {
    final success = await context.read<LedgerProvider>().updateJoinRequest(
      publicId: widget.publicId,
      requestId: request.id,
      status: status,
    );
    if (!mounted) return;
    if (!success) {
      setState(() => _errorMessage = 'Unable to update this join request.');
      return;
    }

    final action = status.toUpperCase() == 'APPROVED' ? 'approved' : 'rejected';
    Navigator.of(context).pop('Join request $action.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Requests')),
      body: Consumer<LedgerProvider>(
        builder: (context, provider, _) {
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_errorMessage != null) {
            return _MessageState(
              message: _errorMessage!,
              actionLabel: 'Retry',
              onAction: _loadRequests,
            );
          }
          final requests = provider.joinRequests;
          if (requests.isEmpty) {
            return const _MessageState(message: 'No join requests found.');
          }

          return RefreshIndicator(
            onRefresh: _loadRequests,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: requests.map((request) {
                        final isRequested =
                            request.status.toUpperCase() == 'REQUESTED';
                        return DataRow(
                          cells: [
                            DataCell(Text(request.name)),
                            DataCell(
                              Text(request.email.isEmpty ? '-' : request.email),
                            ),
                            DataCell(Text(request.status)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: isRequested
                                        ? () => _updateRequest(
                                            request,
                                            'APPROVED',
                                          )
                                        : null,
                                    child: const Text('Approve'),
                                  ),
                                  TextButton(
                                    onPressed: isRequested
                                        ? () => _updateRequest(
                                            request,
                                            'REJECTED',
                                          )
                                        : null,
                                    child: const Text('Reject'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primary,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Running balance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatMoney(balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionEntry transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction.amount >= 0;
    final color = isIncoming ? Colors.green.shade700 : Colors.red.shade700;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          child: Icon(isIncoming ? Icons.south_west : Icons.north_east),
        ),
        title: Text(
          transaction.description.isEmpty
              ? 'Transaction'
              : transaction.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            if (transaction.createdAt != null)
              _formatDateTime(transaction.createdAt!),
            if (transaction.referenceId.isNotEmpty) transaction.referenceId,
            if (transaction.initiatedBy.isNotEmpty)
              'Initiated by ${transaction.initiatedBy}',
            if (transaction.status.isNotEmpty) transaction.status,
          ].join(' • '),
        ),
        trailing: Text(
          '${isIncoming ? '+' : ''}${_formatMoney(transaction.amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({required this.message, this.actionLabel, this.onAction});

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
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = dateTime.hour == 0
      ? 12
      : dateTime.hour > 12
      ? dateTime.hour - 12
      : dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '${months[dateTime.month - 1]} ${dateTime.day}, '
      '${dateTime.year} at $hour:$minute $period';
}

String _formatMoney(double amount) {
  final sign = amount.isNegative ? '-' : '';
  final fixed = amount.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final integerPart = parts[0];
  final grouped = StringBuffer();
  for (var index = 0; index < integerPart.length; index++) {
    if (index > 0 && (integerPart.length - index) % 3 == 0) {
      grouped.write(',');
    }
    grouped.write(integerPart[index]);
  }
  return '${sign}PHP $grouped.${parts[1]}';
}
