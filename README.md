# Cozy Feelings - Mood Tracker ![Status](https://img.shields.io/badge/Status-Completed-green)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) 
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material Design 3](https://img.shields.io/badge/Material_Design_3-757575?style=for-the-badge&logo=materialdesign&logoColor=white)

**Cozy Feelings** is a minimal, warm, and safe space designed for emotional well-being. Built with **Flutter**, this application focuses on simplicity to help users track their daily moods and thoughts without the clutter of traditional journals. It’s about checking in with yourself in a cozy and calm environment.

## 🚀 Key Features

- **Daily Mood Tracking:** A simple interface to log how you feel using intuitive and friendly icons.
- **Thought Dumping:** An open space to write whatever is on your mind—no judgment, just emotional release.
- **Mood History:** A visual history to review your emotional journey and entries over time.
- **Cozy UI/UX:** A carefully selected color palette and smooth animations designed to reduce anxiety.
- **Privacy Focused:** All logs are managed locally to ensure personal reflection remains private.

## 🛠️ Tech Stack

### Frontend
- **Framework:** [Flutter](https://flutter.dev/) (Cross-platform)
- **Language:** [Dart](https://dart.dev/)
- **UI Architecture:** Material Design 3 for a modern and accessible feel.
- **State Management:** Native state management for efficient data flow.

### Logic & Storage
- **Local Persistence:** [Shared Preferences / SQLite] (Adjust according to your choice) to store mood entries securely on the device.
- **Date Handling:** Internationalization and formatting for chronological history.

## 📝 Project Architecture

The application is built with a focus on **Clean Code** and modularity:

| Layer | Responsibility |
| :--- | :--- |
| **UI / Screens** | Handles user interaction, mood selection, and history visualization. |
| **Business Logic** | Manages the processing of daily entries and thought validation. |
| **Data Layer** | Responsible for CRUD operations on the device's local storage. |

## ⚙️ Development Setup

To run this project locally, you need to have the Flutter SDK installed on your machine.

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/your-username/cozy-feelings.git](https://github.com/your-username/cozy-feelings.git)
   cd cozy-feelings
