import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:matrix/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:minestrix/router.gr.dart';
import 'package:minestrix/utils/matrixWidget.dart';
import 'package:minestrix/utils/minestrix/minestrixClient.dart';
import 'package:minestrix/utils/minestrix/minestrixRoom.dart';
import 'package:minestrix_chat/partials/matrix_user_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostHeader extends StatelessWidget {
  final Event? event;
  const PostHeader({Key? key, this.event}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final MinestrixClient sclient = Matrix.of(context).sclient!;
    MinestrixRoom sroom = sclient.srooms[event!.roomId!]!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: MatrixUserImage(
                    client: sclient,
                    url: event!.sender.avatarUrl,
                    width: 48,
                    height: 48,
                    thumnail: true,
                    defaultIcon: Icon(Icons.person, size: 48)),
              ),
              SizedBox(width: 10),
              if (sroom.roomType == SRoomType.UserRoom)
                Flexible(
                  child: Builder(builder: (BuildContext context) {
                    User? p = sclient.srooms[event!.room]?.user;
                    if (p != null) {
                      User user = User(p.id,
                          displayName: p.displayName,
                          avatarUrl: p.avatarUrl.toString(),
                          room: event!.room);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                    primary: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color),
                                onPressed: () {
                                  context.pushRoute(
                                      UserFeedRoute(userId: event!.senderId));
                                },
                                child: Text(
                                    (event!.sender.displayName ??
                                        event!.sender.id),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                              if (event!.sender.id != p.id)
                                Text("to",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color)),
                              if (event!.sender.id != p.id)
                                TextButton(
                                  style: TextButton.styleFrom(
                                      primary: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color),
                                  onPressed: () {
                                    context.pushRoute(
                                        UserFeedRoute(userId: user.id));
                                  },
                                  child: Text((p.displayName ?? p.id),
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400)),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(timeago.format(event!.originServerTs),
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .color)),
                          ),
                        ],
                      );
                    }
                    return Text((event!.sender.displayName ?? event!.sender.id),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold));
                  }),
                ),
              if (sroom.roomType == SRoomType.Group)
                Flexible(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              context.pushRoute(
                                  UserFeedRoute(userId: event!.senderId));
                            },
                            child: Text(
                                (event!.sender.displayName ?? event!.sender.id),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Text("to",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color)),
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              MinestrixRoom? sroom =
                                  sclient.srooms[event!.roomId];
                              if (sroom != null)
                                context.pushRoute(GroupRoute(sroom: sroom));
                            },
                            child: Text(sroom.name,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ),
                      ],
                    ),
                    Text(timeago.format(event!.originServerTs),
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).textTheme.caption!.color)),
                  ],
                )),
            ],
          ),
        ),
        if (event!.canRedact)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                /*  if (encyrpted)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.enhanced_encryption),
                ),*/
                PopupMenuButton<String>(
                    itemBuilder: (_) => [
                          if (event!.canRedact)
                            PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 10),
                                    Text("Edit post"),
                                  ],
                                ),
                                value: "edit"),
                          if (event!.canRedact)
                            PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text("Delete post",
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                                value: "delete")
                        ],
                    icon: Icon(Icons.more_horiz),
                    onSelected: (String action) async {
                      switch (action) {
                        case "delete":
                          await event!.redactEvent();
                          break;
                        default:
                      }
                    })
              ],
            ),
          )
      ],
    );
  }
}
