String timeAgo(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inMinutes < 1) return "Baru saja";
  if (diff.inMinutes < 60) return "${diff.inMinutes}m lalu";
  if (diff.inHours < 24) return "${diff.inHours}j lalu";
  if (diff.inDays < 30) return "${diff.inDays}h lalu";

  final months = _monthsBetween(time, now);
  if (months < 12) return "${months}bulan lalu";

  final years = (months / 12).floor();
  return "${years}tahun lalu";
}

String formatTime(DateTime? time) {
  if (time == null) return '-';

  final now = DateTime.now();
  final diff = now.difference(time);

  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  final clock = "$h.$m";

  if (diff.inMinutes < 1) {
    return "$clock • Baru saja";
  }
  if (diff.inMinutes < 60) {
    return "$clock • ${diff.inMinutes}m lalu";
  }
  if (diff.inHours < 24) {
    final hour = diff.inHours;
    final minute = diff.inMinutes % 60;
    return "$clock • ${hour}j ${minute}m lalu";
  }
  if (diff.inDays < 30) {
    return "$clock • ${diff.inDays}h lalu";
  }

  final months = _monthsBetween(time, now);
  if (months < 12) {
    return "$clock • ${months}bulan lalu";
  }

  final years = (months / 12).floor();
  return "$clock • ${years}tahun lalu";
}

int _monthsBetween(DateTime from, DateTime to) {
  int months = (to.year - from.year) * 12 + (to.month - from.month);
  if (to.day < from.day) {
    months -= 1;
  }
  return months < 0 ? 0 : months;
}
