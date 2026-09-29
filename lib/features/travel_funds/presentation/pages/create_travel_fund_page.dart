import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/travel_fund_provider.dart';
import '../widgets/travel_fund_invite_dialog.dart';

class CreateTravelFundPage extends StatefulWidget {
  const CreateTravelFundPage({super.key});

  @override
  State<CreateTravelFundPage> createState() => _CreateTravelFundPageState();
}

class _CreateTravelFundPageState extends State<CreateTravelFundPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _currency = 'PHP';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TravelFundProvider>();
    final publicId = await provider.createTravelFund(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      baseCurrency: _currency,
    );
    if (!mounted) return;
    if (publicId != null) {
      final inviteCode = await provider.getTravelFundInviteCode(
        publicId: publicId,
      );
      if (!mounted) return;
      if (inviteCode != null) {
        await showTravelFundInviteDialog(
          context: context,
          inviteCode: inviteCode,
          title: 'Travel fund created',
        );
      } else {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Travel fund created'),
            content: const Text(
              'The invite code could not be retrieved. You can get it later '
              'from the fund ledger.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create travel fund')),
      body: Consumer<TravelFundProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Start a new shared travel fund.',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Fund name',
                    hintText: 'Boracay Trip 2027',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Fund name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Description is required'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _currency,
                  decoration: const InputDecoration(
                    labelText: 'Base currency',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'PHP', child: Text('PHP')),
                  ],
                  onChanged: provider.isActionLoading
                      ? null
                      : (value) => setState(() => _currency = value ?? 'PHP'),
                ),
                if (provider.actionErrorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    provider.actionErrorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: provider.isActionLoading ? null : _submit,
                  icon: provider.isActionLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(provider.isActionLoading ? 'Creating...' : 'Create fund'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
