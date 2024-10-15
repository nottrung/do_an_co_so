import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../ad_custom_drawer.dart';
import 'add_tea_screen.dart';
import 'view_tea_profile_screen.dart';

class ListAllTeaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách giảng viên'),
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
      body: TeacherListScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddTeaScreen()));
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

class TeacherListScreen extends StatefulWidget {
  @override
  _TeacherListScreenState createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _selectedDepartment = 'All';

  final List<String> departments = [
    'All',
    'Công nghệ thông tin',
    'Cơ khí - cơ điện tử',
    'Khoa học và kĩ thuật vật liệu',
    'Kỹ thuật ô tô và năng lượng',
    'Điện - điện tử',
    'Công nghệ sinh học hóa học và kỹ thuật môi trường',
    'Kỹ thuật y học',
    'Dược',
    'Điều dưỡng',
    'Khoa học cơ bản',
    'Kinh tế và kinh doanh',
    'Du lịch',
    'Khoa đào tạo ngoại ngữ',
    'Viện đào tạo quốc tế',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey,
                size: 26,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelText: "Tìm tên hoặc mã giảng viên",
              labelStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: InputDecoration(
              filled: true,
              // fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            items: departments.map((String department) {
              return DropdownMenuItem<String>(
                value: department,
                child: Text(department),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDepartment = newValue!;
              });
            },
            isExpanded: true,
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Đã xảy ra lỗi'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              var filteredDocs = snapshot.data!.docs.where((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                bool matchesRole = data['option'] == 'teacher';
                bool matchesSearch = data['name'].toLowerCase().contains(_searchText.toLowerCase()) ||
                    data['teacherId'].toLowerCase().contains(_searchText.toLowerCase());
                bool matchesDepartment = _selectedDepartment == 'All' || data['department'] == _selectedDepartment;
                return matchesRole && matchesSearch && matchesDepartment;
              }).toList();

              filteredDocs.sort((a, b) => (a['teacherId']).compareTo(b['teacherId']));

              if (filteredDocs.isEmpty) {
                return Center(child: Text('Không tìm thấy giảng viên nào.'));
              }

              return ListView(
                children: filteredDocs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewTeaProfileScreen(teacherData: data),
                        ),
                      );
                    },
                    child: Card(
                      // color: Theme.of(context).cardColor,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      child: ListTile(
                        leading: Image.network(
                          data['imageUrl'],
                          width: 100,
                          height: 100,
                        ),
                        title: Text(
                          data['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mã giảng viên: ${data['teacherId']}'),
                            Text('Tuổi: ${data['age']}'),
                            Text('Khoa: ${data['department']}'),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
