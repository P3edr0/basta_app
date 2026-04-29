import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../handler/value_handler.dart';

class TneDateFormat {
  static final maskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static String eventTimeFormat(DateTime date) {
    final day = date.day;
    final month = date.month;
    final year = date.year;
    final hour = date.hour;
    final minutes = date.minute < 10 ? '${date.minute}0' : date.minute;

    final monthName = switch (month) {
      1 => 'Janeiro',
      2 => 'Fevereiro',
      3 => 'Março',
      4 => 'Abril',
      5 => 'Maio',
      6 => 'Junho',
      7 => 'Julho',
      8 => 'Agosto',
      9 => 'Setembro',
      10 => 'Outubro',
      11 => 'Novembro',
      12 => 'Dezembro',
      _ => 'Mês inválido',
    };

    return '$day de $monthName $year $hour:$minutes';
  }

  static String frequencyFormat(DateTime date) {
    final day = GiValueHandler.smallNumberToShow(date.day);
    final month = date.month;

    final monthName = switch (month) {
      1 => 'Jan',
      2 => 'Fev',
      3 => 'Mar',
      4 => 'Abr',
      5 => 'Mai',
      6 => 'Jun',
      7 => 'Jul',
      8 => 'Ago',
      9 => 'Set',
      10 => 'Out',
      11 => 'Nov',
      12 => 'Dez',
      _ => 'Mês inválido',
    };

    return '$day $monthName';
  }

  static String notificationFormat(DateTime date) {
    final day = GiValueHandler.smallNumberToShow(date.day);
    final month = date.month;
    final hour = GiValueHandler.smallNumberToShow(date.hour);
    final minutes = GiValueHandler.smallNumberToShow(date.minute);

    final monthName = switch (month) {
      1 => 'Jan',
      2 => 'Fev',
      3 => 'Mar',
      4 => 'Abr',
      5 => 'Mai',
      6 => 'Jun',
      7 => 'Jul',
      8 => 'Ago',
      9 => 'Set',
      10 => 'Out',
      11 => 'Nov',
      12 => 'Dez',
      _ => 'Mês inválido',
    };

    return '$day $monthName | $hour:$minutes';
  }

  static String calendarFormat(DateTime date) {
    final year = date.year;
    final month = date.month;

    final monthName = switch (month) {
      1 => 'Janeiro',
      2 => 'Fevereiro',
      3 => 'Março',
      4 => 'Abril',
      5 => 'Maio',
      6 => 'Junho',
      7 => 'Julho',
      8 => 'Agosto',
      9 => 'Setembro',
      10 => 'Outubro',
      11 => 'Novembro',
      12 => 'Dezembro',
      _ => 'Mês inválido',
    };

    return '$monthName $year';
  }

  static DateTime? birthDayFormatter(
    String date, [
    String pattern = '/',
    bool isReverse = false,
  ]) {
    if (date.trim().isEmpty) {
      return null;
    }
    final dateSplits =
        date.split(pattern).map((element) => int.parse(element)).toList();
    if (dateSplits.length != 3) return null;

    late int day;
    late int month;
    late int year;

    if (isReverse) {
      day = dateSplits.last;
      month = dateSplits[1];
      year = dateSplits.first;
    } else {
      day = dateSplits.first;
      month = dateSplits[1];
      year = dateSplits.last;
    }
    if (day == 0 || month == 0 || year == 0) return null;
    final handledDate = DateTime(year, month, day);

    return handledDate;
  }

  static DateTime? toDate(
    String date, [
    String pattern = '-',
    bool isReverse = false,
  ]) {
    if (date.trim().isEmpty) {
      return null;
    }
    final dateSplits =
        date.split(pattern).map((element) => int.parse(element)).toList();
    if (dateSplits.length != 3) return null;

    late int day;
    late int month;
    late int year;

    if (isReverse) {
      day = dateSplits.last;
      month = dateSplits[1];
      year = dateSplits.first;
    } else {
      day = dateSplits.first;
      month = dateSplits[1];
      year = dateSplits.last;
    }
    final handledDate = DateTime(year, month, day);

    return handledDate;
  }

  static String expireTimeFormat(DateTime expireAt) {
    final now = DateTime.now();
    final elapsed = expireAt.difference(now);

    if (elapsed.isNegative) {
      return 'Expirado';
    }
    final handledRemaining = elapsed.toString().split('.').first.padLeft(8, '');
    return 'Expira em $handledRemaining';
  }

  static String? ymd(String date) {
    final handledDate = birthDayFormatter(date);
    if (handledDate == null) {
      return null;
    }
    final content =
        '${handledDate.year}-${handledDate.month}-${handledDate.day}';

    return content;
  }

  static String? dmy(DateTime date) {
    final content =
        '${GiValueHandler.smallNumberToShow(date.day)}/${GiValueHandler.smallNumberToShow(date.month)}/${date.year}';

    return content;
  }

  static String? ddmm(DateTime date) {
    final handledDate =
        "${GiValueHandler.smallNumberToShow(date.day)}/${GiValueHandler.smallNumberToShow(date.month)}";

    return handledDate;
  }

  static String getWeekdayAbbreviation(DateTime date) {
    String locale = 'pt_BR';
    initializeDateFormatting(locale);

    final format = DateFormat('E', locale);
    String content = format.format(date);
    content = content.replaceFirst(content[0], content[0].toUpperCase());
    content = content.replaceFirst('.', '');
    return content;
  }

  static String getHour(DateTime date) {
    String minute = GiValueHandler.smallNumberToShow(date.minute);
    String hour = GiValueHandler.smallNumberToShow(date.hour);
    String content = '$hour:$minute';
    return content;
  }
}

extension Normalize on DateTime {
  DateTime normalize() {
    return DateTime(year, month, day);
  }
}
