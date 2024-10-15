class Category {
  String thumbnail;
  String name;

  Category({
    required this.name,
    required this.thumbnail,
  });
}

List<Category> categoryList = [
  Category(
    name: 'Thông Tin',
    thumbnail: 'assets/icons/tea_inf.png',
  ),
  Category(
    name: 'Lịch Giảng',
    thumbnail: 'assets/icons/schedule.jpeg',
  ),
  Category(
    name: 'Yêu Cầu',
    thumbnail: 'assets/icons/ycau.png',
  ),
];

List<Category> categoryList3 = [
  Category(
    name: 'Lịch Giảng',
    thumbnail: 'assets/icons/schedule.jpeg',
  ),
  Category(
    name: 'Gửi Yêu Cầu',
    thumbnail: 'assets/icons/ycau.png',
  ),
  Category(
    name: 'Danh Sách Giảng Viên',
    thumbnail: 'assets/icons/tea_acc.png',
  ),
  Category(
    name: 'Lương',
    thumbnail: 'assets/icons/salary_2.jpg',
  ),
];

