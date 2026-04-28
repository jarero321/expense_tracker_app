# expense_tracker_app

App de gastos personales en español. Registra gastos por categoría, agrúpalos por mes y filtra por categoría. Datos 100% locales en SQLite.

Sin backend, sin sincronización, sin auth. Una sola pantalla principal y un par de pantallas modales para captura y selección.

## Stack

| Capa | Decisión |
|---|---|
| SDK | Dart `^3.11.1`, Flutter Material 3 |
| Estado | `ChangeNotifier` por feature + un `AppManager` singleton para sesión |
| Persistencia | `sqflite` con dos tablas: `categories`, `expenses` |
| Navegación | `Navigator` + `RouteObserver` propio (sin go_router) |
| i18n | `intl` con locale fijo `es` |

Sin gestor de estado externo. Sin DI container. Sin generación de código.

## Cómo correrlo

```bash
flutter pub get
flutter run
```

La primera ejecución crea la DB con cinco categorías semilla (Comida, Transporte, Hogar, Ocio, Otros) — ver `framework/utils/database.dart`.

Locale forzado a español en `main.dart`. Los `DateFormat` y los textos de UI están en `es-MX` neutro.

## Arquitectura

Dos carpetas en `lib/`:

- `app/` — features. Una carpeta por pantalla, más una `manager/` para el estado compartido.
- `framework/` — theme, utilidades (DB, navegación, telemetría, currency) y widgets reutilizables.

```
lib/
├── main.dart                        # raíz: MaterialApp + locale es + AppRouteObserver
├── app/
│   ├── home/
│   │   ├── view.dart                # HomeView (pantalla principal)
│   │   └── model.dart               # HomeViewModel (ChangeNotifier)
│   ├── add_expense/
│   │   ├── view.dart
│   │   └── model.dart               # AddExpenseViewModel + validaciones
│   ├── categories/
│   │   ├── view.dart                # CategoriesSelectorView (modal)
│   │   └── model.dart
│   ├── error/view.dart              # fallback de errores fatales
│   └── manager/
│       └── app_manager.dart         # singleton: estado de sesión compartido
└── framework/
    ├── theme/app.dart               # AppTheme: colores, tipografía, spacings, radii
    ├── utils/
    │   ├── database.dart            # AppDatabase singleton + schema
    │   ├── navigator.dart           # AppNavigator + AppRouteObserver
    │   ├── currency.dart            # formateo MXN en centavos
    │   └── telemetry.dart           # tracking de views y errores
    └── widgets/base/                # AppButton, AppAppBar, AppInput*, AppAlert, AppLoading
```

### El patrón: AppManager + ViewModel por feature

Tres piezas:

1. **`AppManager`** (`app/manager/app_manager.dart`) — singleton. Contiene el estado *transversal* a la sesión: lista de categorías cargadas, lista de gastos del mes activo, mes/año seleccionado, filtro activo, total mensual. **No** notifica cambios; es solo el almacén.

2. **ViewModel por pantalla** (`app/<feature>/model.dart`) — extiende `ChangeNotifier`. Lee y escribe `AppManager`, ejecuta queries contra `AppDatabase`, expone getters derivados (`visibleExpenses`, `monthlyTotalCents`) y dispara `notifyListeners()`. Cada VM también puede tener estado puramente de pantalla (drafts del formulario, errores de validación, `isSaving`).

3. **View** (`app/<feature>/view.dart`) — `StatefulWidget` que en `initState` crea su `late final XViewModel _viewModel`, llama `_viewModel.init()`/`bootstrap`, y envuelve la UI en `ListenableBuilder(listenable: _viewModel, ...)`. En `dispose` libera el VM.

Ejemplo del ciclo de Home:

```
HomeView.initState()
  → HomeViewModel().init()
      → _loadCategories()  →  AppManager.categories
      → _loadMonth()       →  AppManager.expenses + monthlyTotalCents
  → ListenableBuilder rebuilds en cada notifyListeners()
HomeView.dispose() → _viewModel.dispose()
```

