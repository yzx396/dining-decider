# Dining Decider - Implementation Plan

## Methodology

### Walking Skeleton
Build a minimal end-to-end working app first, proving the architecture works across all layers before adding features.

### Vertical Slicing
Each slice delivers complete functionality through all layers (UI → Logic → Data). No horizontal layer-by-layer building.

---

## User Stories

### Epic 1: Core Spinning Experience
| ID | Story | Priority |
|----|-------|----------|
| S1 | As a user, I want to spin a wheel so that I get a random dining category | P0 |
| S2 | As a user, I want to drag the wheel to spin it so the interaction feels physical and fun | P0 |
| S3 | As a user, I want to see restaurant recommendations after spinning so I know where to eat | P0 |
| S4 | As a user, I want haptic feedback when spinning so the experience feels tactile | P1 |

### Epic 2: Location Awareness
| ID | Story | Priority |
|----|-------|----------|
| S5 | As a user, I want results based on my current location so restaurants are nearby | P0 |
| S6 | As a user, I want to enter a location manually so I can plan for trips or if I deny location access | P0 |
| S7 | As a user, I want to set a search radius so I control how far I'm willing to travel | P1 |

### Epic 3: Personalization
| ID | Story | Priority |
|----|-------|----------|
| S8 | As a user, I want to select a "vibe" so recommendations match my mood/occasion | P1 |
| S9 | As a user, I want to set my party size so I can see estimated total cost | P1 |
| S10 | As a user, I want the wheel categories to change based on vibe so options are relevant | P1 |

### Epic 4: Restaurant Details
| ID | Story | Priority |
|----|-------|----------|
| S11 | As a user, I want to see restaurant name and description so I can evaluate the option | P0 |
| S12 | As a user, I want to see pricing info so I know what to expect | P1 |
| S13 | As a user, I want to see parking info so I can plan my arrival | P2 |
| S14 | As a user, I want to open the restaurant in Maps so I can navigate there | P0 |

### Epic 5: Polish & Delight
| ID | Story | Priority |
|----|-------|----------|
| S15 | As a user, I want smooth animations so the app feels premium | P1 |
| S16 | As a user, I want the app to support dark mode so it matches my system preference | P2 |
| S17 | As a user, I want to spin again easily so I can get new options | P1 |

---

## Walking Skeleton (Slice 0)

**Goal**: Prove end-to-end architecture with minimal functionality.

```
┌─────────────────────────────────────────────────────────────────┐
│                      WALKING SKELETON                           │
├─────────────────────────────────────────────────────────────────┤
│  UI Layer        │  Wheel View → Results Sheet                  │
│  Logic Layer     │  Spin → Random category → Filter data        │
│  Data Layer      │  Load 1 category, 3 restaurants from JSON    │
└─────────────────────────────────────────────────────────────────┘
```

### Skeleton Implementation

| Component | Minimal Implementation |
|-----------|------------------------|
| **WheelView** | Static wheel with 4 colored sectors, tap to spin |
| **Animation** | Simple `withAnimation(.easeOut)` rotation |
| **ViewModel** | `@Observable` with `spin()` method |
| **Data** | Hardcoded 1 category, 3 restaurants |
| **ResultsView** | Sheet showing restaurant names only |
| **Navigation** | `.sheet` presentation on spin complete |

### Skeleton Acceptance Criteria
- [ ] App launches without crash
- [ ] Wheel displays with colored sectors
- [ ] Tapping wheel triggers rotation animation
- [ ] After spin, results sheet appears
- [ ] Sheet shows 3 restaurant names
- [ ] Can dismiss sheet and spin again

### Skeleton Code Outline

```swift
// App Entry
@main
struct DiningDeciderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Main View (Skeleton)
struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var showResults = false

    var body: some View {
        VStack {
            WheelView(rotation: $rotation)
                .onTapGesture { spin() }

            Text("Tap wheel to spin")
        }
        .sheet(isPresented: $showResults) {
            ResultsView(restaurants: mockRestaurants)
        }
    }

    func spin() {
        withAnimation(.easeOut(duration: 2)) {
            rotation += Double.random(in: 720...1080)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showResults = true
        }
    }
}

// Skeleton Data
let mockRestaurants = [
    Restaurant(name: "Test Restaurant 1", ...),
    Restaurant(name: "Test Restaurant 2", ...),
    Restaurant(name: "Test Restaurant 3", ...)
]
```

---

## Vertical Slices

### Slice 1: Draggable Wheel with Momentum
**Stories**: S1, S2

| Layer | Implementation |
|-------|----------------|
| UI | `DragGesture` on wheel, visual rotation follows finger |
| Logic | Calculate angular velocity from drag, apply momentum on release |
| Data | None (uses skeleton data) |

**Acceptance Criteria**:
- [ ] Can drag wheel in circular motion
- [ ] Wheel follows finger during drag
- [ ] Release triggers momentum spin
- [ ] Faster drag = more rotations
- [ ] Wheel decelerates naturally

