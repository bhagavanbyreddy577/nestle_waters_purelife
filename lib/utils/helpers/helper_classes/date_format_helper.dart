import 'package:intl/intl.dart';

class NDateFormatHelper {

  /// Private constructor to prevent instantiation
  NDateFormatHelper._();

  // ======================= BASIC DATE FORMATTERS =======================

  /// Returns date in format: "May 9, 2025"
  ///
  /// Example:
  /// ```dart
  /// String formattedDate = DateFormatUtils.formatFullDate(DateTime.now());
  /// print(formattedDate); // "May 9, 2025"
  /// ```
  static String formatFullDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  /// Returns date in format: "05/09/2025"
  ///
  /// Example:
  /// ```dart
  /// String formattedDate = DateFormatUtils.formatShortDate(DateTime.now());
  /// print(formattedDate); // "05/09/2025"
  /// ```
  static String formatShortDate(DateTime date) {
    return DateFormat.yMd().format(date);
  }

  /// Returns date in format: "05/09/25"
  ///
  /// Example:
  /// ```dart
  /// String formattedDate = DateFormatUtils.formatVeryShortDate(DateTime.now());
  /// print(formattedDate); // "05/09/25"
  /// ```
  static String formatVeryShortDate(DateTime date) {
    return DateFormat('MM/dd/yy').format(date);
  }

  /// Returns date in ISO 8601 format: "2025-05-09"
  ///
  /// Example:
  /// ```dart
  /// String formattedDate = DateFormatUtils.formatIsoDate(DateTime.now());
  /// print(formattedDate); // "2025-05-09"
  /// ```
  static String formatIsoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // ======================= TIME FORMATTERS =======================

  /// Returns time in 12-hour format: "2:30 PM"
  ///
  /// Example:
  /// ```dart
  /// String formattedTime = DateFormatUtils.formatTime12Hour(DateTime.now());
  /// print(formattedTime); // "2:30 PM"
  /// ```
  static String formatTime12Hour(DateTime date) {
    return DateFormat.jm().format(date);
  }

  /// Returns time in 24-hour format: "14:30"
  ///
  /// Example:
  /// ```dart
  /// String formattedTime = DateFormatUtils.formatTime24Hour(DateTime.now());
  /// print(formattedTime); // "14:30"
  /// ```
  static String formatTime24Hour(DateTime date) {
    return DateFormat.Hm().format(date);
  }

  /// Returns time with seconds in 12-hour format: "2:30:45 PM"
  ///
  /// Example:
  /// ```dart
  /// String formattedTime = DateFormatUtils.formatTimeWithSeconds12Hour(DateTime.now());
  /// print(formattedTime); // "2:30:45 PM"
  /// ```
  static String formatTimeWithSeconds12Hour(DateTime date) {
    return DateFormat.jms().format(date);
  }

  /// Returns time with seconds in 24-hour format: "14:30:45"
  ///
  /// Example:
  /// ```dart
  /// String formattedTime = DateFormatUtils.formatTimeWithSeconds24Hour(DateTime.now());
  /// print(formattedTime); // "14:30:45"
  /// ```
  static String formatTimeWithSeconds24Hour(DateTime date) {
    return DateFormat.Hms().format(date);
  }

  // ======================= DATETIME FORMATTERS =======================

  /// Returns date and time in format: "May 9, 2025 at 2:30 PM"
  ///
  /// Example:
  /// ```dart
  /// String formattedDateTime = DateFormatUtils.formatFullDateTime(DateTime.now());
  /// print(formattedDateTime); // "May 9, 2025 at 2:30 PM"
  /// ```
  static String formatFullDateTime(DateTime date) {
    return DateFormat("MMMM d, yyyy 'at' h:mm a").format(date);
  }

  /// Returns date and time in short format: "05/09/2025 2:30 PM"
  ///
  /// Example:
  /// ```dart
  /// String formattedDateTime = DateFormatUtils.formatShortDateTime(DateTime.now());
  /// print(formattedDateTime); // "05/09/2025 2:30 PM"
  /// ```
  static String formatShortDateTime(DateTime date) {
    return DateFormat('MM/dd/yyyy h:mm a').format(date);
  }

