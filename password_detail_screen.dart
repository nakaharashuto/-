// ファイルパス: lib/screens/password_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/password_entry.dart';
import '../providers/password_provider.dart';
import '../providers/master_pin_provider.dart';

class PasswordDetailScreen extends ConsumerStatefulWidget {
  final PasswordEntry entry;

  const PasswordDetailScreen({super.key, required this.entry});

  @override
  ConsumerState<PasswordDetailScreen> createState() => _PasswordDetailScreenState();
}

class _PasswordDetailScreenState extends ConsumerState<PasswordDetailScreen> {
  bool _isPasswordVisible = false;

  void _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$labelをコピーしました')),
    );
  }

  Future<void> _confirmDelete(PasswordEntry entry) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('${entry.serviceName} の情報を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(passwordListProvider.notifier).deletePassword(entry.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('削除しました')));
      Navigator.of(context).pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.entry;

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.serviceName),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(entry),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailItem(theme, Icons.title, 'サービス名', entry.serviceName),
            _buildDetailItem(theme, Icons.person, 'ユーザー名', entry.username),
            _buildPasswordItem(theme),
            _buildDetailItem(theme, Icons.link, 'URL', entry.url),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(ThemeData theme, IconData icon, String title, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(value.isEmpty ? '未設定' : value),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _copyToClipboard(value, title),
        ),
      ),
    );
  }

  Widget _buildPasswordItem(ThemeData theme) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.lock, color: theme.colorScheme.primary),
        title: const Text('パスワード'),
        subtitle: Text(_isPasswordVisible ? widget.entry.encryptedPassword : '••••••••'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyToClipboard(widget.entry.encryptedPassword, 'パスワード'),
            ),
          ],
        ),
      ),
    );
  }
}

// 詳細画面への遷移前の認証で使うため、ここに配置
class PinReAuthDialog extends ConsumerStatefulWidget {
  const PinReAuthDialog({super.key});
  @override
  ConsumerState<PinReAuthDialog> createState() => _PinReAuthDialogState();
}

class _PinReAuthDialogState extends ConsumerState<PinReAuthDialog> {
  final _controller = TextEditingController();
  String? _error;

  void _verify() {
    final masterPinValue = ref.read(masterPinProvider).value;
    if (masterPinValue != null && masterPinValue.masterPin == _controller.text) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _error = 'PINが正しくありません';
        _controller.clear();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('認証'),
      content: TextField(
        controller: _controller,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 4,
        autofocus: true,
        decoration: InputDecoration(errorText: _error, counterText: ''),
        onSubmitted: (_) => _verify(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('キャンセル')),
        ElevatedButton(onPressed: _verify, child: const Text('確認')),
      ],
    );
  }
}
