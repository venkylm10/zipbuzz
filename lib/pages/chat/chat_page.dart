import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:zipbuzz/controllers/profile/user_controller.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/models/events/message_model.dart';
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
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  var bufferChats = <Message>[];
  int? maxLines;
  final _defaultColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  Map<int, MaterialColor> senderColors = {};

  void scrollToBottom() async {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void sendMessage() async {
    if (messageController.text.trim().isNotEmpty) {
      await ref.read(chatServicesProvider).sendMessage(
            eventId: widget.event.id,
            message: messageController.text.trim(),
          );
      messageController.clear();
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
      updateMaxLines(messageController.text);
    }
  }

  void updateMaxLines(String value) {
    if (value.length < 200) {
      maxLines = null;
    } else {
      maxLines = 5;
    }
    setState(() {});
  }

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
          elevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16).copyWith(top: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildChat(),
              buildSendTextField(),
            ],
          ),
        ),
      ),
    );
  }

  MaterialColor getSenderColor(int senderId) {
    if (senderColors.containsKey(senderId)) {
      return senderColors[senderId]!;
    }
    int rand = Random().nextInt(_defaultColors.length);
    senderColors[senderId] = _defaultColors[rand];
    return senderColors[senderId]!;
  }

  StreamBuilder<List<Message>> buildChat() {
    return StreamBuilder(
      stream: ref.watch(chatServicesProvider).getMessages(eventId: widget.event.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong: ${snapshot.error}'));
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
                bool showProfilePic = true;
                bool showDate = true;
                if (index != messages.length - 1) {
                  showProfilePic = messages[index + 1].senderId != messages[index].senderId;
                  showDate = messages[index].timeStamp.substring(0, 10) !=
                      messages[index + 1].timeStamp.substring(0, 10);
                }
                return buildMessage(messages[index], showProfilePic, showDate);
              },
            ),
          );
        }
        return buildBufferChat();
      },
    );
  }

  String getTimeFromDateTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  Widget buildDate(String dateTime) {
    final date = DateTime.parse(dateTime).toLocal();
    DateFormat('EEEE (d MMM)').format(date);
    final weeekDay = DateFormat('EEEE').format(date);
    final messageDate = DateFormat('d MMM').format(date);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          weeekDay,
          style: AppStyles.h6.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "($messageDate)",
          style: AppStyles.h6.copyWith(
            color: AppColors.lightGreyColor,
          ),
        ),
      ],
    );
  }

  Expanded buildBufferChat() {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: bufferChats.length,
        reverse: true,
        itemBuilder: (context, index) {
          bool showProfilePic = true;
          bool showDate = true;
          if (index != bufferChats.length - 1) {
            showProfilePic = bufferChats[index + 1].senderId != bufferChats[index].senderId;
            showDate = bufferChats[index].timeStamp.substring(0, 10) !=
                bufferChats[index + 1].timeStamp.substring(0, 10);
          }
          return buildMessage(bufferChats[index], showProfilePic, showDate);
        },
      ),
    );
  }

  Widget buildMessage(Message messageModel, bool showInfo, bool showDate) {
    final userId = ref.read(userProvider).id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showDate) const SizedBox(height: 16),
        if (showDate) buildDate(messageModel.timeStamp),
        if (showDate) const SizedBox(height: 16),
        userId == messageModel.senderId
            ? buildCurrentUserMessage(messageModel, showInfo)
            : buildOthersMessage(messageModel, showInfo)
      ],
    );
  }

  Widget buildCurrentUserMessage(Message messageModel, bool showInfo) {
    double borderRadius = 8;
    final dateTime = DateTime.parse(messageModel.timeStamp).toLocal();
    final time = getTimeFromDateTime(dateTime);

    return Container(
      width: MediaQuery.of(context).size.width - 40,
      margin: EdgeInsets.only(bottom: 8, top: showInfo ? 8 : 0),
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
                  if (showInfo)
                    Text(
                      messageModel.senderName,
                      style: AppStyles.h6.copyWith(
                        fontWeight: FontWeight.w500,
                        color: getSenderColor(messageModel.senderId),
                      ),
                    ),
                  if (showInfo) const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(time, style: AppStyles.h6.copyWith(fontSize: 8)),
                      const SizedBox(width: 4),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65,
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
              buildSenderImage(showInfo, messageModel),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOthersMessage(Message messageModel, bool showInfo) {
    double borderRadius = 8;
    final dateTime = DateTime.parse(messageModel.timeStamp).toLocal();
    final time = getTimeFromDateTime(dateTime);
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      margin: EdgeInsets.only(bottom: 8, top: showInfo ? 8 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              buildSenderImage(showInfo, messageModel),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showInfo)
                    Text(
                      messageModel.senderName,
                      style: AppStyles.h6.copyWith(
                        fontWeight: FontWeight.w500,
                        color: getSenderColor(messageModel.senderId),
                      ),
                    ),
                  if (showInfo) const SizedBox(height: 4),
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

  ClipRRect buildSenderImage(bool showInfo, Message messageModel) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: showInfo
          ? Image.network(
              messageModel.senderPic,
              height: 32,
              width: 32,
              fit: BoxFit.cover,
            )
          : const SizedBox(height: 32, width: 32),
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
                padding: EdgeInsets.only(right: 16, bottom: maxLines == null ? 8 : 16),
                child: SvgPicture.asset(
                  Assets.icons.send_fill,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                      messageController.text.trim().isEmpty
                          ? Colors.grey.shade600
                          : AppColors.primaryColor,
                      BlendMode.srcIn),
                ),
              ),
            ),
            maxLines: maxLines,
            borderRadius: maxLines != null ? 10 : 40,
            crossAxisAlignment: CrossAxisAlignment.end,
            onChanged: updateMaxLines,
          ),
        ),
        const SizedBox(width: 8),
        SvgPicture.asset(
          Assets.icons.add_circle,
          height: 40,
          colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
        ),
      ],
    );
  }
}
