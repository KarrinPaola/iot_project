import 'package:flutter/material.dart';
import 'package:iot_project/main%20app/home/component/history/component/history_items.dart';
import 'package:iot_project/main%20app/home/component/history/component/load_data_history.dart';
import 'package:iot_project/userID_Store.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryHome extends StatefulWidget {
  const HistoryHome({super.key});

  @override
  State<HistoryHome> createState() => _HistoryHomeState();
}

class _HistoryHomeState extends State<HistoryHome> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<Map<String, dynamic>> _HistoryItems = [];

  Future<void> _loadHistory() async {
    if (_selectedDay != null) {
      List<Map<String, dynamic>> HistoryItemsLoad = await loadDataHistory(
        UserStorage.userId!,
        _selectedDay!,
      );
      setState(() {
        _HistoryItems = HistoryItemsLoad;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Lịch sử hoạt động",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(25),
              padding: EdgeInsets.all(MediaQuery.of(context).size.width / 50),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TableCalendar(
                locale: 'vi_VN',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadHistory();
                },
                calendarFormat: CalendarFormat.week,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.black),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.black),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.black),
                  weekendStyle: TextStyle(color: Colors.red),
                ),
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  cellMargin: EdgeInsets.all(7),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width*1,
              
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: _HistoryItems.isNotEmpty
                  ? SingleChildScrollView(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width/25),
                      child: Column(
                        children: _HistoryItems.map((item) {
                          return HistoryItems(
                            actions: item['action'],
                            time: item['time'],
                          );
                        }).toList(),
                      ),
                    )
                  : const Center(
                      child: Text('Chưa có hành động nào trong hôm nay!'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}