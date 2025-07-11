# AILedger Flutter

AutoLedger's Flutter client helps small businesses manage finances by integrating with a backend API.

## Key Features
- **Invoice & Customer Management** – create invoices, track payments and manage customer information.
- **Expense Tracking with Receipt Scanning** – capture receipts and log expenses on the go.
- **Comprehensive Reporting** – generate tax, customer and cash flow reports with export to PDF, CSV and JSON.
- **AI Insights and Analytics** – leverage AI to forecast cash flow and understand payment risks.
- **Voice Commands and Dark Mode** – navigate the app hands‑free and choose between light or dark appearance.

## Getting Started
1. Install the Flutter SDK (version 3.13 or later) from the [Flutter install guide](https://docs.flutter.dev/get-started/install).
2. Install any required system dependencies for your platform.
3. Run `flutter doctor` to verify the installation.
4. Install project dependencies:
```bash
flutter pub get
```
5. Provide runtime configuration using `--dart-define` or environment variables:
- `API_BASE_URL` – base URL of the backend API.
- `OPENAI_API_KEY` – key for AI insights.
- `VOICE_INTENT_URL` – URL for processing voice commands (optional).
- `VOICE_API_KEY` – API key for the voice intent service (optional).
6. Run `flutter test` to ensure the SDK works properly.

Example run:
```bash
flutter run \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=OPENAI_API_KEY=<your-key> \
  --dart-define=VOICE_INTENT_URL=https://intent.example.com \
  --dart-define=VOICE_API_KEY=<optional-key>

## Reports
Navigate to **Reports** from the side drawer to generate tax, customer or cash flow reports. Use the date range picker to filter data and export results as PDF, CSV or JSON.

## Voice Commands
The app supports voice navigation and actions. Configure the intent API details using the `INTENT_API_URL` and `INTENT_API_KEY` defines if you plan to enable this feature.
The app supports voice navigation and actions. Configure the intent API details using the `VOICE_INTENT_URL` and `VOICE_API_KEY` defines if you plan to enable this feature.

## Sample Templates
Default email and invoice templates reside in `lib/data`. They are accessible through `EmailTemplateService.getDefaultTemplates()` and `InvoiceTemplateService.getDefaultTemplates()` for seeding new installs. Adjust these examples or provide your own via the backend API.

## Running Tests
```bash
flutter test

```

## License
This project is licensed under the [MIT License](LICENSE).