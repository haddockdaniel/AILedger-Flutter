# AILedger Flutter

AutoLedger's Flutter client helps small businesses manage finances by integrating with a backend API.

## Key Features
- **Invoice & Customer Management** – create invoices, track payments and manage customer information.
- **Expense Tracking with Receipt Scanning** – capture receipts and log expenses on the go.
- **Comprehensive Reporting** – generate tax, customer and cash flow reports with export to PDF, CSV and JSON.
- **AI Insights and Analytics** – leverage AI to forecast cash flow and understand payment risks.
- **Voice Commands and Dark Mode** – navigate the app hands‑free and choose between light or dark appearance.

## Getting Started
1. Install Flutter 3.13 or later.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Provide runtime configuration using `--dart-define`:
   - `API_BASE_URL` – base URL of the backend API.
   - `OPENAI_API_KEY` – key for AI insights.
   - `INTENT_API_URL` – URL for processing voice commands (optional).
   - `INTENT_API_KEY` – API key for the intent service (optional).

Example run:
```bash
flutter run \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=OPENAI_API_KEY=<your-key> \
  --dart-define=INTENT_API_URL=https://intent.example.com \
  --dart-define=INTENT_API_KEY=<optional-key>
  --dart-define=OPENAI_API_KEY=<your-key>

## Reports
Navigate to **Reports** from the side drawer to generate tax, customer or cash flow reports. Use the date range picker to filter data and export results as PDF, CSV or JSON.

## Voice Commands
The app supports voice navigation and actions. Configure the intent API details using the `INTENT_API_URL` and `INTENT_API_KEY` defines if you plan to enable this feature.
Voice settings allow you to disable the assistant, run recognition offline only and map your own phrases to intents. Open the **Voice Settings** screen to customize these options.

## Sample Templates
Default email and invoice templates reside in `lib/data`. They are accessible through `EmailTemplateService.getDefaultTemplates()` and `InvoiceTemplateService.getDefaultTemplates()` for seeding new installs. Adjust these examples or provide your own via the backend API.

## Running Tests
```bash
flutter test
```