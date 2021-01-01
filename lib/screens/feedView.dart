import 'package:flutter/material.dart';
import 'package:minestrix/components/pageTitle.dart';
import 'package:minestrix/components/postView.dart';
import 'package:minestrix/global/smatrix.dart';

class FeedView extends StatelessWidget {
  const FeedView({
    Key key,
    @required this.sclient,
  }) : super(key: key);

  final SClient sclient;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff4f3f4),
      child: Flexible(
        child: StreamBuilder(
          stream: sclient.onTimelineUpdate.stream,
          builder: (context, _) => ListView.builder(
              itemCount: sclient.stimeline.length + 1,
              itemBuilder: (BuildContext context, int i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text("Feed",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(0),
                        child: Post(event: sclient.stimeline[i - 1]),
                      )),
                );
              }),
        ),
      ),
    );
  }
}
