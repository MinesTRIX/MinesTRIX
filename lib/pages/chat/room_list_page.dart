import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:minestrix_chat/view/room_list/room_list_builder.dart';
import 'package:provider/provider.dart';

import '../../partials/minestrix_title.dart';
import '../../router.gr.dart';
import 'room_list_wrapper.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({Key? key, this.isMobile = false}) : super(key: key);
  final bool isMobile;
  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, _) {
      final state = Provider.of<RoomListWrapperState>(context, listen: false);
      if (state.mobile)
        return RoomListBuilder(
          mobile: true,
          scrollController: scrollController,
          appBarColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(180),
          onAppBarClicked: () => context.navigateTo(SettingsRoute()),
        );

      return Center(child: MinestrixTitle());
    });
  }
}
