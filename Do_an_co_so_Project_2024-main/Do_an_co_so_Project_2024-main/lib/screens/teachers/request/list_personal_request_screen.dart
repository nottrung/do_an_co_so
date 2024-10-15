import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../tea_custom_drawer.dart';
import 'add_new_request_screen.dart';

class ListPersonalRequestScreen extends StatefulWidget {
  const ListPersonalRequestScreen({super.key, required this.teacherData});

  final Map<String, dynamic> teacherData;

  @override
  _ListPersonalRequestScreenState createState() => _ListPersonalRequestScreenState();
}

class _ListPersonalRequestScreenState extends State<ListPersonalRequestScreen> {
  final Set<String> hiddenRequests = Set<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Yêu cầu'),
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
      endDrawer: TeaCustomDrawer(teacherData: widget.teacherData),
      body: ListRequest(teacherData: widget.teacherData, hiddenRequests: hiddenRequests),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewRequestScreen(teacherData: widget.teacherData),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
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

class ListRequest extends StatelessWidget {
  final Map<String, dynamic> teacherData;
  final Set<String> hiddenRequests;

  const ListRequest({super.key, required this.teacherData, required this.hiddenRequests});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('teacherId', isEqualTo: teacherData['teacherId'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Không có yêu cầu nào.'));
        }

        return ListView(
          padding: EdgeInsets.all(10),
          children: snapshot.data!.docs.where((document) {
            return !hiddenRequests.contains(document.id);
          }).map((DocumentSnapshot document) {
            Map<String, dynamic> requestData = document.data() as Map<String, dynamic>;
            String requestId = document.id;
            return YeuCauCard(
              requestData: requestData,
              requestId: requestId,
              onHide: () {
                hiddenRequests.add(requestId);
                (context as Element).markNeedsBuild(); // Refresh UI
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class YeuCauCard extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final String requestId;
  final VoidCallback onHide;

  const YeuCauCard({
    Key? key,
    required this.requestData,
    required this.requestId,
    required this.onHide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Timestamp requestTimestamp = requestData['timestamp'];

    return Dismissible(
      key: Key(requestId),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.grey,
        child: Icon(Icons.visibility_off, color: Colors.white),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Handle delete request
          try {
            await FirebaseFirestore.instance.collection('requests').doc(requestId).delete();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã xóa yêu cầu')),
            );
            return true;
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã xảy ra lỗi: $e')),
            );
            return false;
          }
        } else if (direction == DismissDirection.startToEnd) {
          // Handle hide request
          onHide();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã ẩn yêu cầu')),
          );
          return false;
        }
        return false;
      },
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ngày yêu cầu: ${_formatTimestamp(requestTimestamp)}',
                    style: TextStyle(fontSize: 16, color: Colors.grey), // Normal font size and color
                  ),
                  SizedBox(height: 10),
                  Text(
                    requestData['requestOption'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  if (requestData['requestOption'] == 'Cấp lại mật khẩu') ...[
                    Text('Mã giảng viên: ${requestData['teacherId']}'),
                    SizedBox(height: 10),
                    Text('Tên giảng viên: ${requestData['name']}'),
                    SizedBox(height: 10),
                    Text('Nội dung: ${requestData['requestContent']}'),
                    SizedBox(height: 10),
                    Text('Lý do: ${requestData['requestReason']}'),
                  ] else ...[
                    Text('Mã giảng viên: ${requestData['teacherId']}'),
                    SizedBox(height: 10),
                    Text('Tên giảng viên: ${requestData['name']}'),
                    SizedBox(height: 10),
                    Text('Khoa: ${requestData['department']}'),
                    SizedBox(height: 10),
                    Text('Môn học: ${requestData['subject']}'),
                    SizedBox(height: 10),
                    Text('Nội dung: ${requestData['requestContent']}'),
                    SizedBox(height: 10),
                    Text('Lý do: ${requestData['requestReason']}'),
                  ],
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Trạng thái: '),
                      Text(
                        requestData['status'] ?? '',
                        style: TextStyle(color: _getStatusColor(requestData['status'])),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    String formattedTime = '${dateTime.hour}:${dateTime.minute}';
    return '$formattedDate - $formattedTime';
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'đang chờ':
        return Colors.orange;
      case 'được duyệt':
        return Colors.green;
      case 'từ chối':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
