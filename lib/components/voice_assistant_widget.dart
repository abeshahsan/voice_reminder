import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_reminder/blocs/nlu/nlu_bloc.dart';
import 'package:voice_reminder/blocs/stt/stt_bloc.dart';
import 'package:voice_reminder/services/nlu_task_handler.dart';

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

class VoiceAssistantWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool showHeader;

  const VoiceAssistantWidget({
    Key? key,
    this.title = 'Voice Assistant',
    this.subtitle = 'Type or speak to add, edit, or manage your tasks',
    this.showHeader = true,
  }) : super(key: key);

  @override
  State<VoiceAssistantWidget> createState() => _VoiceAssistantWidgetState();
}

class _VoiceAssistantWidgetState extends State<VoiceAssistantWidget> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus when tapping outside the text field
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isVeryCompact = constraints.maxHeight < 150;
          final bool isCompact = constraints.maxHeight < 300;
          final bool shouldShowHeader =
              widget.showHeader && constraints.maxHeight > 120;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                if (shouldShowHeader && !isCompact) _buildHeader(),
                if (shouldShowHeader && isCompact && !isVeryCompact)
                  _buildCompactHeader(),
                Expanded(child: _buildChatArea()),
                _buildInputArea(isVeryCompact),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.assistant,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          BlocBuilder<NLUBloc, NLUState>(
            builder: (context, state) {
              bool isOnline = !(state is NLUError);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isOnline
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: isOnline ? Colors.green : Colors.orange,
                      size: 6,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? 'Online' : 'Local',
                      style: TextStyle(
                        color: isOnline
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.assistant,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          BlocBuilder<NLUBloc, NLUState>(
            builder: (context, state) {
              bool isOnline = !(state is NLUError);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOnline
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: isOnline ? Colors.green : Colors.orange,
                      size: 8,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? 'Online' : 'Local Mode',
                      style: TextStyle(
                        color: isOnline
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxHeight < 100;
        final bool isVeryCompact = constraints.maxHeight < 60;

        return _messages.isEmpty
            ? Container(
                padding: EdgeInsets.all(
                  isVeryCompact ? 4.0 : (isCompact ? 8.0 : 16.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isVeryCompact) ...[
                        Icon(
                          Icons.chat_bubble_outline,
                          size: isCompact ? 24 : 32,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: isCompact ? 4 : 6),
                      ],
                      if (isVeryCompact) ...[
                        Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ] else if (isCompact) ...[
                        Text(
                          'Start chatting',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Start a conversation',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<NLUBloc, NLUState>(
                          builder: (context, state) {
                            if (state is NLUError) {
                              return Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 12,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Local mode',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(
                  isVeryCompact ? 2.0 : (isCompact ? 4.0 : 6.0),
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(
                    message,
                    isCompact || isVeryCompact,
                  );
                },
              );
      },
    );
  }

  Widget _buildInputArea([bool isVeryCompact = false]) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVeryCompact ? 4.0 : 8.0,
        vertical: isVeryCompact ? 4.0 : 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: BlocListener<NLUBloc, NLUState>(
        listener: (context, nluState) async {
          if (nluState is NLUReceivedResponse) {
            print('=== RASA RESPONSE ===');
            print(nluState.response);
            print('====================');

            // Process the NLU response and handle task operations
            final responseMessage = await NLUTaskHandler.processNLUResponse(
              nluState.response,
              context,
            );

            setState(() {
              _messages.add(
                ChatMessage(
                  text: responseMessage,
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

            setState(() {
              _messages.add(
                ChatMessage(
                  text: 'Sorry, I encountered an error. Please try again.',
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              );
            });
            _scrollToBottom();
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: BlocListener<STTBloc, STTState>(
                listener: (context, state) {
                  if (state is STTAutoSendToNLU) {
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
                    context.read<STTBloc>().recognizedText = '';
                    _textController.clear();
                  }
                },
                child: BlocBuilder<STTBloc, STTState>(
                  builder: (context, state) {
                    final currentSttText = context
                        .read<STTBloc>()
                        .recognizedText;
                    if (_textController.text != currentSttText &&
                        currentSttText.isNotEmpty) {
                      _textController.text = currentSttText;
                      _textController.selection = TextSelection.fromPosition(
                        TextPosition(offset: currentSttText.length),
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        // Focus the text field when tapped
                        if (!_focusNode.hasFocus) {
                          _focusNode.requestFocus();
                        }
                      },
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        autofocus: false,
                        onChanged: (value) {
                          context.read<STTBloc>().recognizedText = value;
                        },
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: isVeryCompact
                              ? 'Type message...'
                              : 'Type or speak your message...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isVeryCompact ? 12.0 : 14.0,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isVeryCompact ? 12.0 : 16.0,
                            vertical: isVeryCompact ? 6.0 : 8.0,
                          ),
                          isDense: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: isVeryCompact ? 2 : 4),
            BlocBuilder<NLUBloc, NLUState>(
              builder: (context, nluState) {
                bool isProcessing = nluState is NLULoading;
                return BlocBuilder<STTBloc, STTState>(
                  builder: (context, state) {
                    bool isMicOn = context.read<STTBloc>().isMicOn;
                    final buttonSize = isVeryCompact ? 28.0 : 32.0;
                    final iconSize = isVeryCompact ? 14.0 : 16.0;

                    return SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: FloatingActionButton(
                        heroTag: 'mic_${widget.hashCode}',
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
                                  context.read<STTBloc>().add(STTListenEvent());
                                } else {
                                  context.read<STTBloc>().add(
                                    STTStopListeningEvent(),
                                  );
                                }
                              },
                        child: Icon(
                          isMicOn ? Icons.mic : Icons.mic_off,
                          size: iconSize,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(width: isVeryCompact ? 2 : 4),
            BlocBuilder<NLUBloc, NLUState>(
              builder: (context, nluState) {
                bool isProcessing = nluState is NLULoading;
                final buttonSize = isVeryCompact ? 28.0 : 32.0;
                final iconSize = isVeryCompact ? 14.0 : 16.0;

                return SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: FloatingActionButton(
                    heroTag: 'send_${widget.hashCode}',
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
                              context.read<STTBloc>().recognizedText = '';
                              _textController.clear();
                            }
                          },
                    child: isProcessing
                        ? SizedBox(
                            width: isVeryCompact ? 10 : 12,
                            height: isVeryCompact ? 10 : 12,
                            child: const CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(Icons.send, size: iconSize),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, [bool isCompact = false]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 2.0 : 3.0),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: isCompact ? 8 : 10,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.assistant,
                color: Colors.white,
                size: isCompact ? 10 : 12,
              ),
            ),
            SizedBox(width: isCompact ? 4 : 6),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * (isCompact ? 0.75 : 0.7),
              minWidth: 0,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8.0 : 10.0,
              vertical: isCompact ? 6.0 : 8.0,
            ),
            decoration: BoxDecoration(
              color: message.isUser
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: message.isUser
                    ? const Radius.circular(12)
                    : const Radius.circular(3),
                bottomRight: message.isUser
                    ? const Radius.circular(3)
                    : const Radius.circular(12),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: isCompact ? 12 : 14,
              ),
              softWrap: true,
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: isCompact ? 4 : 6),
            CircleAvatar(
              radius: isCompact ? 8 : 10,
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                color: Colors.grey,
                size: isCompact ? 10 : 12,
              ),
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
