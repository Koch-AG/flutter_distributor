import 'dart:io' show Platform;

/// Customizer for shell commands to overwrite executables from the env.
///
/// This customizer allows a user to overwrite the executable that will be used
/// for running a command with environment variables.
///
/// This can be useful if `shell_executor` is used for running generated
/// commands, for example from `flutter_distributor`, but the user wants to
/// use a different executable. 
class ShellCustomizer {
  /// Customize a command and its arguments depending on the environment
  ///
  /// This will look for an environment variable named `CUSTOM_XYZ_COMMAND`,
  /// where `XYZ` equals the `executable` passed to this function. If this
  /// variable is present, its contents are used instead of the original
  /// executable.
  ///
  /// It is possible to replace an `executable` with a multi-part command by
  /// using `CUSTOM_XZY_COMMAND="some command"`. Please note that this does
  /// not allow for quoted strings with spaces in the replacement command but
  /// this tradeoff should suffice for most use cases.
  ///
  /// For example, running `'flutter', ['clean']` with the environment
  /// `CUSTOM_FLUTTER_COMMAND="butter"` will run `'butter', ['clean']`
  ///
  /// Running `'flutter', ['clean']` with the environment
  /// `CUSTOM_FLUTTER_COMMAND="fvm flutter"` runs `'fvm', ['flutter', 'clean']`
  ///
  /// Parameters:
  ///  * executable - The executable to run
  ///  * arguments - The arguments to pass to the executable
  ///
  /// Returns:
  ///   A `CustomizedShellCommand` containing the modified executable and
  ///   arguments (or the original values if no env variable was present).
  static CustomizedShellCommand customizeCommand(
    String executable,
    List<String> arguments,
  ) {
    final envVarName = 'CUSTOM_${executable.toUpperCase()}_COMMAND';
    final customCommand = Platform.environment[envVarName];

    if (customCommand != null && customCommand is String) {
      final commandParts = customCommand.split(" ");

      if (commandParts.length >= 1) {
        executable = commandParts[0];
      }

      if (commandParts.length >= 2) {
        arguments = [...commandParts, ...arguments];
        arguments.removeAt(0);
      }
    }

    return CustomizedShellCommand(executable, arguments);
  }
}

class CustomizedShellCommand {
  /// The executable to run
  String executable;

  /// List of arguments to pass to the executable
  List<String> arguments;

  CustomizedShellCommand(this.executable, this.arguments);
}
