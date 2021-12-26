import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:flutter/material.dart';
import 'package:matrix/src/utils/uri_extension.dart';
import 'package:minestrix/router.gr.dart';
import 'package:minestrix/utils/matrixWidget.dart';
import 'package:minestrix/utils/minestrix/minestrixClient.dart';
import 'package:minestrix/utils/minestrix/minestrixRoom.dart';

class QuickLinksBar extends StatefulWidget {
  @override
  _QuickLinksBarState createState() => _QuickLinksBarState();
}

class _QuickLinksBarState extends State<QuickLinksBar>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final MinestrixClient sclient = Matrix.of(context).sclient!;

    List<MinestrixRoom> srooms = sclient.sgroups.values.toList();
    return StreamBuilder(
        stream: sclient.onSync.stream,
        builder: (context, _) => ListView.builder(
            itemCount: srooms.length,
            itemBuilder: (BuildContext context, int i) => Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SRoomView(sroom: srooms[i]),
                )));
  }
}

class SRoomView extends StatelessWidget {
  const SRoomView({
    Key? key,
    required this.sroom,
  }) : super(key: key);
  final MinestrixRoom sroom;
  @override
  Widget build(BuildContext context) {
    final MinestrixClient? client = Matrix.of(context).sclient;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        onPressed: () {
          context.navigateTo(GroupRoute(sroom: sroom));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      sroom.room.avatar == null
                          ? Icon(Icons.group, color: Colors.black)
                          : CircleAvatar(
                              backgroundImage: NetworkImage(
                                sroom.room.avatar!
                                    .getThumbnail(
                                      client!,
                                      width: 64,
                                      height: 64,
                                    )
                                    .toString(),
                              ),
                            ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(sroom.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                Text(
                                  sroom.room.topic,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black),
                                )
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
                if (sroom.room.encrypted)
                  Icon(Icons.verified_user, color: Colors.black),
                if (!sroom.room.encrypted)
                  Icon(Icons.no_encryption, color: Colors.black)
              ]),
        ),
      ),
    );
  }
}
