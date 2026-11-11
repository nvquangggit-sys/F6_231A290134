# Lab F6 — Dialog, SnackBar, Menu & khung điều hướng Flutter

**Sinh viên:** Nguyễn Việt Quang — **MSSV:** 231A290134
**Môn:** Lập trình thiết bị di động (INT4211)
**Thiết bị kiểm thử:** Pixel 6 API 34 (Android 14, x86_64) — 1080 × 2400, điều hướng 3 nút
**Flutter 3.47.3 (stable) · Dart 3.13.3 · Material 3**

Ứng dụng quản lý công việc minh hoạ toàn bộ nội dung Lab F6: dựng khung màn hình bằng một
`Scaffold` duy nhất (AppBar, Drawer, body, NavigationBar, FAB); `NavigationDrawer` và
`NavigationBar` cùng điều khiển một biến trạng thái `_tab`; `showDialog` trả về `Future` và
xử lý đúng trường hợp `null`; hộp thoại nhập liệu có validate, không đóng khi dữ liệu sai;
`SnackBar` + `SnackBarAction` cho chức năng Hoàn tác; `PopupMenuButton` và
`showModalBottomSheet` cho hai kiểu menu.

| | |
|---|---|
| Báo cáo (PDF) | [`docs/BaoCao_LabF6_231A290134.pdf`](docs/BaoCao_LabF6_231A290134.pdf) |
| Báo cáo (Word) | [`docs/BaoCao_LabF6_231A290134.docx`](docs/BaoCao_LabF6_231A290134.docx) |
| Video demo (1 phút 08 giây) | [`docs/F6_231A290134_demo.mp4`](docs/F6_231A290134_demo.mp4) |

## Chức năng

- **Khung màn hình** — `Scaffold(appBar, drawer, body, bottomNavigationBar, floatingActionButton)`.
  Có `drawer` nên AppBar tự thêm nút ba gạch; FAB chỉ hiện ở tab Công việc.
- **Drawer + NavigationBar** — cả hai đọc/ghi chung `_tab`, nên chọn ở Drawer thì thanh dưới sáng
  theo và ngược lại; `onDestinationSelected` của Drawer gọi `Navigator.pop(context)` để tự đóng.
- **Thống kê** — luôn đếm trên `_ds` (dữ liệu gốc), không phụ thuộc bộ lọc hiển thị.
- **Hộp thoại xác nhận** — `showDialog<bool>` + `AlertDialog`; kết quả `bool?` được chuẩn hoá bằng
  `dongY ?? false` nên chạm ra ngoài (null) nghĩa là không xóa.
- **Hộp thoại nhập liệu** — `Form` + `TextFormField` có validator; `Navigator.pop` chỉ nằm trong
  nhánh `validate()` nên hộp thoại không đóng khi dữ liệu sai. Tách thành `StatefulWidget` riêng
  để `TextEditingController` được `dispose()` đúng lúc.
- **Xóa + Hoàn tác** — `_xoa()` giữ lại đối tượng và chỉ số cũ, `SnackBarAction` chèn lại bằng
  `_ds.insert(i, cv)` đúng vị trí; gọi `hideCurrentSnackBar()` trước để không xếp hàng.
- **Hai kiểu menu** — `PopupMenuButton` trong `actions` của AppBar (ẩn/hiện việc đã xong, xóa các
  việc đã xong) và `showModalBottomSheet` khi chạm một dòng (đổi trạng thái, xóa).

### Bài nâng cao (đề yêu cầu ≥ 2, đã làm 3)

| Mã | Nội dung |
|---|---|
| NC1 | `IndexedStack` giữ nguyên vị trí cuộn của từng tab (so với switch expression) |
| NC2 | `Dismissible` vuốt sang trái để xóa, dùng `ValueKey(cv.id)` ổn định, vẫn hỏi lại và vẫn có Hoàn tác |
| NC3 | Chế độ tối bằng `Switch` trong tab Cài đặt; `themeMode` đặt trên `MaterialApp` |

NC4 (`showDatePicker`) không chọn vì thêm hạn chót kéo theo đổi model, định dạng ngày và xử lý
`null`/`mounted` ở một luồng mới — ba bài đã chọn đều trực tiếp cải thiện các thao tác bắt buộc.

## Cấu trúc mã nguồn

