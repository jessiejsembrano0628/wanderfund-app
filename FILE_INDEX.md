# WanderFund App - File Index & Purpose Reference

## 📋 Quick File Reference

Use this guide to quickly locate files and understand their purpose.

---

## 🎯 Start Here

| File | Purpose |
|------|---------|
| [QUICK_START.md](QUICK_START.md) | ⭐ Read this first - Quick setup guide |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | Project overview and completion summary |
| [README_ARCHITECTURE.md](README_ARCHITECTURE.md) | Detailed architecture explanation |
| [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md) | How to integrate APIs with examples |

---

## 🔧 Core Layer Files

### Constants
| File | Purpose |
|------|---------|
| `lib/core/constants/app_constants.dart` | API endpoints, timeouts, error messages, local storage keys |

**What to do:** Update `baseUrl` with your backend API URL

### Error Handling
| File | Purpose |
|------|---------|
| `lib/core/error/failure.dart` | Failure classes for error handling (NetworkFailure, ServerFailure, etc.) |
| `lib/core/error/exceptions.dart` | Custom exception classes (NetworkException, AuthenticationException, etc.) |

**What to do:** Extend with app-specific failure and exception types

### Services
| File | Purpose |
|------|---------|
| `lib/core/services/api_service.dart` | HTTP client with GET, POST, PUT, DELETE methods, error handling, token support |

**What to do:** Customize headers or error handling if needed

---

## 📦 Data Layer Files

### Models
| File | Purpose |
|------|---------|
| `lib/data/models/user_model.dart` | User data model with JSON serialization/deserialization |

**What to do:** Create similar models for each API resource (Item, Post, etc.)

### Data Sources
| File | Purpose |
|------|---------|
| `lib/data/datasources/auth_remote_data_source.dart` | Interface and implementation for authentication API calls |

**What to do:** Create new data sources for other features (ItemDataSource, PostDataSource, etc.)

### Repositories
| File | Purpose |
|------|---------|
| `lib/data/repositories/auth_repository_impl.dart` | Implementation of AuthRepository interface, error mapping |

**What to do:** Create repository implementations for other features

---

## 🏛️ Domain Layer Files

### Entities
| File | Purpose |
|------|---------|
| `lib/domain/entities/user_entity.dart` | Pure Dart object representing user business entity |

**What to do:** Create entities for each business model (Item, Post, etc.)

### Repositories (Interfaces)
| File | Purpose |
|------|---------|
| `lib/domain/repositories/auth_repository.dart` | Abstract interface for authentication operations |

**What to do:** Create repository interfaces for other features

### Use Cases
| File | Purpose |
|------|---------|
| `lib/domain/usecases/auth_usecase.dart` | LoginUsecase, LogoutUsecase, GetCurrentUserUsecase |

**What to do:** Create use cases for each operation (GetItemsUsecase, CreatePostUsecase, etc.)

---

## 🎨 Presentation Layer Files

### Pages
| File | Purpose |
|------|---------|
| `lib/presentation/pages/login_page.dart` | Login UI with email/password fields, validation, error display |
| `lib/presentation/pages/main_menu_page.dart` | Main dashboard with user info, menu grid, quick links |

**What to do:** Create new pages for other features (ItemsPage, ProfilePage, etc.)

### State Management (Providers)
| File | Purpose |
|------|---------|
| `lib/presentation/providers/auth_provider.dart` | AuthProvider for managing authentication state |

**What to do:** Create providers for other features (ItemProvider, ProfileProvider, etc.)

### Widgets
| File | Purpose |
|------|---------|
| `lib/presentation/widgets/` | Directory for reusable custom widgets |

**What to do:** Create custom buttons, cards, loaders, etc.

---

## 🚀 Main Application Files

| File | Purpose |
|------|---------|
| `lib/service_locator.dart` | Dependency injection setup with GetIt, registers all services |
| `lib/main.dart` | Application entry point, theme setup, routing, MultiProvider setup |
| `pubspec.yaml` | Project configuration and dependency list |

**What to do:** 
- Update `service_locator.dart` when adding new features
- Update `pubspec.yaml` when adding new packages
- Customize `main.dart` theme and routing as needed

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `QUICK_START.md` | Setup guide and quick reference (START HERE!) |
| `PROJECT_SUMMARY.md` | Project completion summary and next steps |
| `README_ARCHITECTURE.md` | Detailed clean architecture explanation |
| `API_INTEGRATION_GUIDE.md` | Step-by-step API integration with examples |
| `FILE_INDEX.md` | This file - Quick reference for all files |

