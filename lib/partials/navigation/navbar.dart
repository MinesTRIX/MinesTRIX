import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:minestrix/partials/feed/notfication_bell.dart';
import 'package:minestrix/router.gr.dart';
import 'package:minestrix_chat/partials/components/fake_text_field.dart';
import 'package:minestrix_chat/partials/dialogs/adaptative_dialogs.dart';
import 'package:minestrix_chat/utils/matrix_widget.dart';

import '../../pages/minestrix/friends/research_page.dart';
import '../../utils/settings.dart';

class NavBarDesktop extends StatelessWidget {
  const NavBarDesktop({Key? key}) : super(key: key);

  void displaySearch(BuildContext context) async =>
      await AdaptativeDialogs.show(
          title: 'Search',
          builder: (context) => const ResearchPage(isPopup: true),
          context: context);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Image.asset("assets/icon_512.png",
                                  width: 40,
                                  height: 40,
                                  cacheHeight: 80,
                                  cacheWidth: 80),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text("MinesTRIX",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () async {
                          await context.navigateTo(const AppWrapperRoute());
                          await context.navigateTo(const FeedRoute());
                        }),
                    NavBarButton(
                        name: "My account",
                        icon: Icons.person,
                        onPressed: () async {
                          await context.navigateTo(const AppWrapperRoute());
                          await context.navigateTo(UserViewRoute(
                              userID: Matrix.of(context).client.userID));
                        }),
                    NavBarButton(
                        name: "Chats",
                        icon: Icons.chat,
                        onPressed: () async {
                          await context
                              .navigateTo(const RoomListWrapperRoute());
                        }),
                    NavBarButton(
                        name: "Events",
                        icon: Icons.event,
                        onPressed: () async {
                          await context
                              .navigateTo(const CalendarEventListRoute());
                        }),
                    NavBarButton(
                        name: "Communities",
                        icon: Icons.group,
                        onPressed: () async {
                          await context.navigateTo(const AppWrapperRoute());
                          await context.navigateTo(const CommunityRoute());
                        }),
                  ],
                ),
              ),
              constraints.maxWidth > 1000
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: FakeTextField(
                        icon: Icons.search,
                        onPressed: () => displaySearch(context),
                        text: "Search",
                      ),
                    )
                  : NavBarButton(
                      name: "Search",
                      icon: Icons.search,
                      onPressed: () => displaySearch(context)),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: NotificationBell(),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class NavBarButton extends StatelessWidget {
  const NavBarButton({Key? key, this.name, this.icon, required this.onPressed})
      : super(key: key);
  final String? name;
  final IconData? icon;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed as void Function()?,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 26),
            if (name != null) const SizedBox(width: 6),
            if (name != null)
              Text(name!,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}