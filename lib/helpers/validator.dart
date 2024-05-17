class Validator {
  static String validateMobile(String value) {
    if (value.length == 10) {
      try {
        int _ = int.parse(value);
        return null;
      } catch (e) {
        return "Enter a valid mobile number.";
      }
    } else {
      return "Enter a valid mobile number.";
    }
  }

  static String validateemail(String value) {
    String emailPattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(emailPattern);
    if (value.isEmpty) {
      return "Enter a Email.";
    } else if (!regex.hasMatch(value)) {
      return "Enter a valid Email.";
    } else {
      return null;
    }
  }

  static String notEmpty(String value) {
    if (value == "") {
      return "Field cannot be empty";
    }
    return null;
  }

  static String checkMatch(String value, String original, String errorText) {
    if (value == original) {
      return null;
    }
    return errorText;
  }

  static String validatePassword(String passValue) {
    String patternPass =
        // r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
        "^[A-Za-z0-9!@#\$*~?/]";
    RegExp regex = new RegExp(patternPass);
    print(passValue);
    if (passValue.isEmpty) {
      return "Please Enter Password";
    } else if (!regex.hasMatch(passValue)) {
      return "Enter Password";
    } else
      return null;
  }
}
