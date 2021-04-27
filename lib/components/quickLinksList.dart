import 'package:famedlysdk/famedlysdk.dart';
import 'package:flutter/material.dart';
import 'package:minestrix/global/helpers/NavigationHelper.dart';
import 'package:minestrix/global/smatrix/SMatrixRoom.dart';
import 'package:minestrix/global/smatrixWidget.dart';
import 'package:minestrix/global/smatrix.dart';

class QuickLinksBar extends StatefulWidget {
  @override
  _QuickLinksBarState createState() => _QuickLinksBarState();
}

class _QuickLinksBarState extends State<QuickLinksBar>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final sclient = Matrix.of(context).sclient;

    List<SMatrixRoom> srooms = sclient.sgroups.values.toList();
    return StreamBuilder(
        stream: sclient.onSync.stream,
        builder: (context, _) => ListView.builder(
            itemCount: srooms.length,
            itemBuilder: (BuildContext context, int i) =>
                SRoomView(sroom: srooms[i])));
  }
}

class SRoomView extends StatelessWidget {
  const SRoomView({
    Key key,
    @required this.sroom,
  }) : super(key: key);
  final SMatrixRoom sroom;
  @override
  Widget build(BuildContext context) {
    final SClient client = Matrix.of(context).sclient;
    if (sroom != null)
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ]),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
              padding: EdgeInsets.all(26.0),
            ),
            onPressed: () {
              NavigationHelper.navigateToGroup(context, sroom.room.id);
            },
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
                                  sroom.room.avatar
                                      .getThumbnail(
                                        client,
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
    return Text("ERROR !");
  }
}