```
lib/main.dart                 # toàn bộ ứng dụng, ~470 dòng
test/widget_test.dart         # 7 bài kiểm thử widget
docs/screenshots/             # 23 ảnh chụp từ máy ảo (adb, không dàn dựng)
docs/logs/                    # flutter_analyze.txt, phan_tich.txt
docs/F6_231A290134_demo.mp4   # video demo
```

`lib/main.dart` chia bốn khối:

| Khối | Nội dung |
|---|---|
| `MyApp` (`_MyAppState`) | `MaterialApp`, `theme`/`darkTheme`/`themeMode`; giữ biến `_toi` cho NC3 |
| `CongViec` | Model bất biến: `id` (khoá ổn định cho `Dismissible`), `tieuDe`, `xong`, `copyWith` |
| `HomeShell` (`_HomeShellState`) | Trạng thái `_tab`, `_hienDaXong`, `_ds`; thêm/xóa/đổi trạng thái; dựng toàn bộ khung |
| `_ThemCongViecDialog` | Hộp thoại nhập liệu, tự quản lý và `dispose` controller |

Hai điểm khác mã nguồn mẫu của đề, đều phát sinh từ lỗi gặp khi chạy thật:

- Model có thêm `id` tăng dần — `Dismissible` bắt buộc key duy nhất và ổn định; dùng
  `ValueKey(tieuDe)` sẽ báo lỗi *“Duplicate keys found”* khi hai việc trùng tên.
- Hộp thoại nhập liệu tách thành `StatefulWidget` — cách `dispose()` controller ngay sau
  `await showDialog` trong mã mẫu gây `Failed assertion: '_dependents.isEmpty'` trên
  Flutter 3.47 (chi tiết ở Mục 5.3 của báo cáo).

## Cách chạy

```bash
flutter pub get
flutter run                 # hoặc: flutter build apk --debug
```

## Kết quả kiểm tra

```
$ flutter analyze
Analyzing F6_231A290134...
No issues found! (ran in 1.4s)

$ flutter test
00:03 +7: All tests passed!
```

## Minh chứng

Ảnh chụp màn hình thật (adb, không dàn dựng) nằm trong [`docs/screenshots/`](docs/screenshots):

| Tệp | Nội dung |
|---|---|
| `f6_home.png` | Màn hình Công việc — AppBar, 17 việc mẫu, NavigationBar 3 mục, FAB |
| `f6_drawer.png` | Drawer mở từ mép trái — header + 3 mục |
| `f6_stats.png` | Chọn Thống kê từ Drawer — Drawer đóng, thanh dưới sáng đúng mục, 6/17 |
| `f6_dialog.png` · `f6_dialog_loi.png` · `f6_dialog_typed.png` | Hộp thoại Thêm — focus, lỗi khi để trống, đã nhập |
| `f6_them.png` | Việc mới nằm ở đầu danh sách (18 việc) |
| `f6_xacnhan.png` · `f6_snackbar.png` · `f6_undo.png` | Giữ lâu hỏi xóa → SnackBar Hoàn tác → khôi phục đúng vị trí |
| `f6_huy.png` | Chạm ra ngoài hộp thoại — không xóa gì |
| `f6_menu.png` · `f6_loc.png` · `f6_stats_loc.png` | Menu ⋮, sau khi ẩn việc đã xong (12/18), Thống kê vẫn 6/18 |
| `f6_nc1_a.png` · `f6_nc1_b.png` · `f6_nc1_c.png` | NC1 — cuộn cuối, sang tab khác, quay lại vẫn đúng vị trí |
| `f6_nc2_swipe.png` · `f6_nc2_xacnhan.png` | NC2 — đang vuốt (nền đỏ) và vẫn hỏi lại trước khi xóa |
| `f6_caidat.png` · `f6_dark.png` · `f6_dark_list.png` | NC3 — công tắc tắt, bật chế độ tối, danh sách theo theme tối |
| `f6_analyze.png` | Cửa sổ PowerShell thật chạy `flutter analyze` |

Log của các thí nghiệm phục vụ 3 câu hỏi phân tích nằm trong [`docs/logs/`](docs/logs):
`flutter_analyze.txt` (kết quả cuối) và `phan_tich.txt` (nguyên văn cảnh báo của từng thí nghiệm,
kèm SHA-256 chứng minh `lib/main.dart` đã được khôi phục sau mỗi lần sửa).
