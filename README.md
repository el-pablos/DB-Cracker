# PDDIKTI Flutter App

A Flutter application that uses the PDDIKTI API from Kemdikbud to search for and view student data.

## Features

- Search for students by name (case-insensitive)
- View detailed student information
- Clean and modern UI design
- Error handling and loading states

## Getting Started

### Prerequisites

- Flutter (version 2.19.0 or higher)
- Dart (version 2.19.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone this repository
   ```bash
   git clone https://github.com/yourusername/pddikti_flutter.git
   ```

2. Navigate to the project directory
   ```bash
   cd pddikti_flutter
   ```

3. Install dependencies
   ```bash
   flutter pub get
   ```

4. Run the application
   ```bash
   flutter run
   ```

## Architecture

This application follows a simple architecture with:
- Models for data representation
- API service for network requests
- Screens for UI
- Widgets for reusable UI components
- Utils for constants and helper functions

## API

This app uses the unofficial PDDIKTI API wrapper, which provides access to various data from [PDDIKTI Kemdikbud](https://pddikti.kemdikbud.go.id/). The API allows searching for students, lecturers, universities, and study programs.

## Screenshots

[Add screenshots here]

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [IlhamriSKY](https://github.com/IlhamriSKY) for the PDDIKTI-kemdikbud-API Python wrapper that inspired this Flutter implementation.