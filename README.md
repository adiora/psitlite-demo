# PSIT Lite (Demo)

A lightweight Flutter app designed to provide fast access to essential academic information like attendance, marks, and class schedules.

> ⚠️ **Public Demo Notice**  
> This repository contains a UI/UX demo version of the app.  
> Backend services and production APIs are intentionally removed and replaced with mock data to protect privacy and security.

## Live App
A production build of this app (with backend services enabled) is actively used by students.

🔗 **Download:** [![N|Solid](psitlite.png)](https://psitlite.space) 

 Used by 200+ students for daily academic tracking.

## Why I built this
The existing college ERP app had performance and usability issues.  
This project explores whether a faster, cleaner ERP experience could be built using Flutter, with a focus on performance, clarity, and offline usability.

Key goals:
- **Speed** – faster load times and smoother navigation
- **Simplicity** – only the most-used academic features
- **Convenience** – one tap access to all features

## Features
- 📊 Attendance overview
- 📅 Daily timetable
- 📝 Marks summary
- 💻OLT (Online Test) Results
- 📢 Announcements
- ⚡ Offline-first caching
- 🌙 Dark mode

## How it's built
The app intentionally avoids heavy state-management frameworks to keep things simple and explicit:

- `setState` for local UI state
- `ChangeNotifier` for shared app state
- Custom widgets for reusable UI components

## Screenshots
<table align="center">
  <tr>
    <th align="center">Dashboard</th>
    <th align="center">Attendance</th>
    <th align="center">Timetable</th>
  </tr>
  <tr>
    <td><img src="screenshots/dashboard.webp" width="200"></td>
    <td><img src="screenshots/attendance.webp" width="200"></td>
    <td><img src="screenshots/timetable.webp" width="200"></td>
  </tr>
  <tr>
    <th align="center">Marks</th>
    <th align="center">OLT Marks</th>
    <th align="center">Announcements</th>
  </tr>
  <tr>
    <td><img src="screenshots/marks.webp" width="200"></td>
    <td><img src="screenshots/oltmarks.webp" width="200"></td>
    <td><img src="screenshots/announcements.webp" width="200"></td>
  </tr>
</table>

## Running the Demo
```bash
flutter pub get
flutter run
```
No additional setup is required since all data is mocked.