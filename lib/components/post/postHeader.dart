import 'package:famedlysdk/famedlysdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:minestrix/components/minesTrix/MinesTrixUserImage.dart';
import 'package:minestrix/global/helpers/NavigationHelper.dart';
import 'package:minestrix/global/smatrix.dart';
import 'package:minestrix/global/smatrix/SMatrixRoom.dart';
import 'package:minestrix/global/smatrixWidget.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostHeader extends StatelessWidget {
  final Event event;
  const PostHeader({Key key, this.event}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final SClient sclient = Matrix.of(context).sclient;
    SMatrixRoom sroom = sclient.srooms[event.roomId];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: MinesTrixUserImage(
                    url: event.sender.avatarUrl,
                    width: 48,
                    height: 48,
                    thumnail: true,
                    defaultIcon: Icon(Icons.person, size: 48)),
              ),
              SizedBox(width: 10),
              if (sroom.roomType == SRoomType.UserRoom)
                Flexible(
                  child: FutureBuilder<Profile>(
                      future: sclient.getUserFromRoom(event.room),
                      builder:
                          (BuildContext context, AsyncSnapshot<Profile> p) {
                        if (p.hasData) {
                          User u = User(
                            p.data.userId,
                            displayName: p.data.displayname,
                            avatarUrl: p.data.avatarUrl.toString(),
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      NavigationHelper.navigateToUserFeed(
                                          context, event.sender);
                                    },
                                    child: Text(event.sender.displayName,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  if (event.sender.id != p.data.userId)
                                    Flexible(
                                      child: Row(children: [
                                        Text("to",
                                            style: TextStyle(
                                                color: Colors.grey[600])),
                                        Flexible(
                                          child: TextButton(
                                            onPressed: () {
                                              NavigationHelper
                                                  .navigateToUserFeed(
                                                      context, u);
                                            },
                                            child: Text(p.data.displayname,
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          ),
                                        ),
                                      ]),
                                    ),
                                ],
                              ),
                              Text(timeago.format(event.originServerTs),
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey[600])),
                            ],
                          );
                        }
                        return Text(event.sender.displayName,
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
                        TextButton(
                          onPressed: () {
                            NavigationHelper.navigateToUserFeed(
                                context, event.sender);
                          },
                          child: Text(event.sender.displayName,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Text("to", style: TextStyle(color: Colors.grey[600])),
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              NavigationHelper.navigateToGroup(
                                  context, event.roomId);
                            },
                            child: Text(sroom.name,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400)),
                          ),
                        ),
                      ],
                    ),
                    Text(timeago.format(event.originServerTs),
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[600])),
                  ],
                )),
            ],
          ),
        ),
        if (event.canRedact)
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
                          if (event.canRedact)
                            PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 10),
                                    Text("Edit post"),
                                  ],
                                ),
                                value: "edit"),
                          if (event.canRedact)
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
                    child: Icon(Icons.more_horiz),
                    onSelected: (String action) async {
                      switch (action) {
                        case "delete":
                          await event.redactEvent();
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
