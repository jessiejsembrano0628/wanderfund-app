# API Integration Guide

This guide explains how to integrate your backend API with the WanderFund app using the clean architecture pattern.

## Architecture Overview

```
User Request
    ↓
Presentation Layer (UI/Pages)
    ↓
Provider (State Management)
    ↓
Use Case (Business Logic)
    ↓
Repository (Data abstraction)
    ↓
Data Source (API/Database)
    ↓
API Service (HTTP Client)
    ↓
Backend API
```

## Step-by-Step Integration

### 1. Define API Endpoints

**File: `lib/core/constants/app_constants.dart`**

```dart
class AppConstants {
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1';

  // Add your endpoints here
  static const String loginEndpoint = '$baseUrl/api/$apiVersion/auth/login';
  static const String logoutEndpoint = '$baseUrl/api/$apiVersion/auth/logout';
  static const String getUserEndpoint = '$baseUrl/api/$apiVersion/user';
  
  // Add more endpoints as needed
  static const String getItemsEndpoint = '$baseUrl/api/$apiVersion/items';
  static const String createItemEndpoint = '$baseUrl/api/$apiVersion/items';
  static const String updateItemEndpoint = '$baseUrl/api/$apiVersion/items';
  static const String deleteItemEndpoint = '$baseUrl/api/$apiVersion/items';
}
```

### 2. Create Data Models

**File: `lib/data/models/item_model.dart`**

```dart
import '../../domain/entities/item_entity.dart';

class ItemModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final DateTime createdAt;

  const ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.createdAt,
  });

  // From JSON
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // To Entity
  ItemEntity toEntity() {
    return ItemEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, price, createdAt];
}
```

### 3. Create Domain Entities

**File: `lib/domain/entities/item_entity.dart`**

```dart
class ItemEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final DateTime createdAt;

  const ItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, description, price, createdAt];
}
```

### 4. Create Data Source Interface and Implementation

**File: `lib/data/datasources/item_remote_data_source.dart`**

