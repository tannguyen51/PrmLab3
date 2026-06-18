# AI-Assisted Code Review

This document records the AI-assisted review process for the PRM393 Lab2 Journal Trend Analyzer mobile application.

## Review Scope

Reviewed areas:

- OpenAlex API integration.
- Android device readiness.
- Flutter project organization.
- Error handling and loading states.
- Feature coverage against the assignment requirements.
- Test coverage for analysis logic and main UI flows.

Tool used:

```text
Codex AI code review assistance
```

## Finding 1: Missing Internet Permission in Main Android Manifest

Severity: High

File:

```text
android/app/src/main/AndroidManifest.xml
```

Issue:

The application retrieves all publication data from OpenAlex through HTTP requests. The `INTERNET` permission existed in debug/profile manifests, but it was missing from the main Android manifest. This could cause network access issues when building or running the app outside debug-specific configurations.

Impact:

- The app may fail to retrieve OpenAlex data on Android release builds.
- The app may not satisfy the assignment requirement to run successfully on Android devices.

Fix:

Added the following permission to the main Android manifest:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Status:

Fixed.

## Finding 2: Default README Did Not Document the Real Project

Severity: Medium

File:

```text
README.md
```

Issue:

The README still contained Flutter's default template text and did not explain the app purpose, API usage, project structure, or run instructions.

Impact:

- Reviewers may not understand how the app maps to the assignment requirements.
- The repository looked incomplete even though the source code already implemented most core features.
- Setup instructions for Android device testing were missing.

Fix:

Replaced the default README with project-specific documentation covering:

- Feature list.
- OpenAlex endpoint usage.
- Folder structure.
- Requirement mapping.
- Run commands.
- Testing commands.
- Notes for Android device Internet access.

Status:

Fixed.

## Finding 3: Deliverable Evidence Was Missing

Severity: Medium

Files:

```text
docs/project_report.md
docs/ai_assisted_code_review.md
docs/demo_video_script.md
```

Issue:

The assignment requires a project report, AI-assisted code review evidence, and a demonstration video. The source code existed, but the repository did not include supporting documents to help prove these requirements.

Impact:

- The submission could lose marks for missing non-code deliverables.
- The AI-assisted review process was not documented.
- The video demo could miss required features without a script.

Fix:

Added supporting documents:

- `project_report.md` for report content that can be exported to PDF.
- `ai_assisted_code_review.md` for review findings and fixes.
- `demo_video_script.md` for a 5-10 minute demonstration flow.

Status:

Fixed for documentation. The final video still needs to be recorded by the student.

## Finding 4: Android Device Verification Should Be Explicit

Severity: Medium

Issue:

The assignment specifically states that the app must run successfully on Android devices and Android emulators. Desktop and web execution are useful during development, but they are not enough for final validation.

Impact:

- A project that works on Windows or Chrome may still fail on Android due to permissions, network, or platform configuration.

Recommendation:

Before submission, run:

```powershell
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d <android_device_id>
```

Status:

Pending final verification on the student's Android device.

## Review Summary

The core Flutter implementation covers the main functional requirements:

- Topic search.
- Publication details.
- Trend analysis.
- Top influential papers.
- Top journals.
- Top authors.
- Research dashboard.

The main improvements from this review were focused on Android readiness and submission evidence.