  /// Returns date and time in ISO format: "2025-05-09T14:30:45"
  ///
  /// Example:
  /// ```dart
  /// String formattedDateTime = DateFormatUtils.formatIsoDateTime(DateTime.now());
  /// print(formattedDateTime); // "2025-05-09T14:30:45"
  /// ```
  static String formatIsoDateTime(DateTime date) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss').format(date);
  }

  /// Returns date and time in ISO format with timezone: "2025-05-09T14:30:45-0400"
  ///
  /// Example:
  /// ```dart
  /// String formattedDateTime = DateFormatUtils.formatIsoDateTimeWithTimezone(DateTime.now());
  /// print(formattedDateTime); // "2025-05-09T14:30:45-0400"
  /// ```
  static String formatIsoDateTimeWithTimezone(DateTime date) {
    return DateFormat('yyyy-MM-ddTHH:mm:ssZ').format(date);
  }

  // ======================= DAY, MONTH, YEAR FORMATTERS =======================

  /// Returns day of the month: "9"
  ///
  /// Example:
  /// ```dart
  /// String day = DateFormatUtils.formatDay(DateTime.now());
  /// print(day); // "9"
  /// ```
  static String formatDay(DateTime date) {
    return DateFormat('d').format(date);
  }

  /// Returns day of the month with suffix: "9th"
  ///
  /// Example:
  /// ```dart
  /// String day = DateFormatUtils.formatDayWithSuffix(DateTime.now());
  /// print(day); // "9th"
  /// ```
  static String formatDayWithSuffix(DateTime date) {
    final int dayNum = date.day;
    String suffix;

    if (dayNum >= 11 && dayNum <= 13) {
      suffix = 'th';
    } else {
      switch (dayNum % 10) {
        case 1: suffix = 'st'; break;
        case 2: suffix = 'nd'; break;
        case 3: suffix = 'rd'; break;
        default: suffix = 'th'; break;
      }
    }

    return '$dayNum$suffix';
  }

  /// Returns month name: "May"
  ///
  /// Example:
  /// ```dart
  /// String month = DateFormatUtils.formatMonth(DateTime.now());
  /// print(month); // "May"
  /// ```
  static String formatMonth(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  /// Returns short month name: "May"
  ///
  /// Example:
  /// ```dart
  /// String month = DateFormatUtils.formatShortMonth(DateTime.now());
  /// print(month); // "May"
  /// ```
  static String formatShortMonth(DateTime date) {
    return DateFormat('MMM').format(date);
  }

  /// Returns month number: "05"
  ///
  /// Example:
  /// ```dart
  /// String month = DateFormatUtils.formatMonthNumber(DateTime.now());
  /// print(month); // "05"
  /// ```
  static String formatMonthNumber(DateTime date) {
    return DateFormat('MM').format(date);
  }

  /// Returns year: "2025"
  ///
  /// Example:
  /// ```dart
  /// String year = DateFormatUtils.formatYear(DateTime.now());
  /// print(year); // "2025"
  /// ```
  static String formatYear(DateTime date) {
    return DateFormat('yyyy').format(date);
  }

  /// Returns short year: "25"
  ///
  /// Example:
  /// ```dart
  /// String year = DateFormatUtils.formatShortYear(DateTime.now());
  /// print(year); // "25"
  /// ```
  static String formatShortYear(DateTime date) {
    return DateFormat('yy').format(date);
  }

  // ======================= DAY OF WEEK FORMATTERS =======================

  /// Returns day of week: "Friday"
  ///
  /// Example:
  /// ```dart
  /// String dayOfWeek = DateFormatUtils.formatDayOfWeek(DateTime.now());
  /// print(dayOfWeek); // "Friday"
  /// ```
  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Returns short day of week: "Fri"
  ///
  /// Example:
  /// ```dart
  /// String dayOfWeek = DateFormatUtils.formatShortDayOfWeek(DateTime.now());
  /// print(dayOfWeek); // "Fri"
  /// ```
  static String formatShortDayOfWeek(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  // ======================= RELATIVE TIME FORMATTERS =======================

  /// Returns a relative time string like "2 hours ago" or "in 3 days"
  ///
  /// Example:
  /// ```dart
  /// String relativeTime = DateFormatUtils.getRelativeTime(DateTime.now().subtract(Duration(hours: 2)));
  /// print(relativeTime); // "2 hours ago"
  /// ```
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final isFuture = dateTime.isAfter(now);

    final absoluteDifference = difference.abs();

    if (absoluteDifference.inSeconds < 60) {
      return isFuture ? 'in a few seconds' : 'a few seconds ago';
    } else if (absoluteDifference.inMinutes < 60) {
      final minutes = absoluteDifference.inMinutes;
      return isFuture ? 'in $minutes ${minutes == 1 ? 'minute' : 'minutes'}' : '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (absoluteDifference.inHours < 24) {
      final hours = absoluteDifference.inHours;
      return isFuture ? 'in $hours ${hours == 1 ? 'hour' : 'hours'}' : '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (absoluteDifference.inDays < 7) {
      final days = absoluteDifference.inDays;
      return isFuture ? 'in $days ${days == 1 ? 'day' : 'days'}' : '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (absoluteDifference.inDays < 30) {
      final weeks = (absoluteDifference.inDays / 7).floor();
      return isFuture ? 'in $weeks ${weeks == 1 ? 'week' : 'weeks'}' : '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (absoluteDifference.inDays < 365) {
      final months = (absoluteDifference.inDays / 30).floor();
      return isFuture ? 'in $months ${months == 1 ? 'month' : 'months'}' : '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (absoluteDifference.inDays / 365).floor();
      return isFuture ? 'in $years ${years == 1 ? 'year' : 'years'}' : '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Returns "Today", "Yesterday", "Tomorrow", or a formatted date
  ///
  /// Example:
  /// ```dart
  /// String relativeDate = DateFormatUtils.getRelativeDate(DateTime.now().subtract(Duration(days: 1)));
  /// print(relativeDate); // "Yesterday"
  /// ```
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return 'Today';
    } else if (inputDate == yesterday) {
      return 'Yesterday';
    } else if (inputDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return formatShortDate(date);
    }
  }

  // ======================= CUSTOM FORMATTERS =======================

  /// Returns a custom formatted date using the intl package format string
  ///
  /// Example:
  /// ```dart
  /// String formattedDate = DateFormatUtils.formatCustom(DateTime.now(), 'EEEE, MMMM d, yyyy');
  /// print(formattedDate); // "Friday, May 9, 2025"
  /// ```
  static String formatCustom(DateTime date, String format) {
    return DateFormat(format).format(date);
  }

  /// Returns a formatted date for calendar display: "May 2025"
  ///
  /// Example:
  /// ```dart
  /// String calendarHeader = DateFormatUtils.formatCalendarHeader(DateTime.now());
  /// print(calendarHeader); // "May 2025"
  /// ```
  static String formatCalendarHeader(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Returns a formatted date for file naming: "2025-05-09_14-30-45"
  ///
  /// Example:
  /// ```dart
  /// String fileName = DateFormatUtils.formatForFileName(DateTime.now());
  /// print(fileName); // "2025-05-09_14-30-45"
  /// ```
  static String formatForFileName(DateTime date) {
    return DateFormat('yyyy-MM-dd_HH-mm-ss').format(date);
  }

  // ======================= DATE CALCULATIONS =======================

  /// Returns true if the date is today
  ///
  /// Example:
  /// ```dart
  /// bool isToday = DateFormatUtils.isToday(DateTime.now());
  /// print(isToday); // true
  /// ```
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Returns true if the date is yesterday
  ///
  /// Example:
  /// ```dart
  /// bool isYesterday = DateFormatUtils.isYesterday(DateTime.now().subtract(Duration(days: 1)));
  /// print(isYesterday); // true
  /// ```
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  /// Returns true if the date is tomorrow
  ///
  /// Example:
  /// ```dart
  /// bool isTomorrow = DateFormatUtils.isTomorrow(DateTime.now().add(Duration(days: 1)));
  /// print(isTomorrow); // true
  /// ```
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// Returns true if the date is in the same week as today
  ///
  /// Example:
  /// ```dart
  /// bool isThisWeek = DateFormatUtils.isThisWeek(DateTime.now().add(Duration(days: 2)));
  /// print(isThisWeek); // true
  /// ```
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekDay = today.weekday;

    // Calculate first day of week (assuming week starts on Monday)
    final firstDayOfWeek = today.subtract(Duration(days: weekDay - 1));

    // Calculate last day of week
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    // Check if date is between first and last day of the week
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.compareTo(firstDayOfWeek) >= 0 && dateOnly.compareTo(lastDayOfWeek) <= 0;
  }

  /// Returns true if the date is in the same month as today
  ///
  /// Example:
  /// ```dart
  /// bool isThisMonth = DateFormatUtils.isThisMonth(DateTime.now().add(Duration(days: 10)));
  /// print(isThisMonth); // true
  /// ```
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Returns true if the date is in the same year as today
  ///
  /// Example:
  /// ```dart
  /// bool isThisYear = DateFormatUtils.isThisYear(DateTime.now().add(Duration(days: 60)));
  /// print(isThisYear); // true
  /// ```
  static bool isThisYear(DateTime date) {
    return date.year == DateTime.now().year;
  }

  // ======================= SPECIAL FORMAT PATTERNS =======================

  /// Returns date formatted for API submission (ISO 8601 with Z): "2025-05-09T14:30:45Z"
  ///
  /// Example:
  /// ```dart
  /// String apiDate = DateFormatUtils.formatForApi(DateTime.now());
  /// print(apiDate); // "2025-05-09T14:30:45Z"
  /// ```
  static String formatForApi(DateTime date) {
    // Convert to UTC and format as ISO string
    return date.toUtc().toIso8601String();
  }

  /// Returns date formatted for display in a chat: "Today at 2:30 PM" or "05/09/2025"
  ///
  /// Example:
  /// ```dart
  /// String chatTime = DateFormatUtils.formatForChat(DateTime.now().subtract(Duration(hours: 2)));
  /// print(chatTime); // "Today at 2:30 PM"
  /// ```
  static String formatForChat(DateTime date) {
    if (isToday(date)) {
      return "Today at ${formatTime12Hour(date)}";
    } else if (isYesterday(date)) {
      return "Yesterday at ${formatTime12Hour(date)}";
    } else if (isThisWeek(date)) {
      return "${formatDayOfWeek(date)} at ${formatTime12Hour(date)}";
    } else if (isThisYear(date)) {
      return "${formatMonth(date)} ${formatDay(date)} at ${formatTime12Hour(date)}";
    } else {
      return "${formatMonth(date)} ${formatDay(date)}, ${formatYear(date)}";
    }
  }

  /// Returns time elapsed since date in format "2h 30m" or "3d 5h"
  ///
  /// Example:
  /// ```dart
  /// String elapsed = DateFormatUtils.formatTimeElapsed(DateTime.now().subtract(Duration(hours: 2, minutes: 30)));
  /// print(elapsed); // "2h 30m"
  /// ```
  static String formatTimeElapsed(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inDays > 0) {
      final hours = difference.inHours - (difference.inDays * 24);
      return '${difference.inDays}d ${hours}h';
    } else if (difference.inHours > 0) {
      final minutes = difference.inMinutes - (difference.inHours * 60);
      return '${difference.inHours}h ${minutes}m';
    } else if (difference.inMinutes > 0) {
      final seconds = difference.inSeconds - (difference.inMinutes * 60);
      return '${difference.inMinutes}m ${seconds}s';
    } else {
      return '${difference.inSeconds}s';
    }
  }

  /// Returns a timestamp string suitable for a digital clock display: "14:30:45"
  ///
  /// Example:
  /// ```dart
  /// String timestamp = DateFormatUtils.formatTimestamp(DateTime.now());
  /// print(timestamp); // "14:30:45"
  /// ```
  static String formatTimestamp(DateTime date) {
    return DateFormat.Hms().format(date);
  }

  /// Returns a short timestamp string suitable for a digital clock display: "14:30"
  ///
  /// Example:
  /// ```dart
  /// String timestamp = DateFormatUtils.formatShortTimestamp(DateTime.now());
  /// print(timestamp); // "14:30"
  /// ```
  static String formatShortTimestamp(DateTime date) {
    return DateFormat.Hm().format(date);
  }

  // ======================= LOCALIZATION HELPERS =======================

  /// Returns a date formatted according to the specified locale
  ///
  /// Example:
  /// ```dart
  /// String frenchDate = DateFormatUtils.formatLocalizedDate(DateTime.now(), 'fr_FR');
  /// print(frenchDate); // "9 mai 2025"
  /// ```
  static String formatLocalizedDate(DateTime date, String locale) {
    return DateFormat.yMMMMd(locale).format(date);
  }

  /// Returns a time formatted according to the specified locale
  ///
  /// Example:
  /// ```dart
  /// String frenchTime = DateFormatUtils.formatLocalizedTime(DateTime.now(), 'fr_FR');
  /// print(frenchTime); // "14:30"
  /// ```
  static String formatLocalizedTime(DateTime date, String locale) {
    return DateFormat.jm(locale).format(date);
  }
}

