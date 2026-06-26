import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _name = '';
  bool _notificationsEnabled = true;
  bool _pinEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final name = await SettingsService.getName();
    final notif = await SettingsService.getNotifications();
    final pin = await SettingsService.isPinEnabled();
    setState(() {
      _name = name;
      _notificationsEnabled = notif;
      _pinEnabled = pin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('PENGATURAN'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 16),
          _buildSectionLabel('Preferensi'),
          const SizedBox(height: 10),
          _buildToggleTile(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            value: _notificationsEnabled,
            onChanged: (v) async {
              await SettingsService.setNotifications(v);
              setState(() => _notificationsEnabled = v);
            },
          ),
          const SizedBox(height: 10),
          _buildActionTile(
            icon: Icons.lock_outline_rounded,
            title: 'Keamanan / Kata Sandi',
            subtitle: _pinEnabled ? 'PIN aktif' : 'PIN belum diatur',
            onTap: _showPinDialog,
          ),
          const SizedBox(height: 16),
          _buildSectionLabel('Akun'),
          const SizedBox(height: 10),
          _buildActionTile(
            icon: Icons.logout_rounded,
            title: 'Logout / Reset Sesi',
            subtitle: 'Hapus semua data dan atur ulang',
            onTap: _showLogoutDialog,
            isDestructive: true,
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'MoneyTrak v1.0.0',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                _name.isNotEmpty ? _name[0].toUpperCase() : 'W',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Text('Pengguna MoneyTrak', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showEditNameDialog,
            child: const Icon(Icons.edit_outlined, color: AppColors.textMuted, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.expense : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.expense.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDestructive ? AppColors.expense.withValues(alpha: 0.3) : AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: isDestructive ? AppColors.expense : AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog() {
    final ctrl = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ubah Nama Profil', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Masukkan nama kamu'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty) {
                await SettingsService.setName(newName);
                setState(() => _name = newName);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showPinDialog() {
    if (_pinEnabled) {
      _showDisablePinConfirm();
    } else {
      _showSetPinDialog();
    }
  }

  void _showSetPinDialog() {
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Buat PIN Baru', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Masukkan PIN 4 digit untuk mengamankan aplikasi',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary, letterSpacing: 8, fontSize: 20),
              decoration: const InputDecoration(
                hintText: '••••',
                labelText: 'PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(color: AppColors.textPrimary, letterSpacing: 8, fontSize: 20),
              decoration: const InputDecoration(
                hintText: '••••',
                labelText: 'Konfirmasi PIN',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final pin = pinCtrl.text.trim();
              final confirm = confirmCtrl.text.trim();
              if (pin.length != 4) {
                _showSnack('PIN harus 4 digit', AppColors.expense);
                return;
              }
              if (pin != confirm) {
                _showSnack('PIN tidak cocok', AppColors.expense);
                return;
              }
              await SettingsService.setPin(pin);
              setState(() => _pinEnabled = true);
              if (ctx.mounted) Navigator.pop(ctx);
              _showSnack('PIN berhasil diaktifkan', AppColors.primary);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDisablePinConfirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nonaktifkan PIN?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'PIN keamanan akan dinonaktifkan.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () async {
              await SettingsService.disablePin();
              setState(() => _pinEnabled = false);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Nonaktifkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Sesi?', style: TextStyle(color: AppColors.expense)),
        content: const Text(
          'Semua transaksi dan pengaturan akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () async {
              await SettingsService.resetAll();
              await StorageService.init();
              if (mounted) {
                Navigator.pop(context);
                _showSnack('Sesi berhasil direset', AppColors.primary);
                _loadSettings();
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

