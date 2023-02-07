import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

const kEnvFirebaseToken = 'FIREBASE_TOKEN';
const kEnvServiceAccFile = 'GOOGLE_APPLICATION_CREDENTIALS';

/// Configuration for publishing an application to firebase.
class PublishFirebaseConfig extends PublishConfig {
  /// Firebase app ID (not your app's bundle identifier)
  final String app;

  /// Auth token for connecting to firebase obtained via firebase CLI
  final String? token;

  /// Path to service account file for connecting to firebase
  final String? serviceAccountFile;

  /// Release notes to attach to this release
  final String? releaseNotes;

  /// Path to file with release notes to attach to this release
  final String? releaseNotesFile;

  /// List of testers to attach to this release
  final String? testers;

  /// Path to file with testers to attach to this release
  final String? testersFile;

  /// List of groups to attach to this release
  final String? groups;

  /// Path to file with groups to attach to this release
  final String? groupsFile;

  PublishFirebaseConfig({
    required this.app,
    this.token,
    this.serviceAccountFile,
    this.releaseNotes,
    this.releaseNotesFile,
    this.testers,
    this.testersFile,
    this.groups,
    this.groupsFile,
  });

  factory PublishFirebaseConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    // Get token or service account file for authentication
    String? token = (environment ?? Platform.environment)[kEnvFirebaseToken];
    String? serviceAccountFile =
        (environment ?? Platform.environment)[kEnvServiceAccFile];

    print(token);
    print(serviceAccountFile);

    if ((token ?? '').isEmpty && (serviceAccountFile ?? '').isEmpty) {
      throw PublishError('''
        No autentication for Firebase has been provided.
        
        Please make sure your environment contains either $kEnvFirebaseToken
        with a valid token or $kEnvServiceAccFile with a path to a service
        account credentials file.

        For token authentication, see: https://firebase.google.com/docs/cli?authuser=0#cli-ci-systems
        For service account authentication, see: https://firebase.google.com/docs/app-distribution/authenticate-service-account?platform=ios
      ''');
    }

    // Get Firebase app id
    String? app = publishArguments?['app'];
    if ((app ?? '').isEmpty) {
      throw PublishError('''
        No app id has been provided for publishing to Firebase.

        Please make sure your `distribute_options` contains an app id or
        you passed it directly via command line.

        For obtaining app IDs, see: https://console.firebase.google.com/project/_/settings/general/?authuser=0'
      ''');
    }

    return PublishFirebaseConfig(
      app: app!,
      token: token,
      serviceAccountFile: serviceAccountFile,
      releaseNotes: publishArguments?['release-notes'],
      releaseNotesFile: publishArguments?['release-notes-file'],
      testers: publishArguments?['testers'],
      testersFile: publishArguments?['testers-file'],
      groups: publishArguments?['groups'],
      groupsFile: publishArguments?['groups-file'],
    );
  }

  List<String> toFirebaseCliDistributeArgs() {
    Map<String, String?> cmdData = {
      '--app': app,
      '--token': token,
      '--release-notes': releaseNotes,
      '--release-notes-file': releaseNotesFile,
      '--testers': testers,
      '--testers-file': testersFile,
      '--groups': groups,
      '--groups-file': groupsFile,
    };
    // clean null value cmd
    cmdData.removeWhere((key, value) => value?.isEmpty ?? true);
    // format cmd
    List<String> cmdList = [];
    cmdData.forEach((key, value) {
      cmdList.addAll([key, value!]);
    });
    return cmdList;
  }
}
