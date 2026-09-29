# WanderFund App

A Flutter application built with clean architecture principles, featuring login functionality, main menu, and a template for API calls to the backend.

## Project Structure

```
lib/
├── core/                          # Core layer - constants, error handling, services
│   ├── constants/
│   │   └── app_constants.dart    # App-wide constants and API endpoints
│   ├── error/
│   │   ├── failure.dart          # Error handling classes
│   │   └── exceptions.dart       # Exception definitions
│   └── services/
│       └── api_service.dart      # HTTP client for API calls
├── data/                          # Data layer - data sources and repositories
│   ├── datasources/
│   │   └── auth_remote_data_source.dart    # Remote API calls
│   ├── models/
│   │   └── user_model.dart       # Data models
│   └── repositories/
│       └── auth_repository_impl.dart       # Repository implementation
├── domain/                        # Domain layer - entities, use cases, repository interfaces
│   ├── entities/
│   │   └── user_entity.dart      # Business entities
│   ├── repositories/
│   │   └── auth_repository.dart  # Repository interfaces
│   └── usecases/
│       └── auth_usecase.dart     # Use cases
├── presentation/                  # Presentation layer - UI, state management
│   ├── pages/
│   │   ├── login_page.dart       # Login page UI
│   │   └── main_menu_page.dart   # Main menu UI
│   ├── providers/
│   │   └── auth_provider.dart    # State management using Provider
│   └── widgets/
│       └── (custom widgets)
├── service_locator.dart          # Dependency injection setup
└── main.dart                     # App entry point

```

## Clean Architecture Layers

### Core Layer
Contains app-wide constants, error handling, and service utilities that are independent of business logic.

### Data Layer
Handles data operations:
- **Data Sources**: Remote (API) and local (cache) data fetching
- **Models**: JSON serializable data models
- **Repositories**: Implementation of domain repositories

### Domain Layer
Contains business logic and interfaces:
- **Entities**: Pure business models (UI-independent)
- **Repositories**: Interfaces for data operations
- **Use Cases**: Business logic orchestration

### Presentation Layer
Handles UI and state management:
- **Pages**: Full screen widgets
- **Providers**: State management using Provider package
- **Widgets**: Reusable UI components

## Dependencies

- **http**: For making HTTP requests
- **provider**: For state management
- **get_it**: For dependency injection
- **dartz**: For functional programming (Either type)
- **equatable**: For value object comparison

## Setup & Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Update `AppConstants.baseUrl` in `lib/core/constants/app_constants.dart` with your backend URL
4. Run the app: `flutter run`

## Features

### Authentication
- Login functionality with email and password validation
- Error handling with user feedback
- Logout functionality with confirmation dialog

### Main Menu
- User profile information display
- Menu grid with options (Explore, Bookmarks, Favorites, History)
- Quick links section (Help, Privacy Policy, Terms)

### API Integration Template
The `ApiService` provides a ready-to-use template for API calls:
- GET requests
- POST requests
- PUT requests
- DELETE requests
- Automatic error handling
- Bearer token support

## API Integration Example

The app includes a complete template for backend API integration:

```dart
// Example API call using the template
Future<List<ItemModel>> fetchItems() async {
  try {
    final response = await apiService.get(
      endpoint: '${AppConstants.baseUrl}/items',
      token: userToken,
    );
    return (response['data'] as List)
        .map((item) => ItemModel.fromJson(item))
        .toList();
  } catch (e) {
    // Handle error
  }
}
```

## Error Handling

The app uses functional programming with Dartz to handle errors gracefully:

```dart
// Use cases return Either<Failure, Success>
final result = await loginUsecase(email: email, password: password);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('Success: ${user.name}'),
);
```

## State Management

Using Provider package for state management:

```dart
// Access auth state
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    return Text('User: ${authProvider.user?.name}');
  },
);
```

## Extending the App

### Adding New Features

1. **Create Entity** in `domain/entities/`
2. **Create Use Case** in `domain/usecases/`
3. **Create Repository Interface** in `domain/repositories/`
4. **Implement Repository** in `data/repositories/`
5. **Create Data Source** in `data/datasources/`
6. **Create Models** in `data/models/`
7. **Create Provider** in `presentation/providers/`
8. **Create Pages/Widgets** in `presentation/`
9. **Register in Service Locator** in `service_locator.dart`

## TODO

- [ ] Implement forgot password functionality
- [ ] Add local storage/caching with shared_preferences
- [ ] Implement profile page
- [ ] Add settings page
- [ ] Implement explore feature
- [ ] Add unit tests
- [ ] Add widget tests
- [ ] Implement push notifications
- [ ] Add image caching
- [ ] Implement offline support

## Notes

- Update `AppConstants.baseUrl` with your actual backend URL before deploying
- Implement secure token storage (use flutter_secure_storage package)
- Add comprehensive error messages based on API responses
- Follow the clean architecture pattern for new features
