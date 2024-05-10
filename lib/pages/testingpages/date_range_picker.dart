import 'package:flutter/material.dart';

class DateRangePicker extends StatefulWidget {
  const DateRangePicker({super.key});

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                final dateTimeRange = await showDateRangePicker(
                  context: context,
                  initialEntryMode: DatePickerEntryMode.calendar,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                final firstDay = dateTimeRange?.start;
                final lastDay = dateTimeRange?.end;
                print('first day: $firstDay');
                print('last day: $lastDay');
              },
              child: const Text('Show Date Picker'),
            ),
          ],
        ),
      ),
    );
  }
}
