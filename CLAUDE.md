# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Mandatory Practices

### Test-Driven Development (TDD)
1. **Write tests first** before implementing any feature or fix
2. Follow Red-Green-Refactor cycle: failing test → minimal implementation → refactor
3. Each vertical slice must include tests for all layers (ViewModel, Services, Utilities)

### Clean Code
1. **Single Responsibility**: Each class/struct does one thing well
2. **Small functions**: Max 20 lines, single level of abstraction
3. **No magic numbers**: Use named constants or enums
4. **SOLID principles**: Especially Dependency Injection for testability

## Project Overview

Dining Decider is a native iOS app (SwiftUI, iOS 17+) that helps users decide where to eat via an interactive spinning wheel. Users drag to spin a wheel, which lands on a dining category and shows nearby restaurant recommendations.

## Build Commands

```bash
# Open in Xcode
open DiningDecider.xcodeproj

# Build from command line
xcodebuild -scheme DiningDecider -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run all tests
xcodebuild test -scheme DiningDecider -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run a single test class
xcodebuild test -scheme DiningDecider -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:DiningDeciderTests/WheelMathTests

# Run a single test method
xcodebuild test -scheme DiningDecider -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:DiningDeciderTests/WheelMathTests/test_landingSector_withZeroRotation_returnsFirstSector

# Lint code (install: brew install swiftlint)
swiftlint
```

## Target Project Structure

```
DiningDecider/
├── Views/                  # SwiftUI views
│   └── Components/         # Reusable UI components (WheelView, ControlsCard, etc.)
├── ViewModels/             # @Observable view models (DiningViewModel)
├── Models/                 # Data models (Restaurant, WheelSector, VibeMode)
├── Services/               # LocationManager, GeocodingService (with protocols)
├── Data/                   # restaurants.json + RestaurantLoader
├── Utilities/              # WheelMath, WheelPhysics, HapticManager
└── Extensions/             # Color+Theme (design tokens)

DiningDeciderTests/
├── ViewModels/             # ViewModel unit tests
├── Services/               # Service unit tests
├── Utilities/              # Utility function tests
└── Mocks/                  # Mock implementations for testing
```

## Key Architecture Patterns

### State Management
Single `DiningViewModel` (@Observable) manages all app state: location, vibe mode, party size, wheel rotation, and spin results.

### Wheel Physics
Drag gesture captures angular velocity → release triggers momentum spin → Timer-based deceleration (0.98 friction) → Landing sector calculated from final rotation.

### Restaurant Filtering
`RestaurantLoader` loads bundled JSON → filters by: distance from user (radius), vibe mode (price level), category (wheel sector) → returns shuffled top 3.

### Location Modes
Two modes: `.current(CLLocationCoordinate2D)` uses GPS, `.manual(String)` geocodes user-entered address. Falls back to manual if location permission denied.

## Protocols for Testability

All services must have protocols for dependency injection:

```swift
// Protocol
protocol LocationProviding {
    var currentLocation: CLLocationCoordinate2D? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestPermission()
}

// Implementation
final class LocationManager: NSObject, LocationProviding, CLLocationManagerDelegate { ... }

// Mock for testing
final class MockLocationProvider: LocationProviding {
    var currentLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    func requestPermission() { }
}
```

Apply same pattern to: `RestaurantLoading`, `GeocodingService`, `HapticProviding`.

## Accessibility

All interactive components must support VoiceOver:

```swift
WheelView()
    .accessibilityLabel("Spinning wheel")
    .accessibilityHint("Swipe to spin and get a restaurant recommendation")
    .accessibilityAddTraits(.allowsDirectInteraction)
```

## Design System

Reference screenshots in `docs/UX/` (source of truth for visual design). Key colors:
- Background: #F0EFE9 (warm cream)
- Primary button: #C8A299 (dusty rose)
- Vibe colors: Aesthetic #D98880, Splurge #884EA0, Standard #7F8C8D

Each vibe mode has its own wheel color palette. See `docs/PLAN.md` for full design tokens.

## Documentation

- `docs/MVP.md` - Feature specs, models, code examples
- `docs/PLAN.md` - Implementation plan with vertical slices and acceptance criteria
- `docs/UX/` - Reference screenshots for visual design
