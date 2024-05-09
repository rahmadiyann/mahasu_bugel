Future<String> stripPhoneNumber(String phoneNumber) async {
  String strippedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
  return strippedPhoneNumber;
}
