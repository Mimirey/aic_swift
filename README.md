# GetX Flutter Setup Blueprint

This repository provides a foundational Flutter architecture blueprint (*boilerplate / project setup*) powered by **GetX**, adhering strictly to **Modular & Clean Architecture** principles. It is engineered to be scalable, maintainable, and enforce a clear **Separation of Concerns**.

---

## 📁 Directory Structure & Rationale

Below is the primary directory structure inside `lib/` along with the intended purpose for each folder:

```text
lib/
├── bindings/             # GetX Dependency Injection (per Feature / Screen)
├── components/           # Reusable Global UI Components (Button, Dropdown, Text, etc.)
├── config/               # App Core Configurations
│   ├── network/          # HTTP Client (Dio), Interceptors, Base URL, API Endpoints
│   ├── routes/           # GetX Navigation Routing (Route Names & GetPage Bindings)
│   └── themes/           # System Design Tokens (Colors, Material Theme, Typography)
├── controllers/          # State Management Logic (GetxController)
├── data/                 # Local Storage Management & Dummy / Mock Data
├── helper/               # Pure Utilities & Formatters (Currency, Date, Time, Safe Exec)
├── models/               # Data Transfer Objects (DTOs), Data Schemas, & Enums
├── pages/                # Screen / View Layer (Primary Application UI)
│   └── <feature_name>/   # Isolated Feature Modules (Splash, Dashboard, Auth, etc.)
│       └── components/   # Local UI Components scoped strictly to this feature
└── utils/                # Infrastructure & Service Layer (Secure Storage, Session, Error Handlers)
```

---

## 💡 Detailed Directory Explanations

### 1. `lib/config/` (App Core Configurations)
Serves as the central hub for global application settings:
- **`config/network/`**: Configures HTTP networking powered by `Dio`, centralized token/header handling (`client.dart`), and API endpoints registry (`constant_api.dart`).
- **`config/routes/`**: Manages application navigation flows (`routes.dart`) and the `GetPage` registry (`pages.dart`) connecting routes, views, and bindings.
- **`config/themes/`**: Holds design system tokens such as color palettes (`app_colors.dart`) and global Flutter `ThemeData` configurations (`app_themes.dart`).

### 2. `lib/components/` vs `lib/pages/<feature>/components/`
- **Global Components (`lib/components/`)**: Contains generic, highly reusable UI widgets shared across the entire application (e.g., `CustomButton`, `CustomTextField`, `CustomDropdown`).
- **Local Feature Components (`lib/pages/<feature>/components/`)**: Contains feature-specific UI widgets used exclusively by that page. This prevents global folder pollution and preserves feature module isolation.

### 3. `lib/data/` (Local Storage & Mock Data)
Dedicated to local data persistence, caching mechanisms (such as Hive/SQLite), and mock datasets (e.g., mock JSON seed data) utilized for offline development and unit/integration testing.

### 4. `lib/bindings/`
Declares GetX Dependency Injection (`Bindings`). Lazy-loads controllers, repositories, or services when a view is rendered to optimize memory consumption.

### 5. `lib/controllers/`
Houses business logic and reactive state management inheriting from `GetxController`. Responsible for executing use cases and updating view states.

### 6. `lib/models/`
Defines data structures (DTOs, Request/Response models, JSON serialization) and global enum specifications (`models/metadata/enums.dart`).

### 7. `lib/helper/`
Contains pure utility functions and formatters without state dependencies, such as currency parsers, date/time formatters, string extensions, and safe execution helpers.

### 8. `lib/utils/`
Provides infrastructure and service utilities, including encrypted storage (`AppSecureStorage`), key-value preferences (`AppSharedPreferences`), user session state (`SessionManager`), and global HTTP error/token expiration handlers (`ApiErrorHandler`, `TokenExpiredHandler`).

---

## 🎨 Custom Components Reference

Below is the documentation for custom UI components available in `lib/components/`:

### 🔹 1. `CustomButton` (`lib/components/custom_button.dart`)
A versatile button component built on `ElevatedButton` integrated with `CustomText`.
- **Properties**: Customization for `text`, `margin`, `height`, `width`, `borderRadius`, `backgroundColor`, `foregroundColor`, `fontSize`, `elevation`, `shape`, and `onPressed` callbacks.

### 🔹 2. `CustomText` & `CustomSpacing`
- **`CustomText` (`lib/components/custom_text.dart`)**: Standardized text wrapper ensuring unified font family and typography styling.
- **`CustomSpacing` (`lib/components/custom_spacing.dart`)**: Vertical and horizontal spacing helper replacing manual `SizedBox`:
  - `CustomSpacing.Height(16)`
  - `CustomSpacing.Width(12)`

### 🔹 3. `CustomTextField` & Input Formatter (`lib/components/text_field/`)
- **`CustomTextField`**: Form input widget built on `TextFormField` offering customized borders (error, focused, disabled), `prefixIcon`, `suffixIcon`, `helperText`, `errorText`, and validation support.
- **`DateInputFormatter`**: Custom `TextInputFormatter` that automatically formats numeric inputs into date format `DD/MM/YYYY`.

### 🔹 4. Dropdown Suite (`lib/components/dropdown/`)
A suite of rich dropdown components supporting animated popups and custom color schemes:
- **`CustomDropdown<T>`**: Dynamic popup/overlay dropdown that auto-calculates available screen space (above or below), supporting validation, disabled indices, and smooth slide animations.
- **`CustomSearchableDropdown<T>`**: Dropdown with an embedded search dialog for filtering items in large datasets.
- **`CustomSearchablePopDropdown<T>`**: Pop-up search dialog variation.
- **`DropdownFormField<T>`**: FormField wrapper enabling seamless integration with standard Flutter `Form` widgets.
- **`DropdownColorScheme`**: Custom color scheme configuration (fill, border, selected item, splash, and highlight colors).

### 🔹 5. `CustomIconButton` & `CustomIconButtonCircle` (`lib/components/icon_button/`)
- **`CustomIconButton`**: Standard icon button with centralized padding and touch feedback.
- **`CustomIconButtonCircle`**: Circular icon button widget with ripple effects, ideal for app bars and action toolbars.

---

## 🛠️ Helpers & Utilities Reference

### Helpers (`lib/helper/`)
- **Currency Helpers**: `CurrencyInputFormatter`, `CurrencyLocalFormatter`, and `CurrencyTextParser` for handling locale-based currency input and display formatting.
- **Date & Time Helpers**: `DateFormatter` and `TimeHelper` for parsing and formatting date-time values.
- **Safe Execution & Extensions**: `SafeHelpers` (safe exception-wrapped function execution) and `StringExtensionHelper`.

### Utilities (`lib/utils/`)
- **`SessionManager`**: Manages user authentication state and session lifecycle.
- **`AppSecureStorage`**: Encrypted storage wrapper built on `FlutterSecureStorage` for sensitive tokens.
- **`AppSharedPreferences`**: Key-value storage wrapper built on `SharedPreferences` for non-sensitive app settings.
- **`ApiErrorHandler` & `TokenExpiredHandler`**: Global HTTP error resolution and automated session redirect handling upon token expiration.
