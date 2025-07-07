# AILedger Flutter

This repository contains the Flutter client for the AILedger application. The app integrates with a backend API to manage invoices, tasks, contacts and more.

## Getting Started

1. **Install Flutter**: Ensure you have Flutter 3.13 or later installed.
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure environment variables**:
   Provide API details at build time using `--dart-define`:
   - `API_BASE_URL` – base URL of the backend API.
   - `OPENAI_API_KEY` – key for AI insights.
   - `INTENT_API_URL` – URL for processing voice commands (optional).
   - `INTENT_API_KEY` – API key for the intent service (optional).

   Example:
   ```bash
   flutter run --dart-define=API_BASE_URL=https://api.example.com
   ```
4. **Run tests**:
   ```bash
   flutter test
   ```

## Reports

Navigate to **Reports** from the side drawer to generate tax, customer or cash flow reports. Use the date range picker to filter data and export results as PDF, CSV or JSON.

## Voice Commands

The app supports voice navigation and actions. Configure the intent API details using the `INTENT_API_URL` and `INTENT_API_KEY` defines if you plan to enable this feature.

## Sample Templates

Default email and invoice templates reside in `lib/data`. They are accessible
through `EmailTemplateService.getDefaultTemplates()` and
`InvoiceTemplateService.getDefaultTemplates()` for seeding new installs. Adjust
these examples or provide your own via the backend API.
