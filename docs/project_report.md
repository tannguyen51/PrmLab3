# PRM393 Lab2 Project Report

## Journal Trend Analyzer Mobile Application

Student: `<Student Name>`

Student ID: `<Student ID>`

Course: PRM393 - Mobile Programming

Platform: Flutter and Dart

## 1. Project Overview

Journal Trend Analyzer is a Flutter-based mobile application that retrieves scholarly publication data from OpenAlex and presents analytical insights for a selected research topic.

The application allows users to enter a topic keyword such as Artificial Intelligence, Software Engineering, Data Science, Cybersecurity, Internet of Things, or Blockchain. It then retrieves publication data dynamically from the OpenAlex Works API and displays search results, publication details, trend charts, ranked influential papers, top journals, top authors, and a summary dashboard.

The app does not use a custom backend, database, user authentication, authorization, cloud persistence, or admin features. All publication data is loaded directly from OpenAlex.

## 2. Assignment Requirement Coverage

| Requirement | Status | Implementation |
| --- | --- | --- |
| Topic Search | Completed | Users can search by topic keyword on the search screen. |
| Publication Details | Completed | Users can open detail information for each publication. |
| Publication Trend Analysis | Completed | Publications are grouped by year and displayed in a chart. |
| Top Influential Papers | Completed | Publications are ranked by citation count. |
| Top Research Journals | Completed | Journals are ranked by publication count. |
| Top Contributing Authors | Completed | Authors are ranked by publication count. |
| Research Trend Dashboard | Completed | Dashboard summarizes total publications, average citations, most active year, top journal, top author, and most influential paper. |
| OpenAlex API only | Completed | The app uses OpenAlex as the only external data source. |
| Flutter and Dart | Completed | The application is implemented using Flutter and Dart. |
| Android Device Support | Implemented | Android project exists and Internet permission is declared in the main manifest. |
| AI-Assisted Code Review | Documented | Review findings are recorded in `docs/ai_assisted_code_review.md`. |

## 3. System Design

The application follows a layered structure to keep responsibilities separated.

```text
lib/
  models/      Data objects parsed from OpenAlex responses
  services/    API access and external data retrieval
  state/       State management and analysis logic
  screens/     Main application screens
  widgets/     Reusable UI components
  core/        Shared constants and utility classes
```

### 3.1 Data Flow

1. The user enters a topic on the Search Screen.
2. `SearchProvider` receives the topic and starts the loading state.
3. `PublicationRepository` calls `OpenAlexService`.
4. `OpenAlexService` sends a request to the OpenAlex Works API.
5. JSON responses are parsed into `Publication` models.
6. UI screens consume the resulting publication list.
7. Analyzer classes compute charts, rankings, and dashboard metrics.

### 3.2 State Management

The project uses the `provider` package for dependency injection and state management.

Important classes:

- `SearchProvider`: manages current topic, loading state, error message, and publication results.
- `TrendAnalyzer`: groups publications by publication year.
- `InfluentialAnalyzer`: ranks publications by citation count.
- `ContributorsAnalyzer`: ranks journals and authors by publication count.
- `DashboardAnalyzer`: builds high-level dashboard metrics.

## 4. API Integration

The application integrates with OpenAlex through:

```text
lib/services/openalex_service.dart
```

Base URL:

```text
https://api.openalex.org
```

Endpoint:

```text
GET /works
```

Query parameters:

```text
search=<topic>
per-page=20
```

Example:

```text
https://api.openalex.org/works?search=Artificial%20Intelligence&per-page=20
```

Data extracted from OpenAlex:

- Work ID.
- Title.
- Publication year.
- Citation count.
- Journal/source name.
- Author display names.
- DOI.
- Abstract inverted index.

The abstract is reconstructed from OpenAlex's `abstract_inverted_index` field by ordering words according to their positions.

## 5. Implemented Screens

### 5.1 Search Screen

The Search Screen allows users to enter a topic keyword and retrieve live publication data from OpenAlex. It also displays loading, error, empty, and result states.

Main file:

```text
lib/screens/search/search_screen.dart
```

### 5.2 Publication Detail Screen

The detail screen displays publication title, authors, publication year, citation count, journal name, DOI, and abstract when available.

Main file:

```text
lib/screens/detail/publication_detail_screen.dart
```

### 5.3 Trend Analysis Screen

The trend screen groups publications by year and visualizes publication activity with a bar chart. It also previews influential papers, journals, authors, and dashboard information.

Main file:

```text
lib/screens/trend/trend_analysis_screen.dart
```

### 5.4 Top Influential Papers Screen

This screen ranks publications from highest to lowest citation count.

Main file:

```text
lib/screens/influential/top_influential_papers_screen.dart
```

### 5.5 Top Journals and Authors Screen

This screen presents ranked journals and authors according to the number of related publications.

Main file:

```text
lib/screens/contributors/top_contributors_screen.dart
```

### 5.6 Research Dashboard Screen

The dashboard summarizes key insights for the selected topic:

- Total publications.
- Average citation count.
- Most active publication year.
- Top journal.
- Top author.
- Most influential paper.

Main file:

```text
lib/screens/dashboard/research_dashboard_screen.dart
```

## 6. Error Handling and User Experience

The app includes:

- Loading indicator while waiting for OpenAlex.
- Empty state when no publications match the topic.
- Error state when API requests fail.
- Retry action after errors.
- Pull-to-refresh for the current topic.
- Navigation between list, details, trend analysis, rankings, and dashboard screens.

## 7. Testing

The project includes automated tests under:

```text
test/
```

Covered areas:

- Search screen rendering.
- Opening publication details from a search result.
- Opening the dashboard from the search screen.
- Trend analyzer logic.
- Influential paper ranking.
- Contributor ranking.
- Dashboard summary computation.

Recommended commands:

```powershell
flutter analyze
flutter test
```

## 8. AI-Assisted Code Review

AI-assisted review was used to identify issues and improvement opportunities.

Key findings:

1. Missing Internet permission in the main Android manifest.
2. Default README did not document the actual project.
3. Deliverable evidence files were missing.
4. Android device verification should be explicit before submission.

Details are documented in:

```text
docs/ai_assisted_code_review.md
```

## 9. Challenges

OpenAlex returns data in a structure that requires careful parsing. For example, abstracts are not returned as a plain string; they are returned as an inverted index. The app solves this by reconstructing the abstract in the `Publication` model.

Another challenge is that some publications may not include journal names, DOI values, authors, abstracts, or publication years. The app handles these cases with fallback labels such as "Unknown journal", "Unknown authors", and "Abstract not available."

## 10. Lessons Learned

This project helped reinforce:

- Consuming REST APIs from Flutter.
- Parsing dynamic JSON data.
- Managing asynchronous loading and error states.
- Organizing Flutter code into maintainable layers.
- Using provider for state management.
- Building charts and dashboards for analytical data.
- Preparing evidence and documentation for software submission.

## 11. Conclusion

Journal Trend Analyzer satisfies the main goals of the PRM393 Lab2 assignment. It retrieves real publication data from OpenAlex, analyzes research activity for selected topics, and presents insights through a mobile-friendly Flutter interface.

Before final submission, the app should be tested on a real Android device and the student should export this report to PDF and record the demonstration video.
