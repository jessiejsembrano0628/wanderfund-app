# WanderFund Flutter App - Quick Start Guide

## 🎯 Project Overview

This is a production-ready Flutter application built with **Clean Architecture** principles. It includes:

✅ **Login Page** - Email/password authentication with validation
✅ **Main Menu** - User dashboard with menu options and quick links
✅ **API Service Template** - Ready-to-use HTTP client for backend integration
✅ **Dependency Injection** - GetIt service locator setup
✅ **State Management** - Provider pattern for reactive UI
✅ **Error Handling** - Comprehensive error and exception handling

## 📦 What's Included

### Architecture Layers

```
Domain Layer (Business Logic)
    ↓
Data Layer (Repositories & Data Sources)
    ↓
Presentation Layer (UI & State Management)
```

### File Structure

- **lib/core/** - Constants, error handling, API service
- **lib/domain/** - Entities, repositories, use cases
- **lib/data/** - Models, data sources, repository implementations
- **lib/presentation/** - Pages, providers, widgets

## 🚀 Getting Started

### 1. Install Dependencies

```bash
cd wanderfund_app
flutter pub get
```

### 2. Configure Backend URL

Edit `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

### 3. Run the App

```bash
flutter run
```

## 📝 API Integration Template

The `ApiService` class in `lib/core/services/api_service.dart` provides ready-made methods:

### GET Request
```dart
final response = await apiService.get(
  endpoint: '${AppConstants.baseUrl}/users',
  token: authToken,
);
```

### POST Request
```dart
final response = await apiService.post(
  endpoint: '${AppConstants.baseUrl}/auth/login',
  body: {
    'email': 'user@example.com',
    'password': 'password123',
  },
);
```

### Creating New API Endpoints

1. Add endpoint URL to `AppConstants`:
```dart
static const String newEndpoint = '$baseUrl/api/$apiVersion/new';
```

2. Create a new data source method:
```dart
Future<MyModel> fetchData() async {
  try {
    final response = await apiService.get(
      endpoint: AppConstants.newEndpoint,
      token: token,
    );
    return MyModel.fromJson(response['data']);
  } catch (e) {
    rethrow;
  }
}
```

## 🔐 Security Considerations

⚠️ **Important**: Before deploying to production:

1. **Use Secure Token Storage**
   ```bash
   flutter pub add flutter_secure_storage
   ```
   Replace hardcoded token with secure storage

2. **HTTPS Only**
   - Ensure API endpoint uses HTTPS
   - Add certificate pinning for sensitive data

3. **Input Validation**
   - All form inputs are validated
   - Extend validation as needed

## 🔄 How to Add New Features

### Example: Adding a "Posts" Feature

**Step 1: Create Entity**
```dart
// lib/domain/entities/post_entity.dart
class PostEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  // ...
}
```

**Step 2: Create Repository Interface**
```dart
// lib/domain/repositories/post_repository.dart
abstract class PostRepository {
  Future<Either<Failure, List<PostEntity>>> getPosts();
}
```

**Step 3: Create Use Case**
```dart
// lib/domain/usecases/post_usecase.dart
class GetPostsUsecase {
  final PostRepository repository;
  
  Future<Either<Failure, List<PostEntity>>> call() async {
    return await repository.getPosts();
  }
}
```

**Step 4: Create Data Source & Model**
```dart
// lib/data/datasources/post_remote_data_source.dart
// lib/data/models/post_model.dart
```

**Step 5: Implement Repository**
```dart
// lib/data/repositories/post_repository_impl.dart
```

**Step 6: Create Provider**
```dart
// lib/presentation/providers/post_provider.dart
class PostProvider extends ChangeNotifier {
  // State management logic
}
```

**Step 7: Register in Service Locator**
```dart
// lib/service_locator.dart
getIt.registerSingleton<PostRepository>(
  PostRepositoryImpl(remoteDataSource: getIt<PostRemoteDataSource>()),
);
```

**Step 8: Create UI Pages**
```dart
// lib/presentation/pages/posts_page.dart
```

## 🧪 Testing

### Add test dependencies:
```bash
flutter pub add dev:flutter_test
```

### Example unit test:
```dart
test('LoginUsecase returns user on success', () async {
  final result = await loginUsecase(
    email: 'test@example.com',
    password: 'password123',
  );
  expect(result.isRight(), true);
});
```

## 📱 Pages Included

### Login Page
- Email and password input fields
- Form validation
- Error message display
- Loading state handling
- Forgot password link (TODO)

### Main Menu Page
- User profile card
- Menu grid (Explore, Bookmarks, Favorites, History)
- Quick links (Help, Privacy, Terms)
- Logout functionality with confirmation

## 🎨 Customization

### Theme
Update the MaterialApp theme in `main.dart`:
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
),
```

### Navigation
Add new routes in `main.dart`:
```dart
routes: {
  '/new-page': (context) => const NewPage(),
},
```

## ❌ Troubleshooting

### Pub get fails
```bash
flutter clean
flutter pub get
```

### Build issues
```bash
flutter pub upgrade
flutter run --release
```

### API connection errors
1. Check `AppConstants.baseUrl`
2. Verify backend is running
3. Check network connectivity
4. Review error messages in `ApiService`

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Clean Architecture](https://resocoder.com/flutter-clean-architecture)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)

## 📝 Project Structure Visualization

```
WanderFund App
│
├── Authentication Layer
│   ├── LoginPage (UI)
│   ├── AuthProvider (State)
│   └── LoginUsecase (Business Logic)
│
├── Data Layer
│   ├── AuthRemoteDataSource (API Calls)
│   ├── AuthRepositoryImpl (Implementation)
│   └── UserModel (Data Object)
│
├── Domain Layer
│   ├── UserEntity (Business Object)
│   ├── AuthRepository (Interface)
│   └── AuthUsecase (Business Logic)
│
└── Core Layer
    ├── ApiService (HTTP Client)
    ├── AppConstants (Config)
    └── Failure/Exceptions (Error Handling)
```

## 🎓 Next Steps

1. ✅ Run `flutter pub get`
2. ✅ Update `AppConstants.baseUrl`
3. ✅ Test the login flow
4. ✅ Implement backend API endpoints
5. ✅ Add more features following the template
6. ✅ Implement local storage for authentication tokens
7. ✅ Add comprehensive error handling
8. ✅ Write unit tests
9. ✅ Deploy to production

Happy coding! 🚀
