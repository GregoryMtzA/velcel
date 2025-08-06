import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app/theme.dart';

class InputDatePicker extends StatefulWidget {

  String hintText;
  Function(DateTime date) onChange;
  bool readOnly;

  InputDatePicker({
    super.key,
    required this.hintText,
    this.readOnly = false,
    required this.onChange,
  });

  @override
  State<InputDatePicker> createState() => _InputDatePickerState();
}

class _InputDatePickerState extends State<InputDatePicker> {
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {

    String formattedDate = DateFormat('yyyy, MMMM, EEEE d', 'es_ES').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.hintText, textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: widget.readOnly ? IsselColors.azulSemiOscuro : Theme.of(context).textTheme.bodySmall?.color),),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: IsselColors.grisClaro,
            borderRadius: BorderRadius.circular(20)
          ),
          child: TextButton(
            onPressed: () async {

              if (widget.readOnly){
                return;
              }

              var results = await showCalendarDatePicker2Dialog(
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                    calendarType: CalendarDatePicker2Type.single
                ),
                dialogSize: const Size(450, 400),
                value: [date],
                borderRadius: BorderRadius.circular(15),
              );

              if (results != null){
                widget.onChange(results.first!);
                date = results.first!;
                setState(() {});
              }

            },
            child: Text(formattedDate, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: widget.readOnly ? IsselColors.azulSemiOscuro : Theme.of(context).textTheme.bodySmall?.color)),
          ),
        ),
      ],
    );
  }
}
