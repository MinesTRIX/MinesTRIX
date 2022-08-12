import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix/partials/components/layouts/customHeader.dart';
import 'package:minestrix_chat/partials/dialogs/adaptative_dialogs.dart';
import 'package:minestrix_chat/partials/matrix_image_avatar.dart';
import 'package:minestrix_chat/utils/matrix_widget.dart';
import 'package:provider/provider.dart';

import '../../partials/components/minesTrix/MinesTrixTitle.dart';
import '../../utils/managers/theme_manager.dart';
import '../login_page.dart';

class SettingsAccountPage extends StatefulWidget {
  const SettingsAccountPage({Key? key}) : super(key: key);

  @override
  _SettingsAccountPageState createState() => _SettingsAccountPageState();
}

class _SettingsAccountPageState extends State<SettingsAccountPage> {
  TextEditingController? displayNameController;
  bool savingDisplayName = false;

  @override
  Widget build(BuildContext context) {
    Client sclient = Matrix.of(context).client;
    final m = Matrix.of(context);

    return ListView(
      children: [
        CustomHeader(title: "Account"),
        FutureBuilder(
            future: sclient.getUserProfile(sclient.userID!),
            builder: (context, AsyncSnapshot<ProfileInformation> p) {
              if (displayNameController == null && p.hasData == true) {
                displayNameController = new TextEditingController(
                    text: (p.data?.displayname ?? sclient.userID!));
              }

              return ListTile(
                  leading: savingDisplayName
                      ? CircularProgressIndicator()
                      : MatrixImageAvatar(
                          client: Matrix.of(context).client,
                          url: p.data?.avatarUrl,
                          width: 48,
                          height: 48,
                          defaultIcon: Icon(Icons.person, size: 32),
                        ),
                  title: Text("Edit display name"),
                  trailing: Icon(Icons.edit),
                  subtitle: Text(p.data?.displayname ?? sclient.userID!),
                  onTap: () async {
                    List<String>? results = await showTextInputDialog(
                      context: context,
                      textFields: [
                        DialogTextField(
                            hintText: "Your display name",
                            initialText: p.data?.displayname ?? "")
                      ],
                      title: "Set display name",
                    );
                    if (results?.isNotEmpty == true) {
                      setState(() {
                        savingDisplayName = true;
                      });
                      await sclient.setDisplayName(
                          sclient.userID!, results![0]);
                      setState(() {
                        savingDisplayName = false;
                      });
                    }
                  });
            }),
        ListTile(
            title: Text("Your user ID:"),
            subtitle: Text(sclient.userID ?? "null")),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              H2Title("Accounts"),
              for (final c in m.widget.clients)
                ListTile(
                    title: Text(c.clientName),
                    leading: FutureBuilder<Profile>(
                        future: c.fetchOwnProfile(),
                        builder: (context, snap) {
                          return MatrixImageAvatar(
                            url: snap.data?.avatarUrl,
                            client: c,
                            defaultText: snap.data?.displayName,
                            backgroundColor: Theme.of(context).primaryColor,
                          );
                        }),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.userID ?? ''),
                      ],
                    ),
                    onTap: () async {
                      m.setActiveClient(c);

                      // forcing rebuilding the client
                      context.read<ThemeNotifier>().setPrimaryColor(
                          context.read<ThemeNotifier>().primaryColor);

                      setState(() {});
                    }),
              ListTile(
                  title: Text("Add an account"),
                  trailing: Icon(Icons.add),
                  onTap: () async {
                    AdaptativeDialogs.show(
                        context: context,
                        bottomSheet: true,
                        builder: (context) => LoginPage(
                            popOnLogin: true, title: "Add a new account"));
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