Cuando una pantalla modal (Add, Categories) modifica datos, `HomeView` llama `_viewModel.refresh()` al regresar — el VM no escucha la DB; recarga explícito.

### Navegación: `AppNavigator` + `AppRouteObserver`

`MaterialApp` recibe `navigatorObservers: [AppRouteObserver.routeObserver]` (`main.dart`). El observer expone un `BuildContext` de raíz que `AppNavigator` usa para empujar pantallas sin pasar `context` desde la view.

API mínima:

- `navigateToWidget(view: ...)` — push estándar.
- `navigateAndWait(view: ...)` — push esperando un valor de retorno (modal selector).
- `navigateAndReplaceAll(view: ...)` — reemplaza todo el stack (uso típico: `ErrorView`).

Las transiciones son instantáneas (`transitionDuration: Duration.zero`) — la app prioriza inmediatez sobre animación.

### Persistencia

`AppDatabase` en `framework/utils/database.dart` es un singleton estático. Schema en `_onCreate`:

- `categories(id, name UNIQUE, color_hex, icon_code)`
- `expenses(id, amount_cents, note, category_id FK, spent_at ISO8601)`

Los montos se guardan en **centavos** (`int`), nunca floats — formateo en `framework/utils/currency.dart`.

Los ViewModels acceden a `AppDatabase.instance()` directamente; **no** hay capa de Repository en este repo. La razón: las queries son tres y no hay reuso entre features. Si crece, agrégala.

## Convenciones

- **Drafts en el VM, no en `setState`.** Los formularios mantienen su estado (amount, note, category, date) como propiedades del VM. `setX()` actualiza y llama `notifyListeners()`. Errores de validación viven al lado de cada draft (`amountError`, `categoryError`).
- **Validación pura.** `validateAmount`, `validateNote` son `static` y sin side-effects. `_refreshAllErrors()` consolida y devuelve si el form es válido.
- **Telemetría.** Cada view tiene `static const String tag = 'XView'`. Eventos vía `Telemetry.trackView(tag, action, metadata: {...})` y `Telemetry.trackError(tag, action, e, st)`. El tag identifica la pantalla en logs.
- **Tokens, no literales.** Colores, spacings, radii y tipografía vienen de `AppTheme` en `framework/theme/app.dart`. `AppTheme.font(size: FONT_SIZE.H4, style: FONT_STYLE.SEMIBOLD)` para texto; `AppTheme.SPACE_VERTICAL_2x` para gaps; `AppTheme.MARGINS_ALL` para padding de pantalla.
- **Widgets `Base` reutilizables.** `AppButton`, `AppAppBar`, `AppInputCurrency`, `AppInputText`, `AppFieldPreview`, `AppAlert`, `AppLoading` viven en `framework/widgets/base/` y se usan en todas las pantallas. Lo específico de un feature queda como `class _Widget` privado en el archivo de la view.
- **Manejo de errores.** Errores de validación: `throw StateError('validation')` y la view ignora. Errores fatales: navegación a `ErrorView` con `navigateAndReplaceAll`.

## Agregar un feature

1. `lib/app/<feature>/{view.dart, model.dart}`.
2. Si requiere estado de sesión nuevo (cosas que sobrevivan la pantalla), agrégalo a `AppManager`. Si es solo de pantalla, queda en el VM.
3. Si toca DB:
   - Tabla nueva → agregar `db.execute(CREATE TABLE ...)` en `_onCreate` y subir `_version`.
   - Migración → agregar `onUpgrade` a `openDatabase`.
4. Eventos relevantes → `Telemetry.trackView(tag, ...)`.

## Limitaciones conocidas

- Locale fijo en `es`. Cambiar a multi-idioma requiere mover textos a `.arb`.
- Sin migraciones implementadas — cambiar schema requiere desinstalar la app.
- `AppManager` es global; los tests que toquen state requieren llamar `AppManager().reset()` en `setUp`.
- `sqflite` no corre en web.
