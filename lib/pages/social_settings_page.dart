import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix/chat/minestrix_chat.dart';

import '../partials/calendar_events/calendar_event_create_widget.dart';
import '../partials/components/layouts/custom_header.dart';
import '../partials/editors/sections.dart';
import 'settings/settings_feeds_page.dart';

@RoutePage()
class SocialSettingsPage extends StatefulWidget {
  const SocialSettingsPage({super.key, required this.room});

  final Room room;

  @override
  State<SocialSettingsPage> createState() => _SocialSettingsPageState();
}

class _SocialSettingsPageState extends State<SocialSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return StreamBuilder<Object>(
        stream: room.onUpdate.stream,
        builder: (context, snapshot) {
          return ListView(children: [
            CustomHeader(title: "${room.getLocalizedDisplayname()} settings"),
            Wrap(
              alignment: WrapAlignment.start,
              children: [
                if (room.feedType == FeedRoomType.calendar)
                  SizedBox(
                      width: 500,
                      child: Card(child: EditCalendarRoom(room: room))),
                if (room.feedType == FeedRoomType.calendar)
                  const SizedBox(
                    width: 12,
                  ),
                if (room.isProfileRoom)
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 800,
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProfileSpaceCard(
                          profile: room,
                        ),
                      ),
                    ),
                  ),
                ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Card(child: EditorSectionInfo(room: room))),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      Card(child: EditorSectionPermission(room: room)),
                      Card(child: EditorSectionJoinRules(room: room)),
                      Card(child: EditorSectionOtherSettings(room: room)),
                    ],
                  ),
                ),
              ],
            )
          ]);
        });
  }
}
