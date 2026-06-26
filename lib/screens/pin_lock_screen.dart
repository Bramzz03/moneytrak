import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/settings_service.dart';
import '../theme.dart';
import 'main_screen.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> with SingleTickerProviderStateMixin {
  final List<String> _input = [];
  bool _error = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onDigit(String d) {
    if (_input.length >= 4) return;
    setState(() {
      _input.add(d);
      _error = false;
    });
    if (_input.length == 4) _verify();
  }

  void _onDelete() {
    if (_input.isEmpty) return;
    setState(() => _input.removeLast());
  }

  Future<void> _verify() async {
    final savedPin = await SettingsService.getPin();
    final entered = _input.join();

    if (entered == savedPin) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = true;
        _input.clear();
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.cardGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Masukkan PIN',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ? 'PIN salah, coba lagi' : 'Masukkan PIN 4 digit kamu',
                style: TextStyle(
                  color: _error ? AppColors.expense : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 36),
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                    _error ? 10 * (0.5 - _shakeAnim.value).abs() * 2 : 0,
                    0,
                  ),
                  child: child,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _input.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _error
                            ? AppColors.expense
                            : filled
                                ? AppColors.cardGreen
                                : Colors.transparent,
                        border: Border.all(
                          color: _error
                              ? AppColors.expense
                              : filled
                                  ? AppColors.cardGreen
                                  : AppColors.cardBorder,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(flex: 1),
              _buildNumpad(),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        _buildNumRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildNumRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildNumRow(['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            _buildKey('0'),
            Expanded(
              child: GestureDetector(
                onTap: _onDelete,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.backspace_outlined, color: AppColors.textSecondary, size: 22),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumRow(List<String> digits) {
    return Row(
      children: digits.map((d) => _buildKey(d)).toList(),
    );
  }

  Widget _buildKey(String digit) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onDigit(digit),
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder, width: 0.5),
          ),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
