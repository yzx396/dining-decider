# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dining Decider is a native iOS app (SwiftUI, iOS 17+) that helps users decide where to eat via an interactive spinning wheel. Users drag to spin a wheel, which lands on a dining category and shows nearby restaurant recommendations.

## Tech Stack

- **UI**: SwiftUI with @Observable state management
- **Minimum iOS**: 17.0
- **Architecture**: MVVM (Views → ViewModels → Models/Services)
- **Location**: CoreLocation + MapKit geocoding
- **Animation**: SwiftUI animations with gesture-based physics

## Build Commands

```bash
# Open in Xcode
open DiningDecider.xcodeproj

# Build from command line
xcodebuild -scheme DiningDecider -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run tests
xcodebuild test -scheme DiningDecider -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
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
