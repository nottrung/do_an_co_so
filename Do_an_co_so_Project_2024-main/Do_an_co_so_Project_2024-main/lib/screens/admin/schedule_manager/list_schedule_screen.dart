// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:tea_man_pka/screens/admin/schedule_manager/detail_tea_schedule_screen.dart';
// import 'create_schedule_screen.dart';
//
// class ListScheduleScreen extends StatefulWidget {
//   @override
//   _ListScheduleScreenState createState() => _ListScheduleScreenState();
// }
//
// class _ListScheduleScreenState extends State<ListScheduleScreen> {
//   List<DocumentSnapshot> _schedules = [];
//   List<String> _teacherNames = [];
//   String _searchText = '';
//   String _selectedTeacher = 'All';
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchSchedules();
//   }
//
//   Future<void> _fetchSchedules() async {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('schedules').get();
//     setState(() {
//       _schedules = snapshot.docs;
//
//       _teacherNames = _schedules.map((schedule) => schedule['teacherName'].toString()).toSet().toList();
//       _teacherNames.insert(0, 'All');
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<DocumentSnapshot> filteredSchedules = _schedules.where((schedule) {
//       String teacherName = schedule['teacherName'].toString().toLowerCase();
//       String courseTitle = schedule['courseTitle'].toString().toLowerCase();
//
//       bool matchesSearch = teacherName.contains(_searchText.toLowerCase()) ||
//           courseTitle.contains(_searchText.toLowerCase());
//
//       bool matchesTeacher = _selectedTeacher.toLowerCase() == 'all' || teacherName.toLowerCase() == _selectedTeacher.toLowerCase();
//
//       return matchesSearch && matchesTeacher;
//     }).toList();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Flexible(
//           child: Text(
//             'Danh sách lịch giảng',
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         toolbarHeight: 80,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: TextField(
//               onChanged: (value) {
//                 setState(() {
//                   _searchText = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Tìm kiếm giảng viên, môn học,...',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: DropdownButtonFormField<String>(
//               value: _selectedTeacher,
//               items: _teacherNames.map((teacher) => DropdownMenuItem<String>(
//                 value: teacher,
//                 child: Wrap(
//                   children: [
//                     Text(
//                       teacher,
//                       softWrap: true,
//                     ),
//                   ],
//                 ),
//               )).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedTeacher = value!;
//                 });
//               },
//               decoration: InputDecoration(
//                 labelText: 'Chọn giảng viên',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20.0),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: filteredSchedules.isNotEmpty
//                 ? ListView.builder(
//               itemCount: filteredSchedules.length,
//               itemBuilder: (context, index) {
//                 var schedule = filteredSchedules[index];
//                 return ScheduleCard(
//                   teacherName: schedule['teacherName'],
//                   teacherId: schedule['teacherId'],
//                   courseTitle: schedule['courseTitle'],
//                   startDate: schedule['startDate'],
//                   endDate: schedule['endDate'],
//                   room: schedule['room'],
//                   dayOfWeek: schedule['dayOfWeek'],
//                   startTime: schedule['startTime'],
//                   endTime: schedule['endTime'],
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DetailTeaScheduleScreen(
//                           scheduleId: schedule.id,
//                           scheduleData: schedule.data() as Map<String, dynamic>,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             )
//                 : Center(
//               child: Text('Không tìm thấy lịch giảng của giảng viên này'),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => CreateScheduleScreen()),
//           );
//         },
//         child: Icon(Icons.add),
//       ),
//       floatingActionButtonLocation: CustomFloatingActionButtonLocation(
//         FloatingActionButtonLocation.endFloat,
//         offset: Offset(-20, -20),
//       ),
//     );
//   }
// }
//
// class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
//   final FloatingActionButtonLocation location;
//   final Offset offset;
//
//   CustomFloatingActionButtonLocation(this.location, {required this.offset});
//
//   @override
//   Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
//     final Offset baseOffset = location.getOffset(scaffoldGeometry);
//     return baseOffset + offset;
//   }
// }
//
// class ScheduleCard extends StatelessWidget {
//   final String teacherName;
//   final String teacherId;
//   final String courseTitle;
//   final String startDate;
//   final String endDate;
//   final String room;
//   final String dayOfWeek;
//   final String startTime;
//   final String endTime;
//   final VoidCallback onTap;
//
//   ScheduleCard({
//     required this.teacherName,
//     required this.teacherId,
//     required this.courseTitle,
//     required this.startDate,
//     required this.endDate,
//     required this.room,
//     required this.dayOfWeek,
//     required this.startTime,
//     required this.endTime,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 0.0),
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Giảng viên: $teacherName', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 Text('Mã giảng viên: $teacherId', style: TextStyle(fontSize: 16)),
//                 Text('Môn học: $courseTitle', style: TextStyle(fontSize: 16)),
//                 Text('Phòng học: $room', style: TextStyle(fontSize: 16)),
//                 Text('Ngày: $dayOfWeek', style: TextStyle(fontSize: 16)),
//                 Text('Thời gian: $startTime - $endTime', style: TextStyle(fontSize: 16)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ad_custom_drawer.dart';
import 'create_schedule_screen.dart';
import 'detail_tea_schedule_screen.dart';

class ListScheduleScreen extends StatefulWidget {
  @override
  _ListScheduleScreenState createState() => _ListScheduleScreenState();
}

class _ListScheduleScreenState extends State<ListScheduleScreen> {
  List<DocumentSnapshot> _schedules = [];
  List<String> _teacherNames = [];
  List<String> _semesters = [];
  String _searchText = '';
  String _selectedTeacher = 'All';
  String _selectedSemester = 'All';

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('schedules').get();
    setState(() {
      _schedules = snapshot.docs;

      _teacherNames = _schedules.map((schedule) => schedule['teacherName'].toString()).toSet().toList();
      _teacherNames.insert(0, 'All');

      _semesters = _schedules.map((schedule) => schedule['semester'].toString()).toSet().toList();
      _semesters.insert(0, 'All');
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> filteredSchedules = _schedules.where((schedule) {
      String teacherName = schedule['teacherName'].toString().toLowerCase();
      String courseTitle = schedule['courseTitle'].toString().toLowerCase();
      String semester = schedule['semester'].toString().toLowerCase();

      bool matchesSearch = teacherName.contains(_searchText.toLowerCase()) ||
          courseTitle.contains(_searchText.toLowerCase());

      bool matchesTeacher = _selectedTeacher.toLowerCase() == 'all' || teacherName == _selectedTeacher.toLowerCase();

      bool matchesSemester = _selectedSemester.toLowerCase() == 'all' || semester == _selectedSemester.toLowerCase();

      return matchesSearch && matchesTeacher && matchesSemester;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách lịch giảng'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: AdCustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giảng viên, môn học,...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: DropdownButtonFormField<String>(
              value: _selectedTeacher,
              items: _teacherNames.map((teacher) => DropdownMenuItem<String>(
                value: teacher,
                child: Container(
                  width: 280,
                  child: Text(
                    teacher,
                    style: TextStyle(fontSize: 16),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTeacher = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Chọn giảng viên',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: DropdownButtonFormField<String>(
              value: _selectedSemester,
              items: _semesters.map((semester) => DropdownMenuItem<String>(
                value: semester,
                child: Text(semester),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Chọn học kỳ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredSchedules.isNotEmpty
                ? ListView.builder(
              itemCount: filteredSchedules.length,
              itemBuilder: (context, index) {
                var schedule = filteredSchedules[index];
                return ScheduleCard(
                  teacherName: schedule['teacherName'],
                  teacherId: schedule['teacherId'],
                  courseTitle: schedule['courseTitle'],
                  startDate: schedule['startDate'],
                  endDate: schedule['endDate'],
                  room: schedule['room'],
                  dayOfWeek: schedule['dayOfWeek'],
                  startTime: schedule['startTime'],
                  endTime: schedule['endTime'],
                  semester: schedule['semester'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailTeaScheduleScreen(
                          scheduleId: schedule.id,
                          scheduleData: schedule.data() as Map<String, dynamic>,
                        ),
                      ),
                    );
                  },
                );
              },
            )
                : Center(
              child: Text('Không tìm thấy lịch giảng của giảng viên này'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateScheduleScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        offset: Offset(-20, -20),
      ),
    );
  }
}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final FloatingActionButtonLocation location;
  final Offset offset;

  CustomFloatingActionButtonLocation(this.location, {required this.offset});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset baseOffset = location.getOffset(scaffoldGeometry);
    return baseOffset + offset;
  }
}

class ScheduleCard extends StatelessWidget {
  final String teacherName;
  final String teacherId;
  final String courseTitle;
  final String startDate;
  final String endDate;
  final String room;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String semester;
  final VoidCallback onTap;

  ScheduleCard({
    required this.teacherName,
    required this.teacherId,
    required this.courseTitle,
    required this.startDate,
    required this.endDate,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.semester,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Giảng viên: $teacherName', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Mã giảng viên: $teacherId', style: TextStyle(fontSize: 16)),
                Text('Học kỳ: $semester', style: TextStyle(fontSize: 16)),
                Text('Môn học: $courseTitle', style: TextStyle(fontSize: 16)),
                Text('Phòng học: $room', style: TextStyle(fontSize: 16)),
                Text('Ngày: $dayOfWeek', style: TextStyle(fontSize: 16)),
                Text('Thời gian: $startTime - $endTime', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
