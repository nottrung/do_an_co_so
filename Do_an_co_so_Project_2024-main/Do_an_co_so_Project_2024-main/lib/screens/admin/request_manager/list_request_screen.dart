import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tea_man_pka/screens/admin/request_manager/request_detail_screen.dart';

import '../ad_custom_drawer.dart';

class ListRequestScreen extends StatefulWidget {
  @override
  _ListRequestScreenState createState() => _ListRequestScreenState();
}

class _ListRequestScreenState extends State<ListRequestScreen> {
  final Set<String> hiddenRequests = Set<String>();
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách yêu cầu'),
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
          SizedBox(height: 20,),
          _buildStatusFilterDropdown(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('requests').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Không có yêu cầu nào.'));
                }

                List<DocumentSnapshot> filteredDocs = snapshot.data!.docs.where((document) {
                  if (hiddenRequests.contains(document.id)) return false;
                  if (_selectedStatus == 'All') return true;
                  return document['status'] == _selectedStatus.toLowerCase();
                }).toList();

                return ListView(
                  padding: EdgeInsets.all(10),
                  children: filteredDocs.map((DocumentSnapshot document) {
                    Map<String, dynamic> requestData = document.data() as Map<String, dynamic>;
                    String requestId = document.id;
                    return YeuCauCard(
                      requestData: requestData,
                      requestId: requestId,
                      onHide: () {
                        setState(() {
                          hiddenRequests.add(requestId);
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: DropdownButtonFormField<String>(
        value: _selectedStatus,
        items: ['All', 'Đang chờ', 'Được duyệt', 'Từ chối']
            .map((status) => DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedStatus = value!;
          });
        },
        decoration: InputDecoration(
          labelText: 'Lọc theo trạng thái',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }
}

class YeuCauCard extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final String requestId;
  final VoidCallback onHide;

  const YeuCauCard({Key? key, required this.requestData, required this.requestId, required this.onHide}) : super(key: key);

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
          return false; // Do not delete when hiding
        }
        return false; // Disallow other actions
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestDetailScreen(requestData: requestData, requestId: requestId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility_off),
                        onPressed: () {
                          // Handle hide request when eye icon is pressed
                          onHide();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã ẩn yêu cầu')),
                          );
                        },
                      ),
                    ],
                  ),
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
