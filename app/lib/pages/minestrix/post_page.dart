import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix/partials/post/post/post_item.dart';
import 'package:minestrix_chat/minestrix_chat.dart';
import 'package:minestrix_chat/partials/chat/message_composer/matrix_message_composer.dart';

import '../../partials/post/details/post_replies.dart';

@RoutePage()
class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.event, required this.timeline});
  final Event event;
  final Timeline timeline;
  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  Future<String?> overrideTextSending(String text, {Event? replyTo}) async {
    return await widget.event.room
        .commentPost(content: text, post: widget.event, replyTo: replyTo);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.event.room.onUpdate.stream,
        builder: (context, snapshot) {
          final replies = widget.event.getReplies(widget.timeline);
          return Scaffold(
              appBar: AppBar(
                title: const Text("Post"),
              ),
              body: ListView(
                children: [
                  PostItem(
                    event: widget.event,
                    timeline: widget.timeline,
                    onReact: (Offset) {},
                    isMobile: false,
                  ),
                  const Divider(),
                  MatrixMessageComposer(
                    client: widget.event.room.client,
                    room: widget.event.room,
                    enableAutoFocusOnDesktop: false,
                    hintText: "Reply",
                    loadSavedText: false,
                    allowSendingPictures: false,
                    overrideSending: (String text) =>
                        overrideTextSending(text, replyTo: widget.event),
                  ),
                  const Divider(),
                  if (replies != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PostReplies(
                          timeline: widget.timeline,
                          event: widget.event,
                          replies: replies),
                    ),
                ],
              ));
        });
  }
}
