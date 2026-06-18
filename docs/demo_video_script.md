# Demonstration Video Script

Target duration: 5-10 minutes.

## 1. Introduction

Suggested duration: 30-60 seconds.

Say:

```text
This is the Journal Trend Analyzer mobile application for PRM393 Lab2. The app is built with Flutter and Dart. It uses OpenAlex as the only external data source and does not use a custom backend or authentication.
```

Show:

- Project running on Android device or emulator.
- App home/search screen.

## 2. Topic Search

Suggested duration: 1 minute.

Steps:

1. Enter a topic, for example `Artificial Intelligence`.
2. Tap `Search OpenAlex`.
3. Wait for the loading state.
4. Show publication results.

Mention:

- Data is retrieved dynamically from OpenAlex.
- Results show title, year, citation count, and journal name.

## 3. Publication Details

Suggested duration: 1 minute.

Steps:

1. Tap one publication result.
2. Show the detail screen.
3. Point out title, authors, year, citation count, journal, DOI, and abstract.

Mention:

- Some fields may be unavailable depending on OpenAlex data.
- The app handles missing DOI or abstract gracefully.

## 4. Trend Analysis

Suggested duration: 1-2 minutes.

Steps:

1. Return to the search result screen.
2. Tap `Trend`.
3. Show total publications, most active year, year range, and chart.

Mention:

- Publications are grouped by publication year.
- The chart helps identify growth or decline for the selected topic.

## 5. Top Influential Papers

Suggested duration: 1 minute.

Steps:

1. On the trend screen, show the influential paper preview.
2. Tap `View Full Ranking`.
3. Show ranked papers.

Mention:

- Ranking is based on citation count from OpenAlex.

## 6. Top Journals and Authors

Suggested duration: 1 minute.

Steps:

1. Return to the trend screen.
2. Tap `View Top Journals & Authors`.
3. Show ranked journals and ranked authors.

Mention:

- Journals and authors are ranked by publication count for the selected topic.

## 7. Research Dashboard

Suggested duration: 1 minute.

Steps:

1. Open the dashboard from the search screen or trend screen.
2. Show total publications, average citations, most active year, top journal, top author, and most influential paper.

Mention:

- The dashboard gives a quick summary of the research landscape.

## 8. AI-Assisted Code Review

Suggested duration: 1 minute.

Steps:

1. Open `docs/ai_assisted_code_review.md`.
2. Briefly show the review findings.

Mention:

- Missing Android Internet permission was found and fixed.
- README documentation was improved.
- Deliverable evidence documents were added.

## 9. Closing

Suggested duration: 30 seconds.

Say:

```text
The app satisfies the main Lab2 requirements: topic search, publication detail, trend analysis, influential papers, top journals, top authors, and dashboard analytics using OpenAlex as the data source.
```

## Recording Checklist

- Run on Android device or emulator.
- Make sure the device has Internet access.
- Use a topic that returns enough results, such as `Artificial Intelligence`, `Data Science`, or `Cybersecurity`.
- Show at least four main screens required by the assignment:
  - Search Screen.
  - Publication Detail Screen.
  - Trend Analysis Screen.
  - Research Dashboard Screen.
- Also show extra ranking screens for top papers, journals, and authors.
