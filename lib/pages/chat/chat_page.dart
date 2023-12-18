import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/controllers/user/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/message_model.dart';
import 'package:zipbuzz/services/chat_services.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/custom_text_field.dart';

class ChatPage extends ConsumerStatefulWidget {
  static const id = '/chat';
  final EventModel event;
  const ChatPage({super.key, required this.event});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late TextEditingController messageController;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    messageController = TextEditingController();
    super.initState();
  }

  void scrollToBottom() async {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void sendMessage() async {
    await ref.read(chatServicesProvider).sendMessage(
          eventId: widget.event.id,
          message: messageController.text.trim(),
        );
    messageController.clear();
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
  }

  void updateMaxLines(String value) {
    if (value.length < 200) {
      maxLines = null;
    } else {
      maxLines = 5;
    }
    setState(() {});
  }

  String getTimeFromDateTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  String formatDateTime(String dateTime) {
    final date = DateTime.parse(dateTime).toLocal();
    return DateFormat('EEEE (d MMM)').format(date);
  }

  var bufferChats = <Message>[];
  int? maxLines;
  String chatDate = '';
  bool firstFetch = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.event.bannerPath,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.event.title,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.h3.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          titleSpacing: -10,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16).copyWith(top: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StreamBuilder(
                stream: ref
                    .watch(chatServicesProvider)
                    .getMessages(eventId: widget.event.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: bufferChats.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return buildMessage(bufferChats[index]);
                        },
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.hasData) {
                    var messages = snapshot.data!;
                    bufferChats = messages;
                    return Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: messages.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return buildMessage(messages[index]);
                        },
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: bufferChats.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return buildMessage(bufferChats[index]);
                      },
                    ),
                  );
                },
              ),
              buildSendTextField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMessage(Message messageModel) {
    final userId = ref.read(userProvider).id;
    return userId == messageModel.senderId
        ? buildCurrentUserMessage(messageModel)
        : buildOthersMessage(messageModel);
  }

  Widget buildCurrentUserMessage(Message messageModel) {
    double borderRadius = 8;
    final dateTime = DateTime.parse(messageModel.timeStamp).toLocal();
    final time = getTimeFromDateTime(dateTime);

    return Container(
      width: MediaQuery.of(context).size.width - 32,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    messageModel.senderName,
                    style: AppStyles.h6.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(time, style: AppStyles.h6.copyWith(fontSize: 8)),
                      const SizedBox(width: 4),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadius),
                            topRight: Radius.circular(borderRadius / 2),
                            bottomLeft: Radius.circular(borderRadius),
                            bottomRight: Radius.circular(borderRadius),
                          ),
                          color: AppColors.calenderBg,
                        ),
                        child: Text(
                          messageModel.message,
                          softWrap: true,
                          style: AppStyles.h5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  messageModel.senderPic,
                  height: 32,
                  width: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOthersMessage(Message messageModel) {
    double borderRadius = 8;
    final dateTime = DateTime.parse(messageModel.timeStamp).toLocal();
    final time = getTimeFromDateTime(dateTime);
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  messageModel.senderPic,
                  height: 32,
                  width: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageModel.senderName,
                    softWrap: true,
                    style: AppStyles.h6.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadius / 2),
                            topRight: Radius.circular(borderRadius),
                            bottomLeft: Radius.circular(borderRadius),
                            bottomRight: Radius.circular(borderRadius),
                          ),
                          color: AppColors.calenderBg,
                        ),
                        child: Text(
                          messageModel.message,
                          softWrap: true,
                          style: AppStyles.h5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(time, style: AppStyles.h6.copyWith(fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row buildSendTextField() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: messageController,
            hintText: "Type a message ..",
            suffixIcon: GestureDetector(
              onTap: () => sendMessage(),
              child: Padding(
                padding: EdgeInsets.only(
                    right: 16, bottom: maxLines == null ? 8 : 16),
                child: SvgPicture.asset(
                  Assets.icons.send_fill,
                  height: 30,
                  colorFilter:
                      ColorFilter.mode(Colors.grey.shade600, BlendMode.srcIn),
                ),
              ),
            ),
            maxLines: maxLines,
            borderRadius: 40,
            crossAxisAlignment: CrossAxisAlignment.end,
            onChanged: updateMaxLines,
          ),
        ),
        const SizedBox(width: 8),
        SvgPicture.asset(
          Assets.icons.add_circle,
          height: 40,
          colorFilter:
              const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
        ),
      ],
    );
  }
}
