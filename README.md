### KhataBook - Personal Finance Tracker

KhataBook is a comprehensive financial transaction tracking application built with Flutter. It allows users to manage customers and suppliers, track credit and debit transactions, and generate detailed transaction reports in PDF format.

## Tech Stack

- **Frontend Framework**: Flutter
- **Programming Language**: Dart
- **Database**: SQLite (using sqflite plugin)
- **State Management**: Provider
- **PDF Generation**: pdf package
- **Contact Selection**: flutter_contacts
- **File Operations**: path_provider, open_file, flutter_file_dialog
- **Date Formatting**: intl

## Features

### Contact Management
- Add customers and suppliers from device contacts
- Search contacts by name
- Display contacts with balance information
- View detailed transaction history for each contact

### Transaction Processing
- Record "You Gave" (debit) transactions
- Record "You Got" (credit) transactions
- Add transaction notes/descriptions
- View transaction history with date and time

### Financial Overview
- Dashboard with summary statistics:
  - Total amount you will give
  - Total amount you will get
  - QR collections (if applicable)
- Transaction-based balance calculation
- Real-time balance updates

### Reports & Communication
- Generate PDF transaction reports for specific contacts
- Share and save PDF reports
- Make direct calls to contacts from the application

### User Interface
- Clean, intuitive UI inspired by modern financial apps
- Color-coded transaction history (red for debit, green for credit)
- Search and filter functionality
- Responsive design for various device sizes

## State Management

The application uses the Provider pattern for state management, offering several benefits:

- **Centralized Data**: All data management is handled through the KhataBookProvider class
- **Reactive UI**: UI components automatically update when the underlying data changes
- **Code Organization**: Clear separation between data logic and UI components
- **Efficient Updates**: Only the affected parts of the UI rebuild when data changes

Key state management components:

- **KhataBookProvider**: Manages contacts, transactions, and overall application state
- **DatabaseHelper**: Handles all database operations for persistent storage
- **Transaction models**: Structured data models with clear typing and validation

## Database Structure

The application uses a SQLite database with two main tables:

### Contacts Table
- id (Primary Key)
- name
- phone
- type ('customer' or 'supplier')
- notes
- created_at

### Transactions Table
- id (Primary Key)
- contact_id (Foreign Key to Contacts)
- amount
- type ('credit' or 'debit')
- description
- date
- created_at

## Setup and Installation

1. Clone the repository:
git clone https://github.com/yourusername/khatabook.git

2. Navigate to the project directory:
cd khatabook

3. Install dependencies:
flutter pub get

4. Ensure you have the proper file structure for Android file paths:
android/app/src/main/res/xml/file_paths.xml

5. Run the application:
flutter run

## Screenshots

<p align="center">
  <img src="screenshots/WhatsApp Image 2025-04-15 at 15.08.21_4f30c366.jpg" width="30%" />
  <img src="screenshots/WhatsApp Image 2025-04-15 at 15.08.21_dae90290.jpg" width="30%" />
  <img src="screenshots/WhatsApp Image 2025-04-15 at 15.08.22_54c84d17.jpg" width="30%" />
  <img src="screenshots/WhatsApp Image 2025-04-15 at 15.08.23_b326f424.jpg" width="30%" />
</p>
