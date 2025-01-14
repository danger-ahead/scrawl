import 'package:bnotes/constants.dart';
import 'package:bnotes/pages/backup_restore_page.dart';
import 'package:bnotes/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nextcloud/nextcloud.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _hostController = new TextEditingController();
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  late SharedPreferences loginPreferences;
  bool isLoading = false;

  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nextcloud'),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: kGlobalOuterPadding,
                child: CustomTextField(
                  controller: _hostController,
                  hint: 'Host',
                  icon: Icon(Icons.http),
                  inputType: TextInputType.url,
                ),
              ),
              Padding(
                padding: kGlobalOuterPadding,
                child: CustomTextField(
                  controller: _usernameController,
                  hint: 'Username',
                  icon: Icon(Icons.person_outline),
                  inputType: TextInputType.emailAddress,
                ),
              ),
              Padding(
                padding: kGlobalOuterPadding,
                child: CustomTextField(
                  obscureText: true,
                  isPassword: true,
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icon(Icons.password),
                  inputType: TextInputType.emailAddress,
                ),
              ),
              Visibility(
                visible: !isLoading,
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: kPrimaryColor.withOpacity(0.2),
                          primary: kPrimaryColor),
                      onPressed: () {
                        if (_hostController.text.isNotEmpty &&
                            _usernameController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty) {
                          getdata();
                        }
                      },
                      child: Text('Sign-In')),
                ),
              ),
              Visibility(
                visible: isLoading,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      padding: EdgeInsets.all(10.0),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  padding: EdgeInsets.all(2.0),
                  width: MediaQuery.of(context).size.width * .3,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.black26),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Or, Register with Nextcloud Provider'),
              ),
              // TextButton(
              //   style: ElevatedButton.styleFrom(
              //     primary: Colors.red,
              //     elevation: 0,
              //   ),
              //   onPressed: () => _launchURL(
              //       'https://efss.qloud.my/index.php/apps/registration/'),
              //   child: Image.network(
              //     'https://www.qloud.my/wp-content/uploads/2019/06/logo_qloud-500.png',
              //     width: 100,
              //   ),
              // ),
              TextButton(
                  onPressed: () => _launchURL(
                      'https://efss.qloud.my/index.php/apps/registration/'),
                  child: Text('Qloud')),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     primary: Colors.white,
              //     elevation: 0,
              //   ),
              //   onPressed: () =>
              //       _launchURL('https://owncloud.com/get-started/'),
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Image.network(
              //       'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/OwnCloud_logo_and_wordmark.svg/1200px-OwnCloud_logo_and_wordmark.svg.png',
              //       scale: 14,
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  void _restoreNote() async {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        builder: (context) {
          return Container(
            child: Padding(
              padding: kGlobalOuterPadding,
              child: Container(
                height: 150,
                child: Card(
                  child: Padding(
                    padding: kGlobalOuterPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: kGlobalCardPadding,
                          child: Text(
                            'Restore',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Padding(
                          padding: kGlobalCardPadding,
                          child: Text(
                              'Do you want to restore your previous notes?'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: kGlobalCardPadding,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context,
                                        'yes'); // Confirmation Dialog Pop
                                    Navigator.pop(
                                        context, true); // Login Page Pop
                                  },
                                  child: Text('No'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: kGlobalCardPadding,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      primary: kPrimaryColor,
                                      backgroundColor:
                                          kPrimaryColor.withOpacity(0.2)),
                                  onPressed: () {
                                    Navigator.pop(context,
                                        true); // Confirmation Dialog Pop
                                    Navigator.pop(
                                        context, true); // Login Page Pop
                                    Navigator.of(context).push(
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                BackupRestorePage()));
                                  },
                                  child: Text('Yes'),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future getdata() async {
    loginPreferences = await SharedPreferences.getInstance();
    try {
      setState(() {
        isLoading = true;
      });
      final client = NextCloudClient.withCredentials(
        Uri(host: _hostController.text),
        _usernameController.text,
        _passwordController.text,
      );

      final user = await client.user.getUser();
      print(user);

      // ignore: unnecessary_null_comparison
      if (user != null) {
        loginPreferences.setString('nc_host', _hostController.text);
        loginPreferences.setString('nc_username', _usernameController.text);
        loginPreferences.setString('nc_password', _passwordController.text);

        loginPreferences.setString('nc_userdisplayname', user.displayName);
        loginPreferences.setString('nc_useremail', user.email);

        final userData = await client.avatar.getAvatar(
            loginPreferences.getString('nc_username').toString(), 150);
        loginPreferences.setString('nc_avatar', userData);
        loginPreferences.setBool('is_logged', true);
        loginPreferences.setBool('nextcloud_backup', true);
        setState(() {
          isLoading = false;
        });
        _restoreNote();
      } else {
        setState(() {
          isLoading = false;
        });
        _showAlert();
      }
    } on RequestException catch (e, stacktrace) {
      print('qs' + e.statusCode.toString());
      print(e.body);
      print(stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: Text('Unable to login. Try again.'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future listFiles(NextCloudClient client) async {
    final files = await client.webDav.ls('/');
    for (final file in files) {
      print(file.path);
    }
  }

  void _showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ssd'),
        );
      },
    );
  }
}