```dart
abstract class ItemRemoteDataSource {
  Future<List<ItemModel>> getItems();
  Future<ItemModel> getItem(String id);
  Future<ItemModel> createItem(ItemModel item);
  Future<ItemModel> updateItem(ItemModel item);
  Future<void> deleteItem(String id);
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final ApiService apiService;

  ItemRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<ItemModel>> getItems() async {
    try {
      final response = await apiService.get(
        endpoint: AppConstants.getItemsEndpoint,
      );

      if (response['success'] == true) {
        final List<dynamic> itemsList = response['data'];
        return itemsList
            .map((item) => ItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch items',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ItemModel> getItem(String id) async {
    try {
      final response = await apiService.get(
        endpoint: '${AppConstants.getUserEndpoint}/$id',
      );

      if (response['success'] == true) {
        return ItemModel.fromJson(response['data']);
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch item',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ItemModel> createItem(ItemModel item) async {
    try {
      final response = await apiService.post(
        endpoint: AppConstants.createItemEndpoint,
        body: item.toJson(),
      );

      if (response['success'] == true) {
        return ItemModel.fromJson(response['data']);
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to create item',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ItemModel> updateItem(ItemModel item) async {
    try {
      final response = await apiService.put(
        endpoint: '${AppConstants.updateItemEndpoint}/${item.id}',
        body: item.toJson(),
      );

      if (response['success'] == true) {
        return ItemModel.fromJson(response['data']);
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to update item',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      final response = await apiService.delete(
        endpoint: '${AppConstants.deleteItemEndpoint}/$id',
      );

      if (response['success'] != true) {
        throw ServerException(
          message: response['message'] ?? 'Failed to delete item',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

### 5. Create Repository Interface

**File: `lib/domain/repositories/item_repository.dart`**

```dart
abstract class ItemRepository {
  Future<Either<Failure, List<ItemEntity>>> getItems();
  Future<Either<Failure, ItemEntity>> getItem(String id);
  Future<Either<Failure, ItemEntity>> createItem(ItemEntity item);
  Future<Either<Failure, ItemEntity>> updateItem(ItemEntity item);
  Future<Either<Failure, void>> deleteItem(String id);
}
```

### 6. Implement Repository

**File: `lib/data/repositories/item_repository_impl.dart`**

```dart
class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remoteDataSource;

  ItemRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ItemEntity>>> getItems() async {
    try {
      final items = await remoteDataSource.getItems();
      return Right(items.map((item) => item.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  // Implement other methods similarly...
}
```

### 7. Create Use Cases

**File: `lib/domain/usecases/item_usecase.dart`**

```dart
class GetItemsUsecase {
  final ItemRepository repository;

  GetItemsUsecase({required this.repository});

  Future<Either<Failure, List<ItemEntity>>> call() async {
    return await repository.getItems();
  }
}

class CreateItemUsecase {
  final ItemRepository repository;

  CreateItemUsecase({required this.repository});

  Future<Either<Failure, ItemEntity>> call(ItemEntity item) async {
    return await repository.createItem(item);
  }
}

class UpdateItemUsecase {
  final ItemRepository repository;

  UpdateItemUsecase({required this.repository});

  Future<Either<Failure, ItemEntity>> call(ItemEntity item) async {
    return await repository.updateItem(item);
  }
}

class DeleteItemUsecase {
  final ItemRepository repository;

  DeleteItemUsecase({required this.repository});

  Future<Either<Failure, void>> call(String itemId) async {
    return await repository.deleteItem(itemId);
  }
}
```

### 8. Create Provider (State Management)

**File: `lib/presentation/providers/item_provider.dart`**

```dart
class ItemProvider extends ChangeNotifier {
  final GetItemsUsecase getItemsUsecase;
  final CreateItemUsecase createItemUsecase;
  final UpdateItemUsecase updateItemUsecase;
  final DeleteItemUsecase deleteItemUsecase;

  List<ItemEntity> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ItemEntity> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ItemProvider({
    required this.getItemsUsecase,
    required this.createItemUsecase,
    required this.updateItemUsecase,
    required this.deleteItemUsecase,
  });

  Future<void> loadItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getItemsUsecase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (items) {
        _items = items;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> createItem(ItemEntity item) async {
    _isLoading = true;
    notifyListeners();

    final result = await createItemUsecase(item);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (createdItem) {
        _items.add(createdItem);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  // Implement update and delete similarly...
}
```

### 9. Create UI Page

**File: `lib/presentation/pages/items_page.dart`**

```dart
class ItemsPage extends StatefulWidget {
  const ItemsPage({Key? key}) : super(key: key);

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
      ),
      body: Consumer<ItemProvider>(
        builder: (context, itemProvider, _) {
          if (itemProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (itemProvider.items.isEmpty) {
            return const Center(child: Text('No items found'));
          }

          return ListView.builder(
            itemCount: itemProvider.items.length,
            itemBuilder: (context, index) {
              final item = itemProvider.items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.description),
                trailing: Text('\$${item.price.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
}
```

### 10. Register in Service Locator

**File: `lib/service_locator.dart`**

```dart
void setupServiceLocator() {
  // ... existing code ...

  // Item Data Source
  getIt.registerSingleton<ItemRemoteDataSource>(
    ItemRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  // Item Repository
  getIt.registerSingleton<ItemRepository>(
    ItemRepositoryImpl(remoteDataSource: getIt<ItemRemoteDataSource>()),
  );

  // Item Use Cases
  getIt.registerSingleton<GetItemsUsecase>(
    GetItemsUsecase(repository: getIt<ItemRepository>()),
  );
  getIt.registerSingleton<CreateItemUsecase>(
    CreateItemUsecase(repository: getIt<ItemRepository>()),
  );

  // Item Provider
  getIt.registerSingleton<ItemProvider>(
    ItemProvider(
      getItemsUsecase: getIt<GetItemsUsecase>(),
      createItemUsecase: getIt<CreateItemUsecase>(),
      updateItemUsecase: getIt<UpdateItemUsecase>(),
      deleteItemUsecase: getIt<DeleteItemUsecase>(),
    ),
  );
}
```

## API Response Format Expectations

The app expects API responses in this format:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "id": "123",
    "name": "Item Name",
    "description": "Description",
    "price": 99.99,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

## Error Handling

The app automatically handles these HTTP status codes:

| Status Code | Exception | Action |
|-------------|-----------|--------|
| 200/201 | None | Success |
| 400 | ServerException | Bad request |
| 401 | AuthenticationException | Unauthorized |
| 403 | AuthenticationException | Forbidden |
| 404 | ServerException | Not found |
| 500 | ServerException | Internal server error |
| Other | ServerException | Unknown error |

## Best Practices

1. **Always use the Either pattern** for error handling
2. **Map API models to entities** before returning
3. **Use repository pattern** for data abstraction
4. **Keep use cases simple** - one responsibility
5. **Use providers** for state management
6. **Validate input** before sending to API
7. **Handle timeouts** gracefully (30 seconds default)
8. **Log errors** for debugging

## Testing API Integration

```dart
test('GetItemsUsecase returns items on success', () async {
  final result = await getItemsUsecase();
  
  result.fold(
    (failure) => fail('Should return items'),
    (items) => expect(items, isNotEmpty),
  );
});
```

This architecture ensures:
- ✅ Separation of concerns
- ✅ Testability
- ✅ Maintainability
- ✅ Scalability
- ✅ Error handling
