String dateFormatter(String dateStr) {
    if (dateStr.isEmpty) return "";
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return "$year-$month-$day";
      }
    } catch (_) {}
    return dateStr;
  }
