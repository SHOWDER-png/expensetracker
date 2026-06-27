# Expense Tracker — Flutter

แปลงจาก React + shadcn/ui → Flutter (Dart)

## โครงสร้าง

```
lib/
└── main.dart    ← ทุกอย่างอยู่ในไฟล์เดียว (single-file app)
```

## หน้าจอที่มี

| หน้า | คำอธิบาย |
|------|-----------|
| **Home (Overview)** | Balance card, แผนภูมิการใช้จ่าย 6 เดือน, รายการล่าสุด 5 รายการ |
| **Activity** | ค้นหาและกรองรายการ (All / Expense / Income) |
| **Budget** | สรุปยอดใช้จ่าย, progress bar, breakdown ตามหมวดหมู่ |
| **Add Modal** | กรอกรายการใหม่ (bottom sheet) |

## การติดตั้ง

```bash
flutter pub get
flutter run
```

## สิ่งที่แปลงจาก React → Flutter

| React/shadcn | Flutter |
|-------------|---------|
| `BarChart` (recharts) | `CustomPainter` |
| `useState` | `StatefulWidget + setState` |
| `useMemo` | computed getter |
| Tailwind CSS | `BoxDecoration`, `TextStyle`, `EdgeInsets` |
| shadcn `Card` | `Container` + border + borderRadius |
| `LinearProgressIndicator` (CSS) | Flutter `LinearProgressIndicator` |
| Bottom nav + FAB | `Stack` + custom nav |
| Modal (fixed overlay) | `Stack` overlay |

## Color Palette (จาก theme.css เดิม)

- Background: `#F5F4F0`
- Card: `#FFFFFF`
- Primary: `#1C1C28`
- Accent/Income: `#1E6B4A`
- Muted: `#ECEAE6`
- Muted text: `#8A8880`