**Files**:
```
Views/Components/SpinningWheelView.swift  (create)
Utilities/WheelPhysics.swift              (create)
```

---

### Slice 2: Real Categories & Restaurant Data
**Stories**: S3, S11

| Layer | Implementation |
|-------|----------------|
| UI | Wheel sectors show real category names |
| Logic | Map landing position to category, filter restaurants |
| Data | Load from `restaurants.json` with 3+ categories |

**Acceptance Criteria**:
- [ ] Wheel shows 6-8 category labels
- [ ] Spin lands on a specific category
- [ ] Results show restaurants from that category
- [ ] Each restaurant shows name + description

**Files**:
```
Data/restaurants.json                     (create)
Data/RestaurantLoader.swift               (create)
Models/Restaurant.swift                   (create)
Models/WheelSector.swift                  (create)
Utilities/WheelMath.swift                 (create)
```

---

### Slice 3: Current Location
**Stories**: S5

| Layer | Implementation |
|-------|----------------|
| UI | Location permission prompt, "Using current location" indicator |
| Logic | Request location, filter restaurants by distance |
| Data | Add coordinates to restaurants |

**Acceptance Criteria**:
- [ ] App requests location permission on first spin
- [ ] If granted, shows "📍 Current Location"
- [ ] Only restaurants within default radius (10mi) appear
- [ ] If no restaurants nearby, shows appropriate message

**Files**:
```
Services/LocationManager.swift            (create)
Utilities/DistanceCalculator.swift        (create)
Info.plist                                (add location usage description)
```

---

### Slice 4: Manual Location Entry
**Stories**: S6

| Layer | Implementation |
|-------|----------------|
| UI | Text field with city autocomplete, geocoding feedback |
| Logic | Geocode address string to coordinates |
| Data | None (reuses existing) |

**Acceptance Criteria**:
- [ ] If location denied, shows text input
- [ ] Can type city name or zip code
- [ ] Autocomplete suggestions appear
- [ ] Selected location is geocoded
- [ ] Restaurants filter based on manual location

**Files**:
```
Views/Components/LocationInputView.swift  (create)
Services/GeocodingService.swift           (create)
```

---

### Slice 5: Search Radius
**Stories**: S7

| Layer | Implementation |
|-------|----------------|
| UI | Segmented picker: 5 / 10 / 15 / 25 mi |
| Logic | Apply radius to distance filter |
| Data | None |

**Acceptance Criteria**:
- [ ] Radius picker visible below location
- [ ] Default is 10 mi
- [ ] Changing radius updates available restaurants
- [ ] Larger radius = more potential results

**Files**:
```
Views/Components/RadiusPicker.swift       (create)
ViewModels/DiningViewModel.swift          (update)
```

---

### Slice 6: Vibe Modes
**Stories**: S8, S10

| Layer | Implementation |
|-------|----------------|
| UI | 3 vibe buttons: Aesthetic / Splurge / Standard |
| Logic | Filter by price level, change wheel categories |
| Data | Define sectors per vibe in data |

**Acceptance Criteria**:
- [ ] Three vibe buttons with distinct colors
- [ ] Selecting vibe changes wheel categories
- [ ] Splurge shows only $$$ / $$$$ restaurants
- [ ] Standard shows only $ / $$ restaurants
- [ ] Aesthetic shows all with aesthetic flag

**Files**:
```
Views/Components/VibeSelector.swift       (create)
Data/wheel-sectors.json                   (create or embed in code)
Models/VibeMode.swift                     (create)
```

---

### Slice 7: Party Size & Pricing
**Stories**: S9, S12

| Layer | Implementation |
|-------|----------------|
| UI | Stepper for party size, price display in results |
| Logic | Calculate total = avgCost × partySize |
| Data | Ensure avgCost in all restaurant records |

**Acceptance Criteria**:
- [ ] Party size stepper (1-20)
- [ ] Results show per-person price
- [ ] Results show estimated total for party
- [ ] Price updates when party size changes

**Files**:
```
Views/Components/PartySizeStepper.swift   (create)
Views/ResultsView.swift                   (update)
```

---

### Slice 8: Maps Integration
**Stories**: S14

| Layer | Implementation |
|-------|----------------|
| UI | "Map" button on each restaurant card |
| Logic | Open Apple Maps with coordinates or query |
| Data | Ensure mapQuery field in data |

**Acceptance Criteria**:
- [ ] Each result card has Map button
- [ ] Tapping opens Apple Maps
- [ ] Maps shows correct restaurant location
- [ ] Works with coordinates (preferred) or search query

**Files**:
```
Utilities/MapsHelper.swift                (create)
Views/Components/RestaurantCard.swift     (update)
```

---

### Slice 9: Haptic Feedback
**Stories**: S4

| Layer | Implementation |
|-------|----------------|
| UI | None (system haptics) |
| Logic | Trigger haptics at key moments |
| Data | None |

**Acceptance Criteria**:
- [ ] Light haptic when touching wheel
- [ ] Medium haptic when releasing (spin starts)
- [ ] Success haptic when spin ends

