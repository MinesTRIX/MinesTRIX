import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix/utils/minestrix/minestrix_client_extension.dart';
import 'package:minestrix_chat/minestrix_chat.dart';
import 'package:minestrix_chat/partials/components/fake_text_field.dart';
import 'package:minestrix_chat/partials/dialogs/adaptative_dialogs.dart';
import 'package:minestrix_chat/partials/feed/posts/matrix_post_editor.dart';
import 'package:minestrix_chat/partials/matrix/matrix_image_avatar.dart';
import 'package:minestrix_chat/utils/matrix_widget.dart';

import '../../pages/login_page.dart';
import '../../pages/minestrix/friends/research_page.dart';
import '../../pages/minestrix/groups/create_group_page.dart';
import '../../router.gr.dart';
import '../feed/notfication_bell.dart';

enum Selection { createPost, createStory, createGroup }

class NavBarDesktop extends StatelessWidget {
  const NavBarDesktop({Key? key}) : super(key: key);

  void displaySearch(BuildContext context) async =>
      await AdaptativeDialogs.show(
          title: 'Search',
          builder: (context) => const ResearchPage(isPopup: true),
          context: context);

  Future<void> launchCreatePostModal(BuildContext context) async {
    final client = Matrix.of(context).client;
    await AdaptativeDialogs.show(
        context: context,
        title: "Create post",
        builder: (BuildContext context) =>
            PostEditorPage(room: client.minestrixUserRoom));
  }

  Future<void> launchCreateGroupModal(BuildContext context) async {
    AdaptativeDialogs.show(
        context: context, builder: (context) => const CreateGroupPage());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16.0),
                child: Row(
                  children: [
                    Image.asset("assets/icon_512.png",
                        width: 40, height: 40, cacheHeight: 80, cacheWidth: 80),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("MinesTRIX",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (constraints.maxWidth > 1000)
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: FakeTextField(
                    icon: Icons.search,
                    onPressed: () => displaySearch(context),
                    text: "Search feeds and events",
                  ),
                ),
              ),
            ),
          Row(
            children: [
              if (constraints.maxWidth <= 1000)
                IconButton(
                    onPressed: () => displaySearch(context),
                    icon: const Icon(Icons.search)),
              PopupMenuButton<Selection>(
                  icon: const Icon(Icons.edit),
                  onSelected: (Selection selection) async {
                    switch (selection) {
                      case Selection.createPost:
                        await launchCreatePostModal(context);
                        break;
                      case Selection.createStory:
                        await Matrix.of(context)
                            .client
                            .openStoryEditModalOrCreate(context);
                        break;
                      case Selection.createGroup:
                        await launchCreateGroupModal(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: Selection.createPost,
                            child: ListTile(
                                leading: Icon(Icons.post_add),
                                title: Text('Write post'))),
                        const PopupMenuItem(
                            value: Selection.createStory,
                            child: ListTile(
                                leading: Icon(Icons.camera_alt),
                                title: Text('Create a story'))),
                        const PopupMenuItem(
                            value: Selection.createGroup,
                            child: ListTile(
                                leading: Icon(Icons.group_add),
                                title: Text("Add a group")))
                      ]),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: NotificationBell(),
              ),
              const UserIconMenuSelection(),
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

class UserIconMenuSelection extends StatefulWidget {
  const UserIconMenuSelection({super.key});

  @override
  State<UserIconMenuSelection> createState() => _UserIconMenuSelectionState();
}

class _UserIconMenuSelectionState extends State<UserIconMenuSelection> {
  final GlobalKey anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final client = Matrix.of(context).client;
      return IconButton(
        key: anchorKey,
        onPressed: () {
          Navigator.of(context).push(_SearchViewRoute(anchorKey: anchorKey));
        },
        icon: FutureBuilder<Profile>(
            future: client.fetchOwnProfile(),
            builder: (context, snap) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: MatrixImageAvatar(
                  url: snap.data?.avatarUrl,
                  client: client,
                  defaultText: snap.data?.displayName ?? client.userID!,
                ),
              );
            }),
      );
    });
  }
}

class _SearchViewRoute extends PopupRoute<_SearchViewRoute> {
  _SearchViewRoute({
    required this.anchorKey,
  });

  final GlobalKey anchorKey;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  late final SearchViewThemeData viewTheme;
  late final DividerThemeData dividerTheme;
  final RectTween _rectTween = RectTween();

