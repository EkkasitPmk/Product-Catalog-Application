# CatalogX — Product Catalog Application

A production-ready Flutter mobile application built as a coding challenge submission. CatalogX implements a clean 3-layer architecture, robust Riverpod state management, Dio HTTP networking with DummyJSON API, responsive layouts, infinite pagination, and comprehensive loading/error/empty state handling.

---

## 📱 Features & Highlights

- **Dynamic Product Catalog**: Connects live to `https://dummyjson.com/products` (dynamic API data, no hardcoded products).
- **Product Detail Screen**: Full product view with interactive gallery carousel, thumbnails, contextual badges (e.g. freshness guarantee for groceries vs official warranty for tech), packaging/color variants, and user reviews.
- **Riverpod State Management**: Classic Riverpod 2.6 with `StateNotifier` and `AsyncValue<T>` (pure Dart, no `build_runner` or code-generation required).
- **Dio HTTP Client**: Custom `DioClient` with configurable timeouts, headers, and centralized exception handling (`ApiException`).
- **Comprehensive UI States**:
  - **Loading**: Shimmer skeleton placeholder for products and category filter pills.
  - **Error**: Error state with clear feedback and a 1-tap "Retry" action.
  - **Empty**: Interactive empty state with popular search suggestions and filter reset.
- **Pull-to-Refresh & Infinite Pagination**: Smooth pull-to-refresh and infinite scroll pagination (`skip += limit`).
- **Responsive Layout**: Adapts automatically across mobile (2 columns) and tablet/iPad (3-4 columns).
- **Interactive In-Memory Cart & Wishlist**: Real-time cart quantity stepper, total price calculation, wishlist toggle, and quick checkout flow.
- **State Demo Screen**: Dedicated testing screen (matching coding challenge mockup screen 3) for interviewer validation of all states.
- **TopBar Quick Reset**: Tap the `CatalogX` logo on the topbar to instantly reset search, filters, and sort back to defaults.

---

## 🏛️ Clean Architecture (3 Layers)

The codebase strictly follows clean architecture separation of concerns:

```
lib/
├── core/                         # Cross-cutting concerns & shared utilities
│   ├── constants/               # Colors, API endpoints, themes
│   ├── network/                 # DioClient, interceptors, ApiException
│   └── utils/                   # Currency formatters, responsive layout helper
├── data/                         # Data layer (API models & repositories)
│   ├── models/                  # ProductModel, ProductResponse, CategoryModel
│   └── repositories/            # ProductRepository (interface & Dio implementation)
└── presentation/                 # Presentation layer (UI & State)
    ├── providers/               # Riverpod StateNotifiers (ProductList, Cart, Wishlist)
    ├── screens/                 # Catalog, Product Detail, Categories, Cart, Wishlist, Profile, Demo
    └── widgets/                 # ProductCard, Shimmer, EmptyState, CategoryPills, Carousel
```

---

## 🧪 Testing

The project includes comprehensive unit and widget tests covering repositories, state notifiers, and UI boot checks.

Run all tests:
```bash
flutter test
```

Result:
```
15/15 tests passed! (100% pass rate, 0 errors, 0 warnings)
```

Analyze code quality:
```bash
flutter analyze
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.27 or higher
- Dart 3.6 or higher

### Installation & Run

1. Clone the repository:
   ```bash
   git clone <REPOSITORY_URL>
   cd <REPOSITORY_FOLDER>
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

---

## 📦 Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | `^2.6.1` | State management with `AsyncValue<T>` |
| `dio` | `^5.7.0` | HTTP client with timeout & interceptors |
| `cached_network_image` | `^3.4.1` | Smooth image caching & fading |
| `shimmer` | `^3.0.0` | Skeleton loading effects |
| `intl` | `^0.20.2` | Number & currency formatting |
| `mocktail` | `^1.0.4` | Mocking in unit tests |

---

Developed with ❤️ using Flutter & Dart.