**Files**:
```
Utilities/HapticManager.swift             (create)
Views/Components/SpinningWheelView.swift  (update)
```

---

### Slice 10: Parking Info
**Stories**: S13

| Layer | Implementation |
|-------|----------------|
| UI | Parking row with icon in restaurant card |
| Logic | None |
| Data | Ensure parking field populated |

**Acceptance Criteria**:
- [ ] Parking info displayed with car icon
- [ ] Shows "Street parking", "Valet", etc.
- [ ] Gracefully hidden if no parking info

**Files**:
```
Views/Components/RestaurantCard.swift     (update)
```

---

### Slice 11: Dark Mode
**Stories**: S16

| Layer | Implementation |
|-------|----------------|
| UI | Define color assets for light/dark |
| Logic | None (system handles switching) |
| Data | None |

**Acceptance Criteria**:
- [ ] App respects system appearance
- [ ] Colors adapt appropriately
- [ ] Wheel remains legible in both modes
- [ ] No hardcoded colors

**Files**:
```
Resources/Assets.xcassets/Colors/         (create color sets)
Extensions/Color+Theme.swift              (update)
```

---

### Slice 12: Spin Again Flow
**Stories**: S17

| Layer | Implementation |
|-------|----------------|
| UI | "Spin Again" button in results, smooth dismiss |
| Logic | Reset state, dismiss sheet |
| Data | None |

**Acceptance Criteria**:
- [ ] "Spin Again" button at bottom of results
- [ ] Tapping dismisses sheet
- [ ] Wheel is ready for new spin
- [ ] Previous result is cleared

**Files**:
```
Views/ResultsView.swift                   (update)
ViewModels/DiningViewModel.swift          (update)
```

---

## Implementation Phases

### Phase 1: Foundation (Slices 0-2)
```
Week 1
├── Skeleton: Tap-to-spin wheel with mock data
├── Slice 1: Drag gesture with momentum
└── Slice 2: Real categories & restaurant JSON
```

**Milestone**: Spinnable wheel with real restaurant results

---

### Phase 2: Location (Slices 3-5)
```
Week 2
├── Slice 3: Current location permission & filtering
├── Slice 4: Manual location entry with geocoding
└── Slice 5: Search radius picker
```

**Milestone**: Location-aware restaurant filtering

---

### Phase 3: Personalization (Slices 6-7)
```
Week 3
├── Slice 6: Vibe modes (Aesthetic/Splurge/Standard)
└── Slice 7: Party size & pricing
```

**Milestone**: Personalized recommendations

---

### Phase 4: Polish (Slices 8-12)
```
Week 4
├── Slice 8: Maps integration
├── Slice 9: Haptic feedback
├── Slice 10: Parking info
├── Slice 11: Dark mode
└── Slice 12: Spin again flow
```

**Milestone**: Production-ready MVP

---

## Definition of Done (Per Slice)

- [ ] All acceptance criteria met
- [ ] No compiler warnings
- [ ] Works on iPhone 15 Pro simulator (iOS 17+)
- [ ] Tested in both light and dark mode (after Slice 11)
- [ ] Code follows project structure
- [ ] Committed with descriptive message

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Location permission denied | Slice 4 provides manual fallback |
| No restaurants in area | Show friendly empty state message |
| Drag gesture conflicts | Use `simultaneousGesture` if needed |
| Animation performance | Profile with Instruments, simplify if needed |
| Data entry errors | Validate JSON schema on load |

---

## File Creation Order

```
Phase 1:
  1. DiningDeciderApp.swift
  2. Models/Restaurant.swift
  3. Models/WheelSector.swift
  4. Data/restaurants.json
  5. Data/RestaurantLoader.swift
  6. Utilities/WheelMath.swift
  7. Utilities/WheelPhysics.swift
  8. Views/ContentView.swift
  9. Views/Components/SpinningWheelView.swift
  10. Views/Components/WheelSectorShape.swift
  11. Views/ResultsView.swift
  12. ViewModels/DiningViewModel.swift

Phase 2:
  13. Services/LocationManager.swift
  14. Services/GeocodingService.swift
  15. Utilities/DistanceCalculator.swift
  16. Views/Components/LocationInputView.swift
  17. Views/Components/RadiusPicker.swift

Phase 3:
  18. Models/VibeMode.swift
  19. Views/Components/VibeSelector.swift
  20. Views/Components/PartySizeStepper.swift

Phase 4:
  21. Utilities/MapsHelper.swift
  22. Utilities/HapticManager.swift
  23. Views/Components/RestaurantCard.swift
  24. Extensions/Color+Theme.swift
  25. Resources/Assets.xcassets (colors)
```

---

## Success Metrics

| Metric | Target |
|--------|--------|
| App launch to spin | < 1 second |
| Spin animation FPS | 60 fps |
| Location acquisition | < 3 seconds |
| Geocoding response | < 2 seconds |
| Results display | < 500ms after spin ends |
