# Local Swift packages

All reusable code lives in path-based **Swift Package Manager** modules here. The **StockTracker** app target (`StockTrackerApp/`) is the only application binary: it contains `@main`, the coordinator shell, plists, and links these packages via XcodeGen [`project.yml`](../project.yml).

## Why packages instead of folders in one target?

See [docs/ARCHITECTURE.md — Why independent Swift packages?](../docs/ARCHITECTURE.md#why-independent-swift-packages). In short: **enforced dependency direction**, **faster targeted tests**, and **clear ownership** of Domain vs UI vs market data.

## Clean Architecture mapping

| Package | CA ring | Stable contract |
|---------|---------|-----------------|
| **Domain** | Entities + use cases | `QuoteFeedRepository`, use case types |
| **Data** | Adapters + drivers | Implements repository; not imported by Features |
| **Features** | Interface adapters | View models call use cases only |
| **Core** | Shared infrastructure | WebSocket, config, telemetry |
| **DesignSystem** | UI framework | Visual components + theme |
| **Localization** | Resources | Strings catalog |
| **Bootstrap** | Composition root | Wires concrete types once |
| **TestSupport** | Test harness | Mocks (not linked into app) |

**Dependency rule:** `Features → Domain ← Data`. Bootstrap connects implementations to the app.

## Modules

| Package | Role |
|---------|------|
| **Domain** | Entities (`Quote`, `StockSymbol`), use cases, `QuoteFeedRepository`, deep link parsing |
| **Core** | WebSocket stack, interceptors, `AppConfiguration`, formatting, `AppTelemetry`, logging |
| **Data** | `LiveQuoteFeedRepository` (actor), `QuoteStore`, catalog, `EchoPriceFeedEngine`, `PriceFeedEngine` |
| **Localization** | `Localizable.xcstrings`, `L10n`, `localizedString` helpers |
| **DesignSystem** | `AppTheme`, components, RTL layout, stock icon catalog |
| **Features** | `SymbolListView` / `SymbolDetailView` and view models |
| **Bootstrap** | `CompositionRoot`, `AppDependencies`, repository factory |
| **TestSupport** | Actor mocks (`QuoteFeedRepositoryMock`, `WebSocketClientTestDouble`) |

## Dependency graph (simplified)

```text
Domain
  ↑
Core ──────────────┐
  ↑                │
Data         │
  ↑                │
Bootstrap ── Features ── DesignSystem ── Localization
```

Features does **not** depend on Data or Bootstrap.

## Concurrency

Targets use **Swift 6** and **`StrictConcurrency`** (see each `Package.swift`). Shared mutable market-data state lives in **actors** (`LiveQuoteFeedRepository`, `QuoteStore`, test mocks).

## Resources

| Package | Bundled resources |
|---------|-------------------|
| Data | `symbols.json` (25 symbols + metadata) |
| Localization | `Localizable.xcstrings` |
| DesignSystem | `ThemeColors.xcassets`, optional `StockIcons.xcassets` |

## Testing

| Package | Runner | Notes |
|---------|--------|-------|
| Domain | `swift test` (macOS) | Swift Testing; coverage enforced in CI |
| Core | `swift test` (macOS) | XCTest |
| Data | `xcodebuild test` (iOS Simulator) | XCTest; uses TestSupport |
| Features | `xcodebuild test` (iOS Simulator) | Swift Testing; UIKit via DesignSystem |

From repo root, prefer [`Scripts/ci-test.sh`](../Scripts/ci-test.sh) (auto-picks Simulator, runs full matrix).

## After structural changes

Add, remove, or rename packages in [`project.yml`](../project.yml), then:

```bash
xcodegen generate
```

Layer rules and extension points: [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md).
