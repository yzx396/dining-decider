# Dining Decider

A native iOS app that solves the "where should we eat?" problem through an interactive spinning wheel interface.

![Dining Decider Main Screen](docs/UX/main-screen.png)

## Overview

Dining Decider transforms restaurant selection into a delightful game. Instead of endless deliberation, users spin a customized wheel based on their mood, location, and party size to receive curated restaurant recommendations.

## Key Features

- **Interactive Spinning Wheel** - Drag and release to spin with physics-based momentum
- **Three Vibe Modes**
  - Pretty Pics (Aesthetic): Instagram-worthy, visually beautiful spots
  - Splurge (Formal): Upscale fine dining experiences
  - Hungry/Save (Standard): Quality food without breaking the bank
- **Location-Based Search** - Current location or manual city entry with customizable radius
- **Party Size Support** - 1-20 people with per-person pricing calculated
- **Curated Recommendations** - 3 restaurants per spin with details and directions
- **Native iOS Experience** - Haptic feedback, Apple Maps integration, SF Symbols

## Tech Stack

- **UI Framework**: SwiftUI
- **Minimum iOS**: 17.0
- **State Management**: @Observable
- **Location**: CoreLocation / MapKit
- **Haptics**: UIImpactFeedbackGenerator

## Build & Run

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Commands

```bash
# Open in Xcode
open DiningDecider.xcodeproj

# Build from command line
xcodebuild -scheme DiningDecider -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run all tests
xcodebuild test -scheme DiningDecider -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Project Structure

```
DiningDecider/
├── Views/              # SwiftUI views and components
├── ViewModels/         # @Observable view models
├── Models/             # Data models (Restaurant, WheelSector, VibeMode)
├── Services/           # LocationManager, GeocodingService
├── Data/               # restaurants.json + RestaurantLoader
├── Utilities/          # WheelMath, WheelPhysics, HapticManager
└── Extensions/         # Color+Theme (design tokens)

DiningDeciderTests/
├── ViewModels/         # ViewModel unit tests
├── Services/           # Service unit tests
├── Utilities/          # Utility function tests
└── Mocks/              # Mock implementations for testing
```

## Development Workflow

This project follows **Test-Driven Development (TDD)**:
1. Write tests first before implementing features
2. Follow Red-Green-Refactor cycle
3. Maintain high test coverage across all layers

See [CLAUDE.md](CLAUDE.md) for detailed development guidelines and [docs/MVP.md](docs/MVP.md) for comprehensive technical documentation.

## Architecture

- **Single Source of Truth**: `DiningViewModel` (@Observable) manages all app state
- **Physics-Based Animation**: Drag gesture captures angular velocity, momentum spin with natural deceleration
- **Protocol-Oriented Design**: All services use protocols for dependency injection and testability
- **Clean Code**: SOLID principles, single responsibility, small focused functions

## Future Enhancements

- Restaurant photos with cached images
- Favorites system with SwiftData persistence
- Spin history tracking
- Home Screen widget
- Siri integration
- SharePlay for group decisions

## License

Copyright 2025. All rights reserved.
