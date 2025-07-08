# AILedger Flutter

This repository contains the Flutter client for **AutoLedger**, an application that helps small businesses manage their finances.

See [lib/README.md](lib/README.md) for setup instructions and development tips.

## Key Features

1. **Invoice & Customer Management** – create invoices, track payments and manage customer information.
2. **Expense Tracking with Receipt Scanning** – capture receipts and log expenses on the go.
3. **Comprehensive Reporting** – generate tax, customer and cash flow reports with export to PDF, CSV and JSON.
4. **AI Insights and Analytics** – leverage AI to forecast cash flow and understand payment risks.
5. **Voice Commands and Dark Mode** – navigate the app hands‑free and choose between light or dark appearance.

## Getting Started

Install Flutter 3.13 or later and run:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

You can provide additional runtime configuration using `--dart-define` flags:
```bash
flutter run \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=OPENAI_API_KEY=<your-key> \
  --dart-define=INTENT_API_URL=https://intent.example.com \
  --dart-define=INTENT_API_KEY=<optional-key>
```

Run tests with `flutter test`.