---

## 🔄 Feature Addition Checklist

When adding a new feature, follow this checklist:

```
✓ 1. Create Entity (lib/domain/entities/my_entity.dart)
✓ 2. Create Model (lib/data/models/my_model.dart)
✓ 3. Create Data Source (lib/data/datasources/my_data_source.dart)
✓ 4. Create Repository Interface (lib/domain/repositories/my_repository.dart)
✓ 5. Implement Repository (lib/data/repositories/my_repository_impl.dart)
✓ 6. Create Use Cases (lib/domain/usecases/my_usecases.dart)
✓ 7. Create Provider (lib/presentation/providers/my_provider.dart)
✓ 8. Create Page/Widgets (lib/presentation/pages/my_page.dart)
✓ 9. Register in Service Locator (lib/service_locator.dart)
✓ 10. Add Routes in Main (lib/main.dart)
```

---

## 📊 Layer Dependency Diagram

```
Presentation Layer (UI)
    ↓ (depends on)
Domain Layer (Business Logic)
    ↓ (depends on)
Data Layer (Repositories)
    ↓ (depends on)
Core Layer (Services, Constants)
```

**Rule:** Never depend upward. Lower layers should never import from upper layers.

---

## 🎯 Common Tasks & Where to Find Them

### Adding a New API Endpoint
1. Add to `lib/core/constants/app_constants.dart`
2. Create method in data source (lib/data/datasources/)
3. Follow `API_INTEGRATION_GUIDE.md`

### Adding Error Handling
1. Define failure in `lib/core/error/failure.dart`
2. Define exception in `lib/core/error/exceptions.dart`
3. Handle in repository implementation

### Adding State Management
1. Create provider in `lib/presentation/providers/`
2. Use `Consumer` widget in pages
3. Register in `service_locator.dart`

### Adding Navigation
1. Add route in `main.dart`
2. Use `Navigator.pushNamed()` to navigate

### Adding Validation
1. Add validators in form fields
2. Use formKey to validate before submission

---

## 🔍 File Organization Summary

```
lib/
├── core/              ← App-wide utilities
├── data/              ← API calls & models
├── domain/            ← Business logic
├── presentation/      ← UI & state
├── main.dart          ← Entry point
└── service_locator.dart ← Dependency injection
```

---

## 🔗 Important Connections

| If you want to... | Go to... |
|---|---|
| Change API URL | `lib/core/constants/app_constants.dart` |
| Add new API endpoint | `lib/data/datasources/`, `lib/core/constants/app_constants.dart` |
| Handle new error type | `lib/core/error/failure.dart`, `lib/core/error/exceptions.dart` |
| Add loading state | `lib/presentation/providers/` |
| Change app theme | `lib/main.dart` |
| Add new route | `lib/main.dart` |
| Add dependency | `pubspec.yaml` then `lib/service_locator.dart` |
| Add new page | Create in `lib/presentation/pages/` and add route in `lib/main.dart` |
| Add new provider | Create in `lib/presentation/providers/` and register in `lib/service_locator.dart` |

---

## ✅ Checklist: After Project Creation

- [ ] Read QUICK_START.md
- [ ] Update `AppConstants.baseUrl` in `lib/core/constants/app_constants.dart`
- [ ] Run `flutter pub get`
- [ ] Run `flutter run` to test
- [ ] Test login page UI
- [ ] Test main menu page UI
- [ ] Implement backend API endpoints
- [ ] Test actual login flow
- [ ] Add secure token storage
- [ ] Add more features following the template

---

## 🆘 Troubleshooting

| Problem | Solution | File |
|---|---|---|
| API 404 errors | Check endpoint URL | `lib/core/constants/app_constants.dart` |
| Login not working | Check API response format | `lib/data/datasources/auth_remote_data_source.dart` |
| State not updating | Check provider refresh | `lib/presentation/providers/auth_provider.dart` |
| Dependency errors | Run `flutter pub get` | `pubspec.yaml` |
| Build errors | Run `flutter clean` then `flutter pub get` | - |

---

## 📞 Quick Reference

**Project Structure:** `wanderfund_app/`

**Dependencies:** http, provider, get_it, equatable, dartz

**Main Entry Point:** `lib/main.dart`

**Service Setup:** `lib/service_locator.dart`

**API Configuration:** `lib/core/constants/app_constants.dart`

**State Management:** `lib/presentation/providers/`

---

This index will help you quickly navigate and understand the project structure!
