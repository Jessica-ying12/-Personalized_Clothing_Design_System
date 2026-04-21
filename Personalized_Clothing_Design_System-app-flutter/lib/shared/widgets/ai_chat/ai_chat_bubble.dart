import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/providers/service_providers.dart';

// ── 消息模型 ──────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isLoading;
  _ChatMessage({required this.text, required this.isUser, this.isLoading = false});
}

// ── 悬浮球入口 ────────────────────────────────────────────────────
class AiChatBubble extends ConsumerStatefulWidget {
  const AiChatBubble({super.key});

  @override
  ConsumerState<AiChatBubble> createState() => _AiChatBubbleState();
}

class _AiChatBubbleState extends ConsumerState<AiChatBubble>
    with SingleTickerProviderStateMixin {
  // 悬浮球位置
  double _x = 0;
  double _y = 0;
  bool _initialized = false;

  // 动画（点击时的弹跳）
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _initPosition(Size size) {
    if (!_initialized) {
      _x = size.width - 72;
      _y = size.height * 0.6;
      _initialized = true;
    }
  }

  void _onTap() async {
    await _bounceCtrl.forward();
    await _bounceCtrl.reverse();
    if (!mounted) return;
    _showChatSheet();
  }

  void _showChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: const _ChatSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _initPosition(size);

    return Positioned(
      left: _x,
      top: _y,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _x = (_x + details.delta.dx).clamp(0, size.width - 56);
            _y = (_y + details.delta.dy).clamp(0, size.height - 56);
          });
        },
        onTap: _onTap,
        child: ScaleTransition(
          scale: _bounceAnim,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6A9BFA), Color(0xFFCB8DEA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6A9BFA).withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

// ── 对话面板 ──────────────────────────────────────────────────────
class _ChatSheet extends ConsumerStatefulWidget {
  const _ChatSheet();

  @override
  ConsumerState<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends ConsumerState<_ChatSheet> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // 欢迎语
    _messages.add(_ChatMessage(
      text: '你好！我是服装顾问小裁 👗\n有什么关于服装、穿搭、面料的问题都可以问我～',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(_ChatMessage(text: '', isUser: false, isLoading: true));
      _sending = true;
    });
    _scrollToBottom();

    try {
      final reply = await ref.read(chatServiceProvider).ask(text);
      setState(() {
        _messages.removeLast(); // 移除 loading
        _messages.add(_ChatMessage(text: reply, isUser: false));
        _sending = false;
      });
    } catch (_) {
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMessage(text: '网络出错了，请稍后再试 😅', isUser: false));
        _sending = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72 + bottom,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖拽把手 + 标题
          _buildHeader(),
          // 消息列表
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessage(_messages[i]),
            ),
          ),
          // 输入框
          _buildInput(bottom),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF6A9BFA), Color(0xFFCB8DEA)],
                ),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text('小裁 · 服装顾问',
                style: AppTextStyles.titleMd.copyWith(color: AppColors.grey800)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.grey400),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }

  Widget _buildMessage(_ChatMessage msg) {
    if (msg.isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, right: 60),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
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

    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          msg.text,
          style: AppTextStyles.bodyMd.copyWith(
            color: isUser ? Colors.white : AppColors.grey800,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInput(double bottomInset) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: '问问小裁关于服装的问题...',
                hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.grey400),
                filled: true,
                fillColor: AppColors.grey50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _sending ? AppColors.grey200 : AppColors.primary,
              ),
              child: Icon(
                Icons.send_rounded,
                color: _sending ? AppColors.grey400 : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 打字动画点 ────────────────────────────────────────────────────
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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6, height: 6,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.grey400,
        ),
      ),
    );
  }
}
