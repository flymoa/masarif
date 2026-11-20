import '../l10n/strings.dart';

/// "1 250,00 DH"
String dh(num value, {bool sign = false}) {
  final neg = value < 0;
  final abs = value.abs();
  final cents = (abs * 100).round();
  final intPart = (cents ~/ 100).toString();
  final dec = (cents % 100).toString().padLeft(2, '0');
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(' ');
    buf.write(intPart[i]);
  }
  final prefix = neg ? '−' : (sign ? '+' : '');
  return '$prefix$buf,$dec DH';
}

/// Parse "1 250,5" wla "1250.50" → 1250.5
double? parseAmount(String s) {
  final clean = s.replaceAll(RegExp(r'[\s ]'), '').replaceAll(',', '.');
  final v = double.tryParse(clean);
  if (v == null || v <= 0) return null;
  return (v * 100).roundToDouble() / 100;
}

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String dayLabel(DateTime d) {
  final today = dayOnly(DateTime.now());
  final dd = dayOnly(d);
  if (dd == today) return S.today;
  if (dd == today.subtract(const Duration(days: 1))) return S.yesterday;
  return '${d.day} ${monthShort[d.month - 1]}';
}

String fullDate(DateTime d) {
  final base = '${d.day} ${monthShort[d.month - 1]} ${d.year}';
  return dayOnly(d) == dayOnly(DateTime.now()) ? '${S.today}, $base' : base;
}

String hhmm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String monthLabel(DateTime d) => '${monthNames[d.month - 1]} ${d.year}';

/// Key dyal chher: "2026-11"
String monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
