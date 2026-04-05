class Validators {
  Validators._();

  static bool isEmail(String value) =>
      RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value);

  static bool isPhone(String value) =>
      RegExp(r'^1[3-9]\d{9}$').hasMatch(value);

  static bool isUrl(String value) =>
      Uri.tryParse(value)?.hasAbsolutePath ?? false;

  static bool isNotEmpty(String? value) =>
      value != null && value.trim().isNotEmpty;

  static bool isLengthBetween(String value, int min, int max) =>
      value.length >= min && value.length <= max;
}
