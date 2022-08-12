import 'package:flutter/material.dart';
import 'package:minestrix/partials/components/layouts/customHeader.dart';

import '../../utils/settings.dart';

class SettingsLabsPage extends StatefulWidget {
  const SettingsLabsPage({Key? key}) : super(key: key);

  @override
  State<SettingsLabsPage> createState() => _SettingsLabsPageState();
}

class _SettingsLabsPageState extends State<SettingsLabsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          CustomHeader(title: "Labs"),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Experimental features, use with caution!"),
          ),
          SwitchListTile(
              value: Settings().multipleFeedSupport,
              onChanged: (value) {
                Settings().multipleFeedSupport = value;
                setState(() {});
              },
              secondary: Icon(Icons.people),
              title: Text("Allow creating multiple feeds"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Want to share post with a subset of you friends ? Then multiple feed support is the solution."),
                  InfoBadge(text: "WIP"),
                  InfoBadge(color: Colors.blue, text: "UI")
                ],
              )),
          SizedBox(height: 8),
          SwitchListTile(
              value: Settings().calendarEventSupport,
              onChanged: (value) {
                Settings().calendarEventSupport = value;
                setState(() {});
              },
              secondary: Icon(Icons.calendar_today),
              title: Text("Enable calendar event support"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Allow creating calendar events."),
                  InfoBadge(
                    text: "WIP",
                  ),
                  InfoBadge(
                    text: "Read only",
                  )
                ],
              )),
          SizedBox(height: 8),
          SwitchListTile(
              value: Settings().optimizedFeed,
              onChanged: (value) {
                Settings().optimizedFeed = value;
                setState(() {});
              },
              secondary: Icon(Icons.list),
              title: Text("Optimized feed"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Restart to reload the feed correctly"),
                  InfoBadge(text: "WIP"),
                  InfoBadge(text: "Need restart", color: Colors.orange),
                ],
              ))
        ],
      ),
    );
  }
}

class InfoBadge extends StatelessWidget {
  const InfoBadge({Key? key, required this.text, this.color: Colors.red})
      : super(key: key);

  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}