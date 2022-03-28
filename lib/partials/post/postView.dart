import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:minestrix_chat/config/matrix_types.dart';
import 'package:minestrix_chat/partials/matrix/reactions_list.dart';

import 'package:minestrix/partials/post/postDetails/postContent.dart';
import 'package:minestrix/partials/post/postDetails/postHeader.dart';
import 'package:minestrix/partials/post/postDetails/postReactions.dart';
import 'package:minestrix/partials/post/postDetails/postReplies.dart';
import 'package:minestrix/utils/matrixWidget.dart';
import 'package:minestrix/utils/minestrix/minestrixClient.dart';

class Post extends StatefulWidget {
  final Event event;
  final void Function(Offset) onReact;
  final Timeline? timeline;
  Post({Key? key, required this.event, required this.onReact, this.timeline})
      : super(key: key);

  @override
  _PostState createState() => _PostState();
}

enum PostTypeUpdate { ProfilePicture, DisplayName, Membership, None }

class _PostState extends State<Post> with SingleTickerProviderStateMixin {
  final key = GlobalKey();
  bool showReplyBox = false;
  bool showReplies = true;

  @override
  Widget build(BuildContext context) {
    Event e = widget.event;
    MinestrixClient sclient = Matrix.of(context).sclient!;

    Timeline? t = sclient.srooms[e.roomId!]?.timeline ?? widget.timeline;
    if (t == null) {
      return CircularProgressIndicator();
    }

    return StreamBuilder<Object>(
        stream: e.room.onUpdate.stream,
        builder: (context, snapshot) {
          // support for threaded replies
          Set<Event> replies =
              e.aggregatedEvents(t, MatrixTypes.elementThreadEventType);

          // TODO: remove me after in next update
          replies.addAll(e.aggregatedEvents(t, RelationshipTypes.reply));

          Set<Event> reactions =
              e.aggregatedEvents(t, RelationshipTypes.reaction);
          return Card(
            key: key,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // post content

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostHeader(event: e),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: PostContent(
                            e,
                            imageMaxHeight: 300,
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (reactions.isNotEmpty)
                                    Flexible(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: MaterialButton(
                                                  child: PostReactions(
                                                      event: e,
                                                      reactions: reactions),
                                                  onPressed: () async {
                                                    await showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            Dialog(
                                                                child:
                                                                    ConstrainedBox(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      maxWidth:
                                                                          600,
                                                                      maxHeight:
                                                                          600),
                                                              child: EventReactionList(
                                                                  reactions:
                                                                      reactions),
                                                            )));
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (replies.isNotEmpty)
                                    MaterialButton(
                                        child: Text(
                                            (showReplies ? "Hide " : "Show ") +
                                                replies.length.toString() +
                                                " comments"),
                                        onPressed: () {
                                          setState(() {
                                            showReplies = !showReplies;
                                          });
                                        }),
                                ],
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: MaterialButton(
                                  elevation: 0,
                                  color: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.insert_emoticon_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                      SizedBox(width: 5),
                                      Text("Reaction",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary))
                                    ],
                                  ),
                                  onPressed: () {}),
                              onTapDown: (TapDownDetails detail) async {
                                widget.onReact(detail.globalPosition);
                              },
                            ),
                            SizedBox(width: 9),
                            MaterialButton(
                              elevation: 0,
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.reply,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                  SizedBox(width: 5),
                                  Text("Comment",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary))
                                ],
                              ),
                              onPressed: replyButtonClick,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  if (replies.isNotEmpty && showReplies || showReplyBox)
                    Divider(),
                  if (showReplies)
                    Container(
                      child: Column(
                        children: [
                          if (replies.isNotEmpty || showReplyBox)
                            RepliesVue(
                                timeline: t,
                                event: e,
                                replies: replies,
                                showEditBox: showReplyBox,
                                setReplyVisibility: (bool value) =>
                                    setState(() {
                                      showReplyBox = value;
                                    })),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }

  void replyButtonClick() {
    setState(() {
      showReplyBox = !showReplyBox;
    });
  }
}
