import 'package:flutter/material.dart';
import '../../core/api/api_chat_bot.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  /// 🧠 Chat memory
  final List<Map<String, String>> chatMemory = [];

  final List<Map<String, dynamic>> messages = [
    {
      "text": "Hi 👋 I’m your learning assistant.\nAsk me anything!",
      "isUser": false,
    }
  ];

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isLoading) return;

    setState(() {
      isLoading = true;
      messages.add({"text": text, "isUser": true});
    });

    chatMemory.add({"role": "user", "text": text});
    _controller.clear();
    _scrollToBottom();

    setState(() {
      messages.add({"text": "Typing...", "isUser": false});
    });

    final reply = await ApiChatBot.sendMessageWithMemory(
      userMessage: text,
      memory: chatMemory,
    );

    setState(() {
      messages.removeLast();
      messages.add({"text": reply, "isUser": false});
      isLoading = false;
    });

    if (!reply.startsWith("❌") &&
        !reply.startsWith("⚠️") &&
        !reply.startsWith("⏳")) {
      chatMemory.add({"role": "assistant", "text": reply});
    }

    _scrollToBottom();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _chatHeader(theme),

          /// ===== CHAT LIST =====
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _chatBubble(
                  msg["text"],
                  isUser: msg["isUser"],
                  theme: theme,
                );
              },
            ),
          ),

          /// ===== INPUT AREA =====
          /// ===== INPUT AREA =====
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        if (!isDark)
                          const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 1),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => sendMessage(),
                            style: theme.textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: "Ask something...",
                              hintStyle: theme.textTheme.bodySmall,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: isLoading ? null : sendMessage,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: isLoading
                                ? Colors.grey
                                : theme.colorScheme.primary,
                            child: isLoading
                                ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.send,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// ⬇️ Bottom spacing for floating nav
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 110,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _chatHeader(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          if (!isDark)
            const BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
            child: Image.asset(
              'assets/icon/chatbot.png',
              width: 36,
              height: 36,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edu Plex Bot",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontFamily: 'JainiPurva',
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Online • Learning Assistant",
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CHAT BUBBLE =================
  Widget _chatBubble(
      String text, {
        required bool isUser,
        required ThemeData theme,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor:
                theme.colorScheme.primary.withOpacity(0.15),
                child: Image.asset(
                  'assets/icon/chatbot.png',
                  width: 26,
                ),
              ),
            ),
          Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser
                  ? theme.colorScheme.primary
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SelectableText(
              text,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : theme.textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
