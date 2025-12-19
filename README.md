# PSIT Lite (Demo)

A lightweight Flutter app designed to provide fast access to essential academic information like attendance, marks, and class schedules.

> ⚠️ **Public Demo Notice**  
> This repository contains a UI/UX demo version of the app.  
> Backend services, Firebase configuration, and production APIs are intentionally removed and replaced with mock data to protect privacy and security.

## Why I built this
The existing college ERP app had performance and usability issues.  
This project was an attempt to explore whether a faster, cleaner alternative could be built using Flutter while keeping the feature set minimal and focused.

Key goals:
- **Speed** – faster load times and smoother navigation
- **Simplicity** – only the most-used academic features
- **Learning** – working with real-world data formats and handling unreliable responses gracefully

## Features
- 📊 Attendance overview
- 📅 Daily timetable
- 📝 Marks summary
- 💻OLT Results
- 📢 Announcements
- ⚡ Offline-first caching
- 🌙 Dark mode

## How it's built
The app intentionally avoids heavy state-management frameworks to keep things simple and explicit:

- `setState` for local UI state
- `ChangeNotifier` for shared app state
- Custom widgets for reusable UI components

## Screenshots
| Dashboard | Attendance | Timetable |
|----------|------------|-----------|
| ![](screenshots/dashboard.png) | ![](screenshots/attendance.png) | ![](screenshots/timetable.png) |

## Running the Demo
```bash
flutter pub get
flutter run
```
No additional setup is required since all data is mocked.