  Rect? getRect() {
    final BuildContext? context = anchorKey.currentContext;
    if (context != null) {
      final RenderBox searchBarBox = context.findRenderObject()! as RenderBox;
      final Size boxSize = searchBarBox.size;
      final NavigatorState navigator = Navigator.of(context);

      final Offset boxLocation = searchBarBox.localToGlobal(
          Offset(0, searchBarBox.size.height),
          ancestor: navigator.context.findRenderObject());
      return boxLocation & boxSize;
    }
    return null;
  }

  @override
  TickerFuture didPush() {
    assert(anchorKey.currentContext != null);
    updateViewConfig(anchorKey.currentContext!);
    updateTweens(anchorKey.currentContext!);
    return super.didPush();
  }

  @override
  bool didPop(_SearchViewRoute? result) {
    assert(anchorKey.currentContext != null);
    updateTweens(anchorKey.currentContext!);
    return super.didPop(result);
  }

  void updateViewConfig(BuildContext context) {
    viewTheme = SearchViewTheme.of(context);
    dividerTheme = DividerTheme.of(context);
  }

  void updateTweens(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final Rect anchorRect = getRect() ?? Rect.zero;
    const BoxConstraints effectiveConstraints =
        BoxConstraints(minWidth: 360.0, minHeight: 240.0, maxHeight: 450);
    _rectTween.begin = anchorRect;

    final double viewWidth = clampDouble(anchorRect.width,
        effectiveConstraints.minWidth, effectiveConstraints.maxWidth);
    final double viewHeight = clampDouble(screenSize.height * 2 / 3,
        effectiveConstraints.minHeight, effectiveConstraints.maxHeight);

    final double viewLeftToScreenRight = screenSize.width - anchorRect.left;
    final double viewTopToScreenBottom = screenSize.height - anchorRect.top;

    // Make sure the search view doesn't go off the screen. If the search view
    // doesn't fit, move the top-left corner of the view to fit the window.
    // If the window is smaller than the view, then we resize the view to fit the window.
    Offset topLeft = anchorRect.topLeft;
    if (viewLeftToScreenRight < viewWidth) {
      topLeft = Offset(
          screenSize.width - math.min(viewWidth, screenSize.width), topLeft.dy);
    }
    if (viewTopToScreenBottom < viewHeight) {
      topLeft = Offset(topLeft.dx,
          screenSize.height - math.min(viewHeight, screenSize.height));
    }
    final Size endSize = Size(viewWidth, viewHeight);
    _rectTween.end = (topLeft & endSize);
    return;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final Animation<double> curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubicEmphasized,
              reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
            );

            final Rect viewRect = _rectTween.evaluate(curvedAnimation)!;

            return _ViewContent(
              rect: viewRect,
            );
          }),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);
}

class _ViewContent extends StatefulWidget {
  const _ViewContent({required this.rect});
  final Rect rect;
  @override
  State<_ViewContent> createState() => __ViewContentState();
}

class __ViewContentState extends State<_ViewContent> {
  @override
  Widget build(BuildContext context) {
    final rect = widget.rect;

    final m = Matrix.of(context);

    return Align(
        alignment: Alignment.topLeft,
        child: Transform.translate(
            offset: rect.topLeft,
            child: SizedBox(
              width: rect.width,
              height: rect.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          title: const Text("Choose an account"),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              Card(
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      for (final c in m.widget.clients)
                                        ListTile(
                                            title: Text(c.clientName),
                                            leading: FutureBuilder<Profile>(
                                                future: c.fetchOwnProfile(),
                                                builder: (context, snap) {
                                                  return MatrixImageAvatar(
                                                    url: snap.data?.avatarUrl,
                                                    client: c,
                                                    defaultText:
                                                        snap.data?.displayName,
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                  );
                                                }),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(c.userID ?? ''),
                                              ],
                                            ),
                                            onTap: () async {
                                              m.setActiveClient(c);
                                              Navigator.of(context).pop();
                                            }),
                                      ListTile(
                                          title: const Text("Add an account"),
                                          trailing: const Icon(Icons.add),
                                          onTap: () async {
                                            await AdaptativeDialogs.show(
                                                context: context,
                                                bottomSheet: true,
                                                builder: (context) =>
                                                    const LoginPage(
                                                        popOnLogin: true,
                                                        title:
                                                            "Add a new account"));
                                            if (mounted) {
                                              setState(() {});
                                            }
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text("Settings"),
                            onTap: () async {
                              context.popRoute();
                              context.pushRoute(const SettingsRoute());
                            }),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }
}
