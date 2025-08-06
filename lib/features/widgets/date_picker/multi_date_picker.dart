import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app/theme.dart';

class MultiDatePicker extends StatelessWidget {

  List<DateTime> dates;
  Function(List<DateTime> date) onChange;
  bool readOnly;

  MultiDatePicker({
    super.key,
    required this.dates,
    required this.onChange,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {

    String firstDate = DateFormat('yyyy-MM-dd', 'es_ES').format(dates[0]);
    String secondDate = DateFormat('yyyy-MM-dd', 'es_ES').format(dates[1]);

    return Container(
      decoration: BoxDecoration(
          color: IsselColors.grisClaro,
          borderRadius: BorderRadius.circular(20)
      ),
      child: TextButton(
        onPressed: () async {

          if (readOnly){
            return;
          }

          var results = await showCalendarDatePicker2Dialog(
            context: context,
            config: CalendarDatePicker2WithActionButtonsConfig(
                calendarType: CalendarDatePicker2Type.range
            ),
            dialogSize: const Size(450, 400),
            borderRadius: BorderRadius.circular(15),
          );

          if (results != null){
            onChange([results[0]!, results[1]!]);
          }

        },
        child: Text("${firstDate}  A  ${secondDate}", style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
