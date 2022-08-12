// @CupertinoAutoRouter
// @AdaptiveAutoRouter
// @CustomAutoRouter

import 'package:auto_route/auto_route.dart';
import 'package:minestrix/pages/chat/room_list_wrapper.dart';
import 'package:minestrix_chat/partials/feed/posts/matrix_post_editor.dart';
import 'package:minestrix_chat/view/room_list/room_list_room.dart';
import 'package:minestrix_chat/view/room_list/room_list_space.dart';
import 'package:minestrix_chat/view/room_page.dart';

import 'pages/account/accountsDetailsPage.dart';
import 'pages/app_wrapper_page.dart';
import 'pages/calendar_events/calendar_event_page.dart';
import 'pages/chat/room_list_page.dart';
import 'pages/debug_page.dart';
import 'pages/login_page.dart';
import 'pages/matrix_loading_page.dart';
import 'pages/calendar_events/calendar_events_list_page.dart';
import 'pages/minestrix/feed_page.dart';
import 'pages/minestrix/friends/research_page.dart';
import 'pages/minestrix/groups/create_group_page.dart';
import 'pages/minestrix/groups/group_page.dart';
import 'pages/minestrix/image/post_gallery_page.dart';
import 'pages/minestrix/user/friends_page.dart';
import 'pages/minestrix/user/user_friends_page.dart';
import 'pages/minestrix/user/user_view_page.dart';
import 'pages/settings/settings_labs_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/settings/settings_profile_page.dart';
import 'pages/settings/settings_security_page.dart';
import 'pages/settings/settings_sync_page.dart';
import 'pages/settings/settings_theme_page.dart';

const chatsWrapper = AutoRoute(
    path: 'rooms',
    page: RoomListWrapper,
    name: 'RoomListWrapperRoute',
    children: [
      AutoRoute(path: '', page: RoomListPage, initial: true),
      AutoRoute(path: 'space', name: 'RoomListSpaceRoute', page: RoomListSpace),
      AutoRoute(path: ':roomId', name: 'RoomListRoomRoute', page: RoomListRoom),
    ]);

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: MatrixLoadingPage),

// this app wrapper add the top navigation bar for desktop
// we want to have the top navigation bar on the chat page when on desktop but not the bottom one on small screen
// as it's distracting when typing messages
    AutoRoute(path: '/', page: AppWrapperPage, children: [
      AutoRoute(path: 'feed', page: FeedPage, initial: true),
      AutoRoute(path: 'group', page: GroupPage),
      AutoRoute(path: 'group/create', page: CreateGroupPage),
      AutoRoute(path: 'createPost', page: PostEditorPage),
      AutoRoute(path: 'userfeed', page: UserViewPage),
      AutoRoute(path: 'my_friends', page: FriendsPage),
      AutoRoute(path: 'user_friends', page: UserFriendsPage),
      AutoRoute(path: 'calendar_events/item', page: CalendarEventPage),
      AutoRoute(path: 'post/image_gallery', page: PostGalleryPage),
      AutoRoute(path: 'calendar_events/list', page: CalendarEventListPage),
      AutoRoute(path: 'search', page: ResearchPage),
      AutoRoute(path: 'accounts', page: AccountsDetailsPage),
      AutoRoute(path: 'settings', page: SettingsPage, children: [
        AutoRoute(
            path: 'settings/home', page: SettingsPanelInnerPage, initial: true),
        AutoRoute(path: 'settings/account', page: SettingsAccountPage),
        AutoRoute(path: 'settings/theme', page: SettingsThemePage),
        AutoRoute(path: 'settings/security', page: SettingsSecurityPage),
        AutoRoute(path: 'settings/labs', page: SettingsLabsPage),
        AutoRoute(path: 'settings/sync', page: SettingsSyncPage),
        AutoRoute(path: 'accounts', page: AccountsDetailsPage),
        AutoRoute(path: 'settings/debug', page: DebugPage)
      ]),

      // chats
      AutoRoute(path: ':roomId', page: RoomPage),
      chatsWrapper,
      AutoRoute(path: 'login', page: LoginPage),
      RedirectRoute(path: '*', redirectTo: 'feed')
    ]),

    AutoRoute(path: 'login', page: LoginPage)
  ],
)
class $AppRouter {}
