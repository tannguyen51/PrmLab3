# Journal Trend Analyzer

Flutter mobile application for PRM393 Lab2. The app helps users search a research topic, retrieve publication data from OpenAlex, and analyze publication trends through ranked lists, charts, and a research dashboard.

## Main Features

- Search publications by topic keyword using the OpenAlex Works API.
- Display publication title, publication year, citation count, journal name, and authors.
- Show detailed publication information, including DOI and abstract when available.
- Analyze publication activity by publication year.
- Visualize yearly publication trends with a chart.
- Rank the most influential papers by citation count.
- Identify top contributing journals and authors.
- Summarize insights in a research dashboard.
- Handle loading, empty, and error states.

## OpenAlex API Usage

The application uses OpenAlex as the only external data source.

Base URL:

```text
https://api.openalex.org
```

Main endpoint:

```text
GET /works?search=<topic>&per-page=20
```

The API integration is implemented in:

```text
lib/services/openalex_service.dart
```

No custom backend, authentication, authorization, or database is used.

## Project Structure

```text
lib/
  app.dart
  main.dart
  core/
    constants/
    utils/
  models/
  screens/
    search/
    detail/
    trend/
    influential/
    contributors/
    dashboard/
  services/
  state/
  widgets/
```

## Requirements Mapping

| Requirement | Implementation |
| --- | --- |
| Topic Search | `SearchScreen`, `SearchProvider`, `OpenAlexService` |
| Publication Details | `PublicationDetailScreen` |
| Publication Trend Analysis | `TrendAnalysisScreen`, `TrendAnalyzer`, `TrendChart` |
| Top Influential Papers | `TopInfluentialPapersScreen`, `InfluentialAnalyzer` |
| Top Research Journals | `TopContributorsScreen`, `ContributorsAnalyzer` |
| Top Contributing Authors | `TopContributorsScreen`, `ContributorsAnalyzer` |
| Research Trend Dashboard | `ResearchDashboardScreen`, `DashboardAnalyzer` |
| Models / Services / Screens / Widgets / State | Dedicated folders under `lib/` |
| Android Internet Access | `android/app/src/main/AndroidManifest.xml` |

## How to Run

Open a terminal at the project root:

```powershell
cd E:\Ki8\PRM\Lab2\PRM393_lab2
```

Install dependencies:

```powershell
flutter pub get
```

Check connected devices:

```powershell
flutter devices
```

Run on a real Android device:

```powershell
flutter run -d <device_id>
```

Run on Android emulator:

```powershell
flutter run -d emulator-5554
```

Run on Chrome for quick UI checking:

```powershell
flutter run -d chrome
```

Run on Windows desktop:

```powershell
flutter config --enable-windows-desktop
flutter run -d windows
```

## Testing and Quality Checks

Run static analysis:

```powershell
flutter analyze
```

Run tests:

```powershell
flutter test
```

The project includes tests for analyzers and main user flows under:

```text
test/
```

## Deliverable Documents

Supporting documents are stored in:

```text
docs/
```

- `project_report.md`: report content that can be exported to PDF.
- `ai_assisted_code_review.md`: AI-assisted review findings and fixes.
- `demo_video_script.md`: suggested 5-10 minute demo flow.

## Notes for Android Device Testing

The app requires Internet access to call OpenAlex. The main Android manifest includes:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

When testing on a real Android phone, make sure the device has a working network connection.
