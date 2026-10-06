# Compliance & privacy

This document describes how the Stock Tracker app handles data for App Store review and internal release checklists. It is **not legal advice**.

## Summary

| Topic | Status |
|-------|--------|
| Cross-app tracking | **Off** (`NSPrivacyTracking` = false) |
| Analytics / ads SDKs | **None** in the binary |
| Account / PII collection | **None** |
| On-device preferences | Layout direction only (`UserDefaults`) |
| Network | WebSocket to configured host (demo: Postman Echo) |

## Privacy manifest

Ship [`StockTrackerApp/PrivacyInfo.xcprivacy`](../StockTrackerApp/PrivacyInfo.xcprivacy) with every build.

### Accessed API types

| API category | Reason code | Use in app |
|--------------|-------------|------------|
| `NSPrivacyAccessedAPICategoryUserDefaults` | **CA92.1** | Store `userLayoutDirectionChoice` for RTL/LTR toolbar setting |

When adding new storage (Keychain, file timestamps, disk space APIs, etc.), update the manifest and this table **before** release.

## Data flows

```text
App ──WebSocket──▶ Host from AppConfig.WebSocketURL
                 (price echo JSON; not written to disk)

App ──UserDefaults──▶ userLayoutDirectionChoice only
```

- Quotes exist **in memory** while the app runs; there is no Core Data / SQLite catalog sync.
- **`symbols.json`** is bundled read-only metadata, not user data.

## Logging and telemetry

| Channel | What is logged | What is avoided |
|---------|----------------|-------------------|
| Network interceptors | Host name, payload **byte count** | Full URLs with secrets, message bodies |
| `AppTelemetry` | Event names + bootstrap failure **reason string** | User identifiers, portfolio data |
| OSLog subsystem | `com.stocktracker.app` | — |

Review new log lines with the same rules before merging.

## Third-party services

Default configuration points at **Postman Echo** for development. Production deployments must:

1. Document the market-data vendor in release notes.
2. Update privacy labels if the vendor collects IP addresses or identifiers.
3. Use TLS (`wss://`) endpoints only.

## Pre-release checklist

- [ ] `PrivacyInfo.xcprivacy` matches code (UserDefaults, any new APIs)
- [ ] No API keys or secrets in git (use xcconfig excluded from VCS if needed)
- [ ] App Store “Data collection” answers align with “no data collected” for current binary
- [ ] WebSocket host documented for security review
- [ ] [OPERATIONS.md](OPERATIONS.md) health checks pass on release candidate

## Related docs

- [ARCHITECTURE.md](ARCHITECTURE.md) — where configuration and feeds are wired
- [OPERATIONS.md](OPERATIONS.md) — telemetry and CI artifacts
