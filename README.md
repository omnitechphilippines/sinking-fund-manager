# 💰 Sinking Fund Manager

A Flutter app designed to help small cooperatives or families manage a sinking fund. This app enables tracking of member contributions, loans, and overall fund balance — ideal for community savings or cooperatives managed by a trusted person.

---

## 📱 Features

- 👥 **Member Management**
    - Add, edit, or remove members
    - View member details

- 💵 **Contribution Tracking**
    - Specify contribution amount per head
    - Record and track member payments
    - View contribution history

- 📄 **Loan Management**
    - Issue and track loans per member
    - Monitor loan balance and repayments
    - Set interest and repayment terms

- 📊 **Fund Overview**
    - View total funds collected
    - See outstanding loans
    - Member account summary

- 🔐 **Security**
    - Optional PIN or biometric login (coming soon)
    - Offline-first with optional backups

---

## 🛠️ Tech Stack

| Feature          | Technology |
|------------------|------------|
| Framework        | Flutter    |
| State Management | Riverpod   |
| Local Database   | Hive       |
| UI               | Material 3 |
| Export Support   | PDF, Excel |


---

## 📦 Platforms Supported

- 🌐 Web (HTML5)
- 💻 Windows
- 📱 Android

---

## 📷 Screenshots

> Screenshots from each platform

### 🖥️ Windows
- will be added later
---

### 🌐 Web
- will be added later
---

### 📱 Android
- will be added later
---

## 🌐 Live Demo

- 🔗 **Web (GitHub Pages):**  
  [Demo](https://omnitechphilippines.github.io/sinking-fund-manager/)

---

## 📦 Download Latest Releases

You can also find all versions in the [Releases Page](https://github.com/omnitechphilippines/sinking-fund-manager/releases)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `v3.38.1`
- Dart SDK `v3.10.0`

### Run the app

```bash
# Clone the repo
git clone https://github.com/your-username/sinking-fund-manager.git
cd sinking-fund-manager

# Get packages
flutter pub get

# Run the app (Web)
flutter run -d chrome

# Run the app (Windows)
flutter config --enable-windows-desktop
flutter run -d windows

# Run the app (Android)
flutter run -d android
