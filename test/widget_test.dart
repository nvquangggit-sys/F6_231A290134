// Kiểm thử widget cho Lab F6 — Dialog, SnackBar, Menu & khung điều hướng.
//
// Chạy: flutter test
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:f6_231a290134/main.dart';

void main() {
  testWidgets('Màn hình đầu có Scaffold, Drawer, NavigationBar và FAB', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Công việc'), findsOneWidget); // title AppBar
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Nộp bài Lab A11'), findsOneWidget); // việc đầu danh sách
  });

  testWidgets('Chọn tab Thống kê đếm trên dữ liệu gốc (6/17)', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Thống kê'));
    await tester.pumpAndSettle();

    expect(find.text('6 / 17'), findsOneWidget);
    expect(find.text('công việc đã hoàn thành'), findsOneWidget);
  });

  testWidgets('Hộp thoại thêm việc báo lỗi và không đóng khi để trống', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Thêm công việc'), findsOneWidget);

    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();

    expect(find.text('Không được để trống'), findsOneWidget);
    expect(find.text('Thêm công việc'), findsOneWidget); // vẫn mở
  });

  testWidgets('Thêm việc mới vào đầu danh sách', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Việc kiểm thử');
    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();

    expect(find.text('Việc kiểm thử'), findsOneWidget);
    expect(find.text('Thêm công việc'), findsNothing);
  });

  testWidgets('Giữ lâu để xóa, SnackBar có Hoàn tác khôi phục đúng vị trí', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.longPress(find.text('Nộp bài Lab A11'));
    await tester.pumpAndSettle();
    expect(find.text('Xác nhận xóa'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await tester.pumpAndSettle();

    expect(find.text('Nộp bài Lab A11'), findsNothing);
    expect(find.text('HOÀN TÁC'), findsOneWidget);

    await tester.tap(find.text('HOÀN TÁC'));
    await tester.pumpAndSettle();

    expect(find.text('Nộp bài Lab A11'), findsOneWidget);
    // Vị trí cũ là đầu danh sách: việc hoàn tác đứng trước "Họp nhóm đồ án".
    final daHoanTac = tester.getTopLeft(find.text('Nộp bài Lab A11')).dy;
    final keTiep = tester.getTopLeft(find.text('Họp nhóm đồ án')).dy;
    expect(daHoanTac, lessThan(keTiep));
  });

  testWidgets('Menu ⋮ ẩn việc đã xong nhưng Thống kê không đổi', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ẩn việc đã xong'));
    await tester.pumpAndSettle();

    expect(find.text('Ôn tập SQLite'), findsNothing); // việc đã xong bị ẩn

    await tester.tap(find.text('Thống kê'));
    await tester.pumpAndSettle();
    expect(find.text('6 / 17'), findsOneWidget); // vẫn tính trên _ds
  });

  testWidgets('NC3: bật chế độ tối đổi themeMode của MaterialApp', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Cài đặt'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chế độ tối'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
