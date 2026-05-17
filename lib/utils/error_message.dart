String cleanErrorMessage(Object error) {
  var message = error.toString();
  message = message.replaceFirst(RegExp(r'^Exception:\s*'), '');
  message = message.replaceAll(RegExp(r'Profil güncellenemedi:\s*\d+'), 'Profil güncellenemedi.');
  message = message.replaceAll(RegExp(r':\s*400\b'), '');
  message = message.trim();
  return message.isEmpty ? 'Bir hata oluştu.' : message;
}
