# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Mandatory Practices

### Test-Driven Development (TDD)
1. **Write tests first** before implementing any feature or fix
2. Follow Red-Green-Refactor cycle: failing test → minimal implementation → refactor
3. Each vertical slice must include tests for all layers (View, ViewModel, Services, Utilities)
4. Run tests before committing: `xcodebuild test`

### Clean Code
1. **Single Responsibility**: Each class/struct does one thing well
2. **Meaningful names**: Variables, functions, types should be self-documenting
3. **Small functions**: Max 20 lines, single level of abstraction
4. **No magic numbers**: Use named constants or enums
5. **SOLID principles**: Especially Dependency Injection for testability
6. **Boy Scout Rule**: Leave code cleaner than you found it

## Project Overview

Dining Decider is a native iOS app (SwiftUI, iOS 17+) that helps users decide where to eat via an interactive spinning wheel. Users drag to spin a wheel, which lands on a dining category and shows nearby restaurant recommendations.

## Tech Stack

- **UI**: SwiftUI with @Observable state management
- **Minimum iOS**: 17.0
- **Architecture**: MVVM (Views → ViewModels → Models/Services)
- **Location**: CoreLocation + MapKit geocoding
- **Animation**: SwiftUI animations with gesture-based physics

## Getting Started (New Project Setup)

1. **Create Xcode project**: File → New → Project → iOS App
   - Product Name: `DiningDecider`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None
   - Include Tests: Yes

2. **Add Location capability**:
   - Select project → Signing & Capabilities → + Capability → Location

3. **Configure Info.plist** (add these keys):
   ```
   NSLocationWhenInUseUsageDescription = "To find restaurants near you"
   ```

4. **Add restaurants.json to bundle**:
   - Drag file into Xcode project navigator
   - Ensure "Copy items if needed" is checked
   - Target membership: DiningDecider

## Build Commands

```bash
# Open in Xcode
open DiningDecider.xcodeproj

# Build from command line
xcodebuild -scheme DiningDecider -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run tests
xcodebuild test -scheme DiningDecider -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Lint code (install: brew install swiftlint)
swiftlint
```

## Project Structure

```
DiningDecider/
├── App/                    # App entry point
├── Views/                  # SwiftUI views
│   └── Components/         # Reusable UI components
├── ViewModels/             # @Observable view models
├── Models/                 # Data models (Restaurant, WheelSector, VibeMode)
├── Services/               # LocationManager, GeocodingService
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

## SwiftUI Quick Reference

### Property Wrappers
- `@State` - Local view state (value types)
- `@Observable` - Shared state class (iOS 17+)
- `@Environment` - System values (\.colorScheme, \.dismiss)
- `@Binding` - Two-way connection to parent's state

### Common Patterns
```swift
.sheet(isPresented: $showSheet) { }     // Modal presentation
.onAppear { }                            // Run on view appear
.task { }                                // Async work on appear
GeometryReader { geo in }                // Get parent size
```

### Gesture Basics
```swift
.gesture(DragGesture()
    .onChanged { value in }              // During drag
    .onEnded { value in }                // On release
)
```

## Accessibility

All interactive components must support VoiceOver:

```swift
WheelView()
    .accessibilityLabel("Spinning wheel")
    .accessibilityHint("Swipe to spin and get a restaurant recommendation")
    .accessibilityAddTraits(.allowsDirectInteraction)
```

## Design System

Reference screenshots in `docs/UX/`. Key colors:
- Background: #F0EFE9 (warm cream)
- Primary button: #C8A299 (dusty rose)
- Vibe colors: Aesthetic #D98880, Splurge #884EA0, Standard #7F8C8D

Each vibe mode has its own wheel color palette. See `docs/PLAN.md` for full design tokens.

## Documentation

- `docs/MVP.md` - Feature specs, models, code examples
- `docs/PLAN.md` - Implementation plan with vertical slices and acceptance criteria
- `docs/UX/` - Reference screenshots (source of truth for visual design)
