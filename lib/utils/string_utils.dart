String? getUserName(userData) {
  String? name;
  if (userData['user'].email != null) {
    name = userData['user'].email;
    name = name!.replaceAll('@kncv.com', '').capitalize();
  }
  return name;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
