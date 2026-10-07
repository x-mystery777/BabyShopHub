String naira(num value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '₦$buffer';
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDate(DateTime? d) =>
    d == null ? '-' : '${_months[d.month - 1]} ${d.day}, ${d.year}';

String formatDateTime(DateTime? d) {
  if (d == null) return '-';
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '${formatDate(d)}, $h:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
}

/// yyyy-MM-dd, as the backend expects for dates of birth.
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String orderNumber(int id) => '#BSH${id.toString().padLeft(6, '0')}';

/// Same rule the backend enforces for reset / change password.
final _strongPassword = RegExp(
    r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[-@!*()}{#$%,<>/^:;'&+=_~?]).{8,}$");

String? validateStrongPassword(String? v) {
  if (v == null || v.isEmpty) return 'Enter a password.';
  if (!_strongPassword.hasMatch(v)) {
    return 'Use 8+ characters with upper & lower case, a number and a symbol.';
  }
  return null;
}

String? validateEmailField(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email address.';
  }
  return null;
}