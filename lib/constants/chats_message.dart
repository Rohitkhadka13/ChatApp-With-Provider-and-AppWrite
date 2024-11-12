import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/constants/date_formatter.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:flutter/material.dart';

class ChatsMessage extends StatefulWidget {
  final MessageModel msg;
  final String currentUser;
  final bool isImage;
  const ChatsMessage({
    super.key,
    required this.msg,
    required this.currentUser,
    required this.isImage,
  });

  @override
  State<ChatsMessage> createState() => _ChatsMessageState();
}

class _ChatsMessageState extends State<ChatsMessage> {
  @override
  Widget build(BuildContext context) {
    return widget.isImage
        ? Container(
            child: Row(
              mainAxisAlignment: widget.msg.sender == widget.currentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: widget.msg.sender == widget.currentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://cloud.appwrite.io/v1/storage/buckets/672b869d003847f5570b/files/${widget.msg.message}/view?project=672ae4ec00014c5b3400&mode=admin",
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            formatDate(widget.msg.timeStamp),
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline),
                          ),
                        ),
                        widget.msg.sender == widget.currentUser
                            ? widget.msg.isSeenByReceiver
                                ? Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: kPrimaryColor,
                                  )
                                : Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: Colors.grey,
                                  )
                            : SizedBox()
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.all(4),
            margin: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: widget.msg.sender == widget.currentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: widget.msg.sender == widget.currentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.msg.sender == widget.currentUser
                                ? kPrimaryColor
                                : kSecondaryColor,
                            borderRadius: BorderRadius.only(
                                bottomLeft:
                                    widget.msg.sender == widget.currentUser
                                        ? const Radius.circular(20)
                                        : const Radius.circular(2),
                                bottomRight:
                                    widget.msg.sender == widget.currentUser
                                        ? const Radius.circular(2)
                                        : const Radius.circular(20),
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20)),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Text(
                            widget.msg.message,
                            style: TextStyle(
                              color: widget.msg.sender == widget.currentUser
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                            formatDate(widget.msg.timeStamp),
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline),
                          ),
                        ),
                        widget.msg.sender == widget.currentUser
                            ? widget.msg.isSeenByReceiver
                                ? Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: kPrimaryColor,
                                  )
                                : Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: Colors.grey,
                                  )
                            : SizedBox()
                      ],
                    )
                  ],
                )
              ],
            ),
          );
  }
}
