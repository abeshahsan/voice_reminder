import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/blocs/nlu/nlu_bloc.dart';
import 'package:voice_reminder/blocs/stt/stt_bloc.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  late TextEditingController _textController;
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assistant,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Voice Assistant',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Type or speak your task below',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: BlocListener<NLUBloc, NLUState>(
              listener: (context, nluState) {
                // Print Rasa response when received
                if (nluState is NLUReceivedResponse) {
                  print('=== RASA RESPONSE ===');
                  print(nluState.response);
                  print('====================');

                  // Add bot response to chat
                  setState(() {
                    _messages.add(
                      ChatMessage(
                        text: 'lol',
                        isUser: false,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                  _scrollToBottom();
                } else if (nluState is NLUError) {
                  print('=== RASA ERROR ===');
                  print(nluState.error);
                  print('==================');

                  // Add error message to chat
                  setState(() {
                    _messages.add(
                      ChatMessage(
                        text: 'lol',
                        isUser: false,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                  _scrollToBottom();
                } else if (nluState is NLULoading) {
                  print('=== SENDING TO RASA ===');
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: BlocListener<STTBloc, STTState>(
                      listener: (context, state) {
                        // Auto-send to NLU when STT is done and has text
                        if (state is STTAutoSendToNLU) {
                          // Add user message to chat
                          setState(() {
                            _messages.add(
                              ChatMessage(
                                text: state.message,
                                isUser: true,
                                timestamp: DateTime.now(),
                              ),
                            );
                          });
                          _scrollToBottom();

                          context.read<NLUBloc>().add(
                            NLUSendMessageEvent(state.message),
                          );
                          // Clear the recognized text after sending
                          context.read<STTBloc>().recognizedText = '';
                          _textController.clear();
                        }
                      },
                      child: BlocBuilder<STTBloc, STTState>(
                        builder: (context, state) {
                          // Initialize controller with current STT text if it's different
                          final currentSttText = context
                              .read<STTBloc>()
                              .recognizedText;
                          if (_textController.text != currentSttText &&
                              currentSttText.isNotEmpty) {
                            _textController.text = currentSttText;
                            _textController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(offset: currentSttText.length),
                                );
                          }

                          return TextField(
                            controller: _textController,
                            onChanged: (value) {
                              context.read<STTBloc>().recognizedText = value;
                            },
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Type or speak your message...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14.0,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<NLUBloc, NLUState>(
                    builder: (context, nluState) {
                      bool isProcessing = nluState is NLULoading;
                      return BlocBuilder<STTBloc, STTState>(
                        builder: (context, state) {
                          bool isMicOn = context.read<STTBloc>().isMicOn;
                          return FloatingActionButton(
                            heroTag: 'mic',
                            mini: true,
                            backgroundColor: isProcessing
                                ? Colors.grey.shade400
                                : (isMicOn
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.red),
                            foregroundColor: Colors.white,
                            onPressed: isProcessing
                                ? null
                                : () {
                                    if (!isMicOn) {
                                      context.read<STTBloc>().add(
                                        STTListenEvent(),
                                      );
                                    } else {
                                      context.read<STTBloc>().add(
                                        STTStopListeningEvent(),
                                      );
                                    }
                                  },
                            child: Icon(isMicOn ? Icons.mic : Icons.mic_off),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<NLUBloc, NLUState>(
                    builder: (context, nluState) {
                      bool isProcessing = nluState is NLULoading;
                      return FloatingActionButton(
                        heroTag: 'send',
                        mini: true,
                        backgroundColor: isProcessing
                            ? Colors.grey.shade400
                            : Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        onPressed: isProcessing
                            ? null
                            : () {
                                final textToSend = _textController.text.trim();
                                if (textToSend.isNotEmpty) {
                                  // Add user message to chat
                                  setState(() {
                                    _messages.add(
                                      ChatMessage(
                                        text: textToSend,
                                        isUser: true,
                                        timestamp: DateTime.now(),
                                      ),
                                    );
                                  });
                                  _scrollToBottom();

                                  context.read<NLUBloc>().add(
                                    NLUSendMessageEvent(textToSend),
                                  );
                                  // Clear the text after sending
                                  context.read<STTBloc>().recognizedText = '';
                                  _textController.clear();
                                }
                              },
                        child: isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.send),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.assistant, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width *
                  0.55, // Limit width to 60% of screen
              minWidth: 0,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: message.isUser
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: message.isUser
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: message.isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              softWrap: true,
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.grey, size: 16),
            ),
          ],
        ],
      ),
    );
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
}
