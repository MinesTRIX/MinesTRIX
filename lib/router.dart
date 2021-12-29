// @CupertinoAutoRouter
// @AdaptiveAutoRouter
// @CustomAutoRouter
import 'package:auto_route/auto_route.dart';
import 'package:minestrix/components/post/postEditor.dart';
import 'package:minestrix/pages/account/accountsDetailsPage.dart';
import 'package:minestrix/pages/appWrapperPage.dart';
import 'package:minestrix/pages/loginPage.dart';
import 'package:minestrix/pages/matrixLoadingPage.dart';
import 'package:minestrix/pages/minestrix/feedPage.dart';
import 'package:minestrix/pages/minestrix/friends/researchPage.dart';
import 'package:minestrix/pages/minestrix/groups/groupPage.dart';
import 'package:minestrix/pages/minestrix/homeWraperPage.dart';
import 'package:minestrix/pages/minestrix/user/friendsPage.dart';
import 'package:minestrix/pages/minestrix/user/userFriendsPage.dart';
import 'package:minestrix/pages/minestrix/user/userViewPage.dart';
import 'package:minestrix/pages/settingsPage.dart';
import 'package:minestrix_chat/view/matrix_chat_page.dart';
import 'package:minestrix_chat/view/matrix_chats_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: MatrixLoadingPage),

// this app wrapper add the top navigation bar for desktop
// we want to have the top navigation bar on the chat page when on desktop but not the bottom one on small screen
// as it's distracting when typing messages
    AutoRoute(path: '/', page: AppWrapperPage, children: [
      // nested routes defines the bottom navigation bar for mobile
      AutoRoute(
          path: '',
          name: 'MinestrixRouter',
          page: HomeWraperPage,
          children: [
            AutoRoute(path: 'feed', page: FeedPage, initial: true),
            AutoRoute(path: 'group', page: GroupPage),
            AutoRoute(path: 'createPost', page: PostEditorPage),
            AutoRoute(
                path: 'user',
                name: 'UserWrapperRoute',
                page: EmptyRouterPage,
                children: [
                  AutoRoute(path: 'feed', page: UserViewPage, initial: true),
                  AutoRoute(path: 'my_friends', page: FriendsPage),
                  AutoRoute(path: 'user_friends', page: UserFriendsPage),
                  RedirectRoute(path: '*', redirectTo: 'feed')
                ]),
            AutoRoute(path: 'search', page: ResearchPage),
            AutoRoute(path: 'accounts', page: AccountsDetailsPage),
            AutoRoute(path: 'settings', page: SettingsPage),
            RedirectRoute(path: '*', redirectTo: 'feed')
          ]),
      AutoRoute(
        path: 'chats',
        page: MatrixChatsPage,
      ),
      AutoRoute(
          path: 'chatsW',
          name: 'ChatsRouter',
          page: EmptyRouterPage,
          children: [
            AutoRoute(path: ':roomId', page: MatrixChatPage),
            RedirectRoute(path: '*', redirectTo: ''),
          ]),
      RedirectRoute(path: '*', redirectTo: ''),
    ]),
    AutoRoute(path: '/login', page: LoginPage)
  ],
)
class $AppRouter {}
