import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class _Message {
  final String text;
  final bool isUser;
  final DateTime time;

  _Message({required this.text, required this.isUser, required this.time});
}

class AskAIScreen extends StatefulWidget {
  const AskAIScreen({super.key});

  @override
  State<AskAIScreen> createState() => _AskAIScreenState();
}

class _AskAIScreenState extends State<AskAIScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Message> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    final saved = StorageService.getChatMessages();
    if (saved.isEmpty) {
      _messages.add(_Message(
        text: 'Halo! Saya MoneyTrak AI\n\nSaya bisa bantu analisis keuangan kamu, kasih saran penghematan, atau jawab pertanyaan seputar keuangan pribadi.\n\nApa yang ingin kamu tanyakan?',
        isUser: false,
        time: DateTime.now(),
      ));
    } else {
      for (final m in saved) {
        _messages.add(_Message(
          text: m['text'] as String,
          isUser: m['isUser'] as bool,
          time: DateTime.parse(m['time'] as String),
        ));
      }
    }
  }

  Future<void> _saveMessages() async {
    await StorageService.saveChatMessages(
      _messages.map((m) => {'text': m.text, 'isUser': m.isUser, 'time': m.time.toIso8601String()}).toList(),
    );
  }

  Future<void> _clearChat() async {
    await StorageService.clearChat();
    setState(() {
      _messages.clear();
      _messages.add(_Message(
        text: 'Halo! Saya MoneyTrak AI\n\nSaya bisa bantu analisis keuangan kamu, kasih saran penghematan, atau jawab pertanyaan seputar keuangan pribadi.\n\nApa yang ingin kamu tanyakan?',
        isUser: false,
        time: DateTime.now(),
      ));
    });
    await _saveMessages();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    _controller.clear();
    setState(() {
      _messages.add(_Message(text: text, isUser: true, time: DateTime.now()));
      _loading = true;
    });
    _scrollToBottom();

    final now = DateTime.now();
    final txs = StorageService.getTransactionsByMonth(now.year, now.month);
    final reply = await GeminiService.chatWithAI(text, txs);

    setState(() {
      _messages.add(_Message(text: reply, isUser: false, time: DateTime.now()));
      _loading = false;
    });
    _scrollToBottom();
    await _saveMessages();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('TANYA AI'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
            tooltip: 'Hapus chat',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Hapus semua chat?', style: TextStyle(color: AppColors.textPrimary)),
                content: const Text('Riwayat percakapan akan dihapus permanen.', style: TextStyle(color: AppColors.textMuted)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
                    onPressed: () {
                      Navigator.pop(context);
                      _clearChat();
                    },
                    child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) return _buildTypingIndicator();
                return _buildMessage(_messages[i]);
              },
            ),
          ),
          _buildQuickSuggestions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessage(_Message msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 18),
          ),
          border: msg.isUser
              ? null
              : Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 200),
            const SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = [
      'Analisis pengeluaranku',
      'Tips hemat bulan ini',
      'Kategori terbesar?',
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () {
            _controller.text = suggestions[i];
            _send();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Text(
              suggestions[i],
              style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tanya sesuatu tentang keuanganmu...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                ),
                filled: true,
                fillColor: AppColors.card,
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, Color(0xFF9B59B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: _loading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOut,
    ));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
