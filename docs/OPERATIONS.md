# Operations

Runbook for developers and release owners: observability, verification, and CI.

## Observability

### Logs (Console.app)

Filter **subsystem:** `com.stocktracker.app`

| Category | Source | Typical messages |
|----------|--------|------------------|
| `network` | `LoggingWebSocketInterceptor`, metrics interceptor | connect/disconnect, failures, byte counts |
| `telemetry` | `OSLogAppTelemetry` | App launched, bootstrap, feed start/stop, connection status |

### Product telemetry events

[`AppTelemetryEvent`](../Packages/Core/Sources/Core/Observability/AppTelemetry.swift):

| Event | When |
|-------|------|
| `appLaunched` | Root view appears after successful bootstrap |
| `bootstrapSucceeded` | Composition root created dependencies |
| `bootstrapFailed(reason:)` | Catalog or repository setup failed |
| `feedStarted` / `feedStopped` | User toggles feed on list screen |
| `connectionStatusChanged` | Connection stream emits new status |

Inject alternate implementations via `AppDependencies.telemetry` for tests or future backends.

### WebSocket metrics

[`WebSocketMetricsRecorder`](../Packages/Core/Sources/Core/Networking/MetricWebSocketInterceptor.swift) (actor) tracks:

- `connectCount`, `sendCount`, `receiveCount`, `failureCount`

Access from debug tooling through `AppDependencies.metricsRecorder` after bootstrap.

## Manual health checks

1. **Cold launch** — No crash; list shows 25 symbols; Console shows bootstrap succeeded + app launched.
2. **Start feed** — Status moves connecting → connected; prices change; telemetry feed started.
3. **Sort** — Price and change sorts reorder list deterministically.
4. **Detail** — Tap a symbol; market data card and about section load; prices update with feed.
5. **RTL** — Toolbar layout menu → Right to left; row icon and nav bar align (see `StockListRowLayout`).
6. **Deep link** — Open `stocktracker://symbol/AAPL` in Simulator; detail for AAPL appears.

## CI pipeline

Local and GitHub Actions use [`Scripts/ci-test.sh`](../Scripts/ci-test.sh):

| Step | Action |
|------|--------|
| Lint | `swiftlint lint --strict` |
| Domain | `swift test --enable-code-coverage`; fail if line coverage is below `MIN_DOMAIN_COV` (default **45**) |
| Core | `swift test` |
| Data | `xcodebuild test` from `Packages/Data` on iOS Simulator |
| Features | `xcodebuild test` from `Packages/Features` on iOS Simulator |
| App | `xcodebuild test` on **StockTracker** scheme + UI tests; `-enableCodeCoverage YES` |
| Artifact | `TestResults.xcresult` (uploaded in CI) |

### Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `MIN_DOMAIN_COV` | `45` | Minimum Domain module line coverage percent |
| `SIM_DEST` | *(auto)* | Full `xcodebuild -destination` string; skips auto-detection |
| `SIM_DEVICE_NAME` | *(auto)* | Shorthand, e.g. `iPhone 17 Pro` → `platform=iOS Simulator,name=…` |

If neither `SIM_DEST` nor `SIM_DEVICE_NAME` is set, the script picks the first available simulator matching **iPhone 17 Pro → 17 → 16 Pro → 16 → …** and uses `platform=iOS Simulator,id=<UDID>` (avoids “device not found” when only newer runtimes are installed).

Example:

```bash
MIN_DOMAIN_COV=50 SIM_DEVICE_NAME='iPhone 17 Pro' ./Scripts/ci-test.sh
```

Workflow: [`.github/workflows/ios.yml`](../.github/workflows/ios.yml)

## Troubleshooting

| Symptom | Likely cause | Action |
|---------|--------------|--------|
| CI Simulator tests fail “device could not be found” | Hard-coded or missing runtime | Use updated `ci-test.sh` (auto UDID), or set `SIM_DEST` / `SIM_DEVICE_NAME` |
| Features `swift test` on Mac fails UIKit | Platform mismatch | Use `xcodebuild test` from `Packages/Features` on Simulator |
| Empty quotes after start | WebSocket blocked or wrong URL | Check `WebSocketURL`, network, Console network logs |
| Bootstrap failure screen | Missing `symbols.json` or bad plist | Verify app bundle resources and `AppConfig.plist` |

## Production feed swap

1. Implement [`PriceFeedEngine`](../Packages/Data/Sources/Data/PriceFeedEngine.swift).
2. Update [`QuoteFeedRepositoryFactory`](../Packages/Bootstrap/Sources/Bootstrap/QuoteFeedRepositoryFactory.swift).
3. Re-run full `./Scripts/ci-test.sh` and manual health checks.

Details: [ARCHITECTURE.md](ARCHITECTURE.md).
