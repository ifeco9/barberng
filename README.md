# BarberNG - Barber Shop Management App

A Flutter application for connecting barbers with customers, managing appointments, and providing a seamless booking experience.

## Features

- **User Authentication**: Separate flows for barbers and customers
- **Appointment Booking**: Customers can book appointments with barbers
- **Profile Management**: Both barbers and customers can manage their profiles
- **Service Management**: Barbers can manage their services and availability
- **Location Services**: Find barbers near you
- **Real-time Updates**: Get instant notifications about appointments

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Firebase account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/barberng.git
cd barberng
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the `google-services.json` file to `android/app/`
   - Download and add the `GoogleService-Info.plist` file to `ios/Runner/`
   - Enable Authentication, Firestore, and Storage in Firebase Console

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/           # Data models
├── screens/          # UI screens
│   ├── auth/         # Authentication screens
│   ├── barber/       # Barber-specific screens
│   ├── customer/     # Customer-specific screens
│   └── onboarding/   # Onboarding screens
├── services/         # Business logic and API calls
├── utils/            # Utility functions
├── main.dart         # Entry point
└── wrapper.dart      # Authentication wrapper
```

## Known Issues

- Firebase persistence is only supported on web platforms
- Provider installer warning on some Android devices (doesn't affect functionality)
- Location services may require manual permission on some devices

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend services
- All contributors who have helped with the project