/// Extension method for DateTime to simplify date formatting
extension DateTimeFormatExtension on DateTime {
  /// Format this date to a full date representation
  String toFullDate() => NDateFormatHelper.formatFullDate(this);

  /// Format this date to a short date representation
  String toShortDate() => NDateFormatHelper.formatShortDate(this);

  /// Format this date to time in 12-hour format
  String toTime12Hour() => NDateFormatHelper.formatTime12Hour(this);

  /// Format this date to time in 24-hour format
  String toTime24Hour() => NDateFormatHelper.formatTime24Hour(this);

  /// Format this date to a full date and time representation
  String toFullDateTime() => NDateFormatHelper.formatFullDateTime(this);

  /// Format this date as a relative time (e.g., "2 hours ago")
  String toRelativeTime() => NDateFormatHelper.getRelativeTime(this);

  /// Format this date as a relative date (e.g., "Today", "Yesterday")
  String toRelativeDate() => NDateFormatHelper.getRelativeDate(this);

  /// Check if this date is today
  bool get isToday => NDateFormatHelper.isToday(this);

  /// Check if this date is yesterday
  bool get isYesterday => NDateFormatHelper.isYesterday(this);

  /// Check if this date is tomorrow
  bool get isTomorrow => NDateFormatHelper.isTomorrow(this);

  /// Format this date for chat display
  String toChatFormat() => NDateFormatHelper.formatForChat(this);

  /// Format this date for API submission
  String toApiFormat() => NDateFormatHelper.formatForApi(this);

  /// Format as elapsed time
  String toElapsedTime() => NDateFormatHelper.formatTimeElapsed(this);
}