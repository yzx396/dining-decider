# Dining Decider - Implementation Plan

## Methodology

### Walking Skeleton
Build a minimal end-to-end working app first, proving the architecture works across all layers before adding features.

### Vertical Slicing
Each slice delivers complete functionality through all layers (UI → Logic → Data). No horizontal layer-by-layer building.

### Design-First Slicing
Each slice includes UI design matching the reference screenshots. No slice is "done" until it visually matches the design system.

---

## Current Implementation Status

> **Last Updated**: January 2026

### Summary
| Phase | Status | Completion |
|-------|--------|------------|
| Phase 1: Foundation (Slices 0-2) | ✅ Complete | 100% |
| Phase 2: Location (Slices 3-5) | ✅ Complete | 100% |
| Phase 3: Personalization (Slices 6-7) | ✅ Complete | 100% |
| Phase 4: Polish (Slices 8-12) | ✅ Complete | 100% |

### All Slices Complete
All 12 slices have been implemented. The MVP is production-ready.

### Architecture Note
State management is handled in `ContentView.swift` rather than a separate `DiningViewModel`. This approach works well for the current app complexity.

### DiningDeciderCore Package
Pure Swift logic has been extracted into a Swift Package for fast, simulator-free testing:
- `WheelMath.swift` - Sector landing calculations
- `WheelPhysics.swift` - Momentum & friction physics
- `DistanceCalculator.swift` - Haversine distance formula
- `HapticTypes.swift` - Haptic types & protocols
- `PartySize.swift` - Party size constants & validation
- `SearchRadius.swift` - Search radius options
- `PriceCalculator.swift` - Price formatting utilities
- `LuminanceCalculator.swift` - Color luminance & contrast
- `ThemeColorValues.swift` - Light/dark mode color hex constants

**Test Coverage**: 161+ tests running in ~0.01s

---

## Design System

> **Reference**: `docs/UX/` screenshots are the source of truth for visual design.
>
> **Note**: Location UI follows `docs/MVP.md` (current location + manual entry + radius), not the city dropdown in screenshots.

### Color Tokens

```swift
// Background & Surfaces
background:         #F0EFE9  // Warm cream
cardBackground:     #FFFFFF  // White
cardShadow:         0, 0, 0, 0.05

// Text
titleColor:         #5E5B52  // Muted charcoal
labelColor:         #999999  // Gray (section labels)
textPrimary:        #333333  // Dark gray

// Interactive
primaryButton:      #C8A299  // Dusty rose
primaryButtonText:  #FFFFFF
disabledButton:     #DDDDDD
borderColor:        #E0E0E0

// Vibe: Aesthetic (Pretty Pics)
vibeAesthetic:      #D98880  // Rose/coral
aestheticWheel:     [#E6B0AA, #D98880, #F1948A, #C39BD3,
                     #F5B7B1, #FAD7A0, #E8DAEF, #D7BDE2]

// Vibe: Splurge (Formal)
vibeSplurge:        #884EA0  // Deep purple
splurgeWheel:       [#884EA0, #AF7AC5, #7D3C98,
                     #5B2C6F, #D2B4DE, #A569BD]

// Vibe: Standard (Hungry/Save)
vibeStandard:       #7F8C8D  // Muted gray
standardWheel:      [#A4B494, #DCC7AA, #B5C0D0, #E4B7B2,
                     #C4C3D0, #9FAEB5, #D8DCD6, #C8A299]

// Wheel
wheelBorder:        #EAE8E1  // Beige
wheelCenter:        #FFFFFF  // White dot
```

### Typography

```swift
// Using San Francisco (system default)
sectionLabel:   .caption, weight: .medium, tracking: 0.5, uppercase
               color: labelColor

vibeButton:     .subheadline, weight: .medium

wheelCategory:  .caption, weight: .semibold
               color: white or dark depending on sector

buttonText:     .headline, weight: .semibold, tracking: 0.5

partySize:      .title2, weight: .medium
```

### Spacing & Sizing

```swift
// Spacing scale (multiples of 4)
spacing-xs:     4pt
spacing-sm:     8pt
spacing-md:     16pt
spacing-lg:     24pt
spacing-xl:     32pt

// Corner radius
radiusSmall:    8pt   // Buttons, inputs
radiusMedium:   12pt  // Cards
radiusLarge:    16pt  // Large buttons
radiusFull:     9999  // Pills

// Component sizes
wheelDiameter:  300pt (scales with screen)
wheelBorder:    8pt
wheelCenter:    50pt
buttonHeight:   56pt
cardPadding:    20pt
```

### Component Patterns

| Component | Style |
|-----------|-------|
| **Controls Card** | White bg, 12pt radius, subtle shadow, 20pt padding |
| **Section Label** | Uppercase, letter-spacing, gray color |
| **Dropdown** | Bordered, 8pt radius, chevron icon |
| **Stepper** | Horizontal: [-] value [+], icons in circles |
| **Vibe Buttons** | 3-up, pill shape, emoji prefix, selected has fill color |
| **Wheel** | Colored sectors, radial text, white center, beige border |
| **CTA Button** | Full width, pill shape, dusty rose, white text |
| **Footer** | Fork/knife icon, "Dining Decider" text |

### Screen Layouts

#### Main Screen (ContentView)
```
┌─────────────────────────────────────┐
│ ┌─────────────────────────────────┐ │
│ │  CURRENT LOCATION   PARTY SIZE  │ │
│ │  [San Francis... ▼] [- 2 +]     │ │
│ │                                 │ │
│ │  CIRCUMSTANCE / VIBE            │ │
│ │  [✨ Pretty] [💸 Splurge] [🍜 Hungry] │
│ └─────────────────────────────────┘ │
│                                     │
│           ┌───────────┐             │
│          ╱  Wheel     ╲            │
│         │   with       │           │
│         │  sectors     │           │
│          ╲            ╱            │
│           └───────────┘             │
│                                     │
│   ┌─────────────────────────────┐   │
│   │        SPIN WHEEL           │   │
│   └─────────────────────────────┘   │
│                                     │
│            🍴 Dining Decider        │
└─────────────────────────────────────┘
```

#### Results Sheet
```
┌─────────────────────────────────────┐
│          [Category Name]            │
│          Recommendations            │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Restaurant Name          [Map]  │ │
│ │ 💎 Luxury                       │ │
│ │ "Description quote here..."     │ │
│ │ 🚗 Parking info                 │ │
│ │ $65/person · ~$130 total        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Restaurant 2...                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Restaurant 3...                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│   ┌─────────────────────────────┐   │
│   │        SPIN AGAIN           │   │
│   └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## User Stories

### Epic 1: Core Spinning Experience
| ID | Story | Priority |
|----|-------|----------|
| CORE-01 | As a user, I want to spin a wheel so that I get a random dining category | P0 |
| CORE-02 | As a user, I want to drag the wheel to spin it so the interaction feels physical and fun | P0 |
| CORE-03 | As a user, I want to see restaurant recommendations after spinning so I know where to eat | P0 |
| CORE-04 | As a user, I want haptic feedback when spinning so the experience feels tactile | P1 |

### Epic 2: Location Awareness
| ID | Story | Priority |
|----|-------|----------|
| LOC-01 | As a user, I want results based on my current location so restaurants are nearby | P0 |
| LOC-02 | As a user, I want to enter a location manually so I can plan for trips or if I deny location access | P0 |
| LOC-03 | As a user, I want to set a search radius so I control how far I'm willing to travel | P1 |

### Epic 3: Personalization
| ID | Story | Priority |
|----|-------|----------|
| PERS-01 | As a user, I want to select a "vibe" so recommendations match my mood/occasion | P1 |
| PERS-02 | As a user, I want to set my party size so I can see estimated total cost | P1 |
| PERS-03 | As a user, I want the wheel categories to change based on vibe so options are relevant | P1 |

### Epic 4: Restaurant Details
| ID | Story | Priority |
|----|-------|----------|
| REST-01 | As a user, I want to see restaurant name and description so I can evaluate the option | P0 |
| REST-02 | As a user, I want to see pricing info so I know what to expect | P1 |
| REST-03 | As a user, I want to see parking info so I can plan my arrival | P2 |
| REST-04 | As a user, I want to open the restaurant in Maps so I can navigate there | P0 |

### Epic 5: Polish & Delight
| ID | Story | Priority |
|----|-------|----------|
| POL-01 | As a user, I want smooth animations so the app feels premium | P1 |
| POL-02 | As a user, I want the app to support dark mode so it matches my system preference | P2 |
| POL-03 | As a user, I want to spin again easily so I can get new options | P1 |

---

## Walking Skeleton (Slice 0)

**Goal**: Prove end-to-end architecture with minimal functionality AND establish visual foundation.

```
┌─────────────────────────────────────────────────────────────────┐
│                      WALKING SKELETON                           │
├─────────────────────────────────────────────────────────────────┤
│  UI Layer        │  Styled Wheel View → Styled Results Sheet    │
│  Design Layer    │  Color tokens, typography, basic components  │
│  Logic Layer     │  Spin → Random category → Filter data        │
│  Data Layer      │  Load 1 category, 3 restaurants from JSON    │
└─────────────────────────────────────────────────────────────────┘
```

### Skeleton Implementation

| Component | Minimal Implementation |
|-----------|------------------------|
| **Theme** | Color tokens in `Color+Theme.swift` |
| **WheelView** | Styled wheel with 4 colored sectors (aesthetic palette) |
| **Animation** | Simple `withAnimation(.easeOut)` rotation |
| **ViewModel** | `@Observable` with `spin()` method |
| **Data** | Hardcoded 1 category, 3 restaurants |
| **ResultsView** | Styled sheet with restaurant cards |
| **Navigation** | `.sheet` presentation on spin complete |

### Skeleton Acceptance Criteria

**Functionality**:
- [x] App launches without crash
- [x] Wheel displays with colored sectors
- [x] Tapping wheel triggers rotation animation
- [x] After spin, results sheet appears
- [x] Sheet shows 3 restaurant names
- [x] Can dismiss sheet and spin again

**Design** (compare to `docs/UX/iphone_screenshot_1.png`):
- [x] Background is warm cream (#F0EFE9)
- [x] Wheel has correct pastel colors
- [x] Wheel has white center dot
- [x] Wheel has beige border
- [x] Category text is radial and legible
- [x] Basic visual hierarchy established

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
**Stories**: CORE-01, CORE-02

| Layer | Implementation |
|-------|----------------|
| UI | `DragGesture` on wheel, visual rotation follows finger |
| Design | Smooth 60fps animation, no visual jank |
| Logic | Calculate angular velocity from drag, apply momentum on release |
| Data | None (uses skeleton data) |

**Acceptance Criteria**:

*Functionality*:
- [x] Can drag wheel in circular motion
- [x] Wheel follows finger during drag
- [x] Release triggers momentum spin
- [x] Faster drag = more rotations
- [x] Wheel decelerates naturally

*Design*:
- [x] Rotation is smooth (60fps)
- [x] No visual stuttering or jumping
- [x] Wheel feels "physical" and weighted
- [x] Deceleration curve feels natural

**Files**:
```
Views/Components/SpinningWheelView.swift  (created)
DiningDeciderCore/Sources/DiningDeciderCore/WheelPhysics.swift  (created)
```

---

### Slice 2: Real Categories & Restaurant Data
**Stories**: CORE-03, REST-01

| Layer | Implementation |
|-------|----------------|
| UI | Wheel sectors show real category names |
| Design | 8 sectors with aesthetic palette, radial text |
| Logic | Map landing position to category, filter restaurants |
| Data | Load from `restaurants.json` with 3+ categories |

**Acceptance Criteria**:

*Functionality*:
- [x] Wheel shows 8 category labels
- [x] Spin lands on a specific category
- [x] Results show restaurants from that category
- [x] Each restaurant shows name + description

*Design* (match `docs/UX/iphone_screenshot_1.png`):
- [x] 8 sectors with pastel colors from aesthetic palette
- [x] Text is rotated radially (readable from center)
- [x] Text is white or dark based on sector brightness
- [x] Sectors have clean edges (no gaps)
- [x] Results sheet has card-based layout

**Files**:
```
Data/restaurants.json                     (created)
Data/RestaurantLoader.swift               (created)
Models/Restaurant.swift                   (created)
Models/WheelSector.swift                  (created)
DiningDeciderCore/Sources/DiningDeciderCore/WheelMath.swift  (created)
```

---

### Slice 3: Current Location + Controls Card
**Stories**: LOC-01

| Layer | Implementation |
|-------|----------------|
| UI | Controls card with location display |
| Design | White card, subtle shadow, section labels |
| Logic | Request location, filter restaurants by distance |
| Data | Add coordinates to restaurants |

**Acceptance Criteria**:

*Functionality*:
- [x] App requests location permission on first spin
- [x] If granted, shows "📍 Current Location"
- [x] Only restaurants within default radius (10mi) appear
- [x] If no restaurants nearby, shows appropriate message

*Design* (card style from screenshots, location per MVP.md):
- [x] White controls card with rounded corners (12pt)
- [x] Subtle drop shadow on card
- [x] "LOCATION" label (uppercase, gray, small)
- [x] Shows "📍 Current Location" pill/badge when using GPS
- [x] "Change" button to switch to manual entry
- [x] Proper spacing between elements (16-20pt)

**Files**:
```
Services/LocationManager.swift            (created)
DiningDeciderCore/Sources/DiningDeciderCore/DistanceCalculator.swift  (created)
Views/Components/ControlsCard.swift       (created)
Info.plist                                (location usage description added)
```

---

### Slice 4: Manual Location Entry
**Stories**: LOC-02

| Layer | Implementation |
|-------|----------------|
| UI | Text field with city autocomplete, geocoding feedback |
| Design | Matches dropdown style, clear affordance |
| Logic | Geocode address string to coordinates |
| Data | None (reuses existing) |

**Acceptance Criteria**:

*Functionality*:
- [x] If location denied, shows text input
- [x] Can type city name or zip code
- [x] Autocomplete suggestions appear
- [x] Selected location is geocoded
- [x] Restaurants filter based on manual location

*Design*:
- [x] Text field matches dropdown visual style
- [x] Clear placeholder text ("Enter city or zip")
- [x] Autocomplete list has clean styling
- [x] Loading state while geocoding
- [x] Smooth transition between current/manual modes

**Files**:
```
Views/Components/LocationInputView.swift  (created)
Services/GeocodingService.swift           (created)
```

---

### Slice 5: Search Radius
**Stories**: LOC-03

| Layer | Implementation |
|-------|----------------|
| UI | Segmented picker: 5 / 10 / 15 / 25 mi |
| Design | Subtle segmented control, fits card layout |
| Logic | Apply radius to distance filter |
| Data | None |

**Acceptance Criteria**:

*Functionality*:
- [x] Radius picker visible below location
- [x] Default is 10 mi
- [x] Changing radius updates available restaurants
- [x] Larger radius = more potential results

*Design*:
- [x] Compact segmented control or pill buttons
- [x] Selected state clearly visible
- [x] "SEARCH RADIUS" label above (matches section label style)
- [x] Fits within controls card layout
- [x] Consistent spacing with other controls

**Files**:
```
Views/Components/RadiusPicker.swift       (created)
DiningDeciderCore/Sources/DiningDeciderCore/SearchRadius.swift  (created)
ContentView.swift                         (state managed in ContentView)
```

---

### Slice 6: Vibe Modes
**Stories**: PERS-01, PERS-03

| Layer | Implementation |
|-------|----------------|
| UI | 3 vibe buttons: Aesthetic / Splurge / Standard |
| Design | Pill buttons with emoji, distinct vibe colors |
| Logic | Filter by price level, change wheel categories |
| Data | Define sectors per vibe in data |

**Acceptance Criteria**:

*Functionality*:
- [x] Three vibe buttons with distinct colors
- [x] Selecting vibe changes wheel categories
- [x] Splurge shows only $$$ / $$$$ restaurants
- [x] Standard shows only $ / $$ restaurants
- [x] Aesthetic shows all price levels

*Design* (match all 3 screenshots):
- [x] 3 equal-width pill buttons in a row
- [x] Each has emoji prefix (✨ 💸 🍜)
- [x] Unselected: white bg, gray border
- [x] Selected colors:
  - Pretty Pics: #D98880 (dusty rose)
  - Splurge: #884EA0 (deep purple)
  - Hungry/Save: #7F8C8D (muted gray)
- [x] White text when selected
- [x] Wheel colors change to match vibe palette
- [x] "CIRCUMSTANCE / VIBE" label above

**Files**:
```
Views/Components/VibeSelector.swift       (created)
Models/VibeMode.swift                     (created, includes wheel sectors)
Models/WheelSector.swift                  (created, mode-specific sectors embedded)
```

---

### Slice 7: Party Size & Pricing
**Stories**: PERS-02, REST-02

| Layer | Implementation |
|-------|----------------|
| UI | Stepper for party size, price display in results |
| Design | Circular +/- buttons, prominent number |
| Logic | Calculate total = avgCost × partySize |
| Data | Ensure avgCost in all restaurant records |

**Acceptance Criteria**:

*Functionality*:
- [x] Party size stepper (1-20)
- [x] Results show per-person price
- [x] Results show estimated total for party
- [x] Price updates when party size changes

*Design* (match `docs/UX/iphone_screenshot_1.png`):
- [x] "PARTY SIZE" label (uppercase, gray)
- [x] Horizontal layout: [−] number [+]
- [x] +/- icons in circular bordered buttons
- [x] Number is large and prominent (.title2)
- [x] Buttons disable at min (1) and max (20)
- [x] Disabled state: gray icons

**Files**:
```
Views/Components/PartySizeStepper.swift   (created)
Views/ResultsView.swift                   (created)
DiningDeciderCore/Sources/DiningDeciderCore/PartySize.swift  (created)
DiningDeciderCore/Sources/DiningDeciderCore/PriceCalculator.swift  (created)
```

---

### Slice 8: Maps Integration + Restaurant Cards
**Stories**: REST-04

| Layer | Implementation |
|-------|----------------|
| UI | "Map" button on each restaurant card |
| Design | Clean card layout with map button |
| Logic | Open Apple Maps with coordinates or query |
| Data | Ensure mapQuery field in data |

**Acceptance Criteria**:

*Functionality*:
- [x] Each result card has Map button
- [x] Tapping opens Apple Maps
- [x] Maps shows correct restaurant location
- [x] Works with coordinates (preferred) or search query

*Design*:
- [x] Restaurant card: white bg, rounded corners, shadow
- [x] Card header: Restaurant name (bold) + Map button (right aligned)
- [x] Map button: SF Symbol `map.fill`, dusty rose color
- [x] Clear visual hierarchy within card
- [x] Cards have consistent spacing in list

**Files**:
```
Utilities/MapsHelper.swift                (created)
Views/Components/RestaurantCard.swift     (created)
Views/ResultsView.swift                   (created)
```

---

### Slice 9: Haptic Feedback
**Stories**: CORE-04

| Layer | Implementation |
|-------|----------------|
| UI | None (system haptics) |
| Logic | Trigger haptics at key moments |
| Data | None |

**Acceptance Criteria**:

*Functionality*:
- [x] Light haptic when touching wheel
- [x] Medium haptic when releasing (spin starts)
- [x] Success haptic when spin ends

*Design (feel)*:
- [x] Haptics feel "premium" and intentional
- [x] Not too frequent (avoid haptic fatigue)
- [x] Enhances physical feel of wheel interaction

**Files**:
```
Utilities/HapticManager.swift             (created)
DiningDeciderCore/Sources/DiningDeciderCore/HapticTypes.swift  (created)
Views/Components/SpinningWheelView.swift  (created, with haptic integration)
```

---

### Slice 10: Parking Info + Full Card Design
**Stories**: REST-03

| Layer | Implementation |
|-------|----------------|
| UI | Complete restaurant card with all details |
| Design | Price tag, description, parking row |
| Logic | None |
| Data | Ensure parking field populated |

**Acceptance Criteria**:

*Functionality*:
- [x] Parking info displayed with car icon
- [x] Shows "Street parking", "Valet", etc.
- [x] Gracefully hidden if no parking info

*Design*:
- [x] Price level tag (💎 Luxury, ✨ Premium, 📸 Aesthetic, 💰 Value)
- [x] Description in quotes, italic style
- [x] Parking row: 🚗 icon + text, muted color
- [x] Price row: "$XX/person · ~$XXX total"
- [x] Consistent vertical spacing within card
- [x] All text legible and properly sized

**Files**:
```
Views/Components/RestaurantCard.swift     (created, complete implementation)
```

---

### Slice 11: Dark Mode
**Stories**: POL-02

| Layer | Implementation |
|-------|----------------|
| UI | Define color assets for light/dark |
| Design | Dark variants of all theme colors |
| Logic | None (system handles switching) |
| Data | None |

**Acceptance Criteria**:

*Functionality*:
- [x] App respects system appearance
- [x] Colors adapt appropriately
- [x] Wheel remains legible in both modes
- [x] No hardcoded colors in views

*Design*:
- [x] Dark background: #1C1C1E or similar
- [x] Cards: #2C2C2E (elevated surface)
- [x] Text inverts appropriately
- [x] Wheel colors remain vibrant in dark mode
- [x] Button colors maintain sufficient contrast
- [x] Shadows adjust for dark mode (lighter or removed)
- [x] All UI elements tested in both modes

**Files**:
```
DiningDeciderCore/Sources/DiningDeciderCore/ThemeColorValues.swift  (created)
DiningDecider/Assets.xcassets/Colors/     (created - 10 color sets with light/dark variants)
Extensions/Color+Theme.swift              (updated to use asset colors)
DiningDeciderTests/Extensions/ColorDarkModeTests.swift  (created - 19 tests)
DiningDeciderCore/Tests/DiningDeciderCoreTests/ThemeColorValuesTests.swift  (created - 20 tests)
```

---

### Slice 12: Spin Again Flow + CTA Buttons
**Stories**: POL-03

| Layer | Implementation |
|-------|----------------|
| UI | "Spin Again" button in results, smooth dismiss |
| Design | Consistent CTA button styling |
| Logic | Reset state, dismiss sheet |
| Data | None |

**Acceptance Criteria**:

*Functionality*:
- [x] "Spin Again" button at bottom of results
- [x] Tapping dismisses sheet
- [x] Wheel is ready for new spin
- [x] Previous result is cleared

*Design* (CTA buttons match screenshots):
- [x] Full-width pill shape button
- [x] Background: dusty rose (#C8A299)
- [x] Text: white, uppercase, letter-spacing
- [x] Height: 56pt
- [x] Corner radius: full (pill)
- [x] Subtle shadow beneath
- [x] Consistent with main "SPIN WHEEL" button style
- [x] Smooth sheet dismiss animation

**Files**:
```
Views/ResultsView.swift                   (created, includes Spin Again button)
ContentView.swift                         (state managed here instead of separate ViewModel)
```

---

## Implementation Phases

### Phase 1: Foundation (Slices 0-2) ✅ COMPLETE
```
├── Skeleton: Tap-to-spin wheel with mock data ✅
├── Slice 1: Drag gesture with momentum ✅
└── Slice 2: Real categories & restaurant JSON ✅
```

**Milestone**: Spinnable wheel with real restaurant results ✅

---

### Phase 2: Location (Slices 3-5) ✅ COMPLETE
```
├── Slice 3: Current location permission & filtering ✅
├── Slice 4: Manual location entry with geocoding ✅
└── Slice 5: Search radius picker ✅
```

**Milestone**: Location-aware restaurant filtering ✅

---

### Phase 3: Personalization (Slices 6-7) ✅ COMPLETE
```
├── Slice 6: Vibe modes (Aesthetic/Splurge/Standard) ✅
└── Slice 7: Party size & pricing ✅
```

**Milestone**: Personalized recommendations ✅

---

### Phase 4: Polish (Slices 8-12) ✅ COMPLETE
```
├── Slice 8: Maps integration ✅
├── Slice 9: Haptic feedback ✅
├── Slice 10: Parking info ✅
├── Slice 11: Dark mode ✅
└── Slice 12: Spin again flow ✅
```

**Milestone**: Production-ready MVP ✅

---

## Definition of Done (Per Slice)

### Functionality
- [ ] All functional acceptance criteria met
- [ ] No compiler warnings
- [ ] Works on iPhone 17 Pro simulator (iOS 17+)
- [ ] Code follows project structure
- [ ] Committed with descriptive message

### Testing (TDD Required)
- [ ] Tests written BEFORE implementation
- [ ] All tests pass
- [ ] ViewModel tests cover all public methods
- [ ] Utility functions have unit tests
- [ ] Services use protocol mocks

### Design
- [ ] All design acceptance criteria met
- [ ] Visually compare to reference screenshots (where applicable)
- [ ] Colors match design tokens exactly
- [ ] Typography matches specifications
- [ ] Spacing is consistent (4pt grid)
- [ ] Tested in both light and dark mode (after Slice 11)
- [ ] No visual regressions in other screens

### Accessibility
- [ ] VoiceOver labels on interactive elements
- [ ] Sufficient color contrast
- [ ] Touch targets minimum 44pt

---

## Design Review Checkpoints

| After Slice | Review Focus |
|-------------|--------------|
| Slice 0 | Theme foundation: background, wheel colors, basic hierarchy |
| Slice 2 | Wheel polish: sectors, text legibility, center dot, border |
| Slice 3 | Controls card: shadows, labels, layout |
| Slice 6 | Vibe selector: button states, color accuracy, wheel color changes |
| Slice 8 | Restaurant cards: layout, typography, spacing |
| Slice 11 | Dark mode: all screens, contrast, legibility |
| Slice 12 | Final polish: animations, transitions, overall consistency |

### Design QA Checklist (Final)

**Colors**:
- [ ] Background is warm cream in light mode
- [ ] All vibe colors are accurate
- [ ] Wheel palettes match per vibe
- [ ] Button colors are correct

**Typography**:
- [ ] Section labels are uppercase + gray
- [ ] Hierarchy is clear (titles > body > captions)
- [ ] No truncation issues

**Components**:
- [ ] Cards have consistent shadows
- [ ] Buttons have correct corner radius
- [ ] Spacing follows 4pt grid
- [ ] All interactive states work (hover, pressed, disabled)

**Animation**:
- [ ] Wheel spins smoothly at 60fps
- [ ] Sheet presentation is smooth
- [ ] No visual jank or stuttering

**Consistency**:
- [ ] Same component looks identical across screens
- [ ] Dark mode maintains brand feel
- [ ] Responsive to different iPhone sizes

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

## File Creation Order (Actual Implementation)

```
Phase 0 (Skeleton - Design Foundation): ✅ COMPLETE
  1. Extensions/Color+Theme.swift        # Design tokens ✅
  2. DiningDeciderApp.swift              ✅
  3. ContentView.swift                   # State managed here (no separate ViewModel) ✅
  4. Views/Components/WheelSectorShape.swift ✅
  5. Views/Components/SpinningWheelView.swift ✅
  6. Views/ResultsView.swift             ✅

Phase 1 (Core): ✅ COMPLETE
  7. Models/Restaurant.swift             ✅
  8. Models/WheelSector.swift            ✅
  9. Data/restaurants.json               ✅
  10. Data/RestaurantLoader.swift        ✅
  11. DiningDeciderCore/WheelMath.swift  # Extracted to package ✅
  12. DiningDeciderCore/WheelPhysics.swift ✅

Phase 2 (Location): ✅ COMPLETE
  13. Services/LocationManager.swift     ✅
  14. Services/GeocodingService.swift    ✅
  15. DiningDeciderCore/DistanceCalculator.swift ✅
  16. Views/Components/ControlsCard.swift ✅
  17. Views/Components/LocationInputView.swift ✅
  18. Views/Components/RadiusPicker.swift ✅
  19. DiningDeciderCore/SearchRadius.swift ✅

Phase 3 (Personalization): ✅ COMPLETE
  20. Models/VibeMode.swift              ✅
  21. Views/Components/VibeSelector.swift ✅
  22. Views/Components/PartySizeStepper.swift ✅
  23. DiningDeciderCore/PartySize.swift  ✅
  24. DiningDeciderCore/PriceCalculator.swift ✅

Phase 4 (Polish): ✅ COMPLETE
  25. Utilities/MapsHelper.swift         ✅
  26. Utilities/HapticManager.swift      ✅
  27. DiningDeciderCore/HapticTypes.swift ✅
  28. Views/Components/RestaurantCard.swift ✅
  29. DiningDeciderCore/LuminanceCalculator.swift ✅
  30. DiningDeciderCore/ThemeColorValues.swift ✅
  31. Assets.xcassets/Colors/             ✅ (10 color sets with light/dark)
  32. Extensions/Color+Theme.swift        ✅ (updated for adaptive colors)

Additional Files Created:
  - DiningDeciderCore/Package.swift     # Swift Package for core logic
  - Tests (161+ total: 141 in DiningDeciderCore + 20+ in main app)
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

---

## Testing Examples

> **TDD is mandatory**: Write tests BEFORE implementation. Red → Green → Refactor.

### Protocol Pattern for Testability

All services should have protocols to enable mocking in tests:

```swift
// MARK: - Protocol
protocol RestaurantLoading {
    func restaurants(for category: String) throws -> [Restaurant]
    var allCategories: [String] { get }
}

// MARK: - Production Implementation
final class RestaurantLoader: RestaurantLoading {
    private let restaurants: [String: [Restaurant]]

    init(bundle: Bundle = .main) throws {
        // Load from JSON...
    }

    func restaurants(for category: String) throws -> [Restaurant] {
        guard let list = restaurants[category] else {
            throw RestaurantLoaderError.categoryNotFound(category)
        }
        return list
    }

    var allCategories: [String] {
        Array(restaurants.keys)
    }
}

// MARK: - Mock for Testing
final class MockRestaurantLoader: RestaurantLoading {
    var mockRestaurants: [String: [Restaurant]] = [:]
    var shouldThrowError: RestaurantLoaderError?

    func restaurants(for category: String) throws -> [Restaurant] {
        if let error = shouldThrowError { throw error }
        return mockRestaurants[category] ?? []
    }

    var allCategories: [String] {
        Array(mockRestaurants.keys)
    }
}
```

### Example: WheelMath Tests

```swift
// WheelMathTests.swift
import XCTest
@testable import DiningDecider

final class WheelMathTests: XCTestCase {

    func test_landingSector_withZeroRotation_returnsFirstSector() {
        // Given
        let sectorCount = 8
        let rotation = 0.0

        // When
        let index = WheelMath.landingSector(rotation: rotation, sectorCount: sectorCount)

        // Then
        XCTAssertEqual(index, 0)
    }

    func test_landingSector_withFullRotation_returnsFirstSector() {
        // Given
        let sectorCount = 8
        let rotation = 360.0

        // When
        let index = WheelMath.landingSector(rotation: rotation, sectorCount: sectorCount)

        // Then
        XCTAssertEqual(index, 0)
    }

    func test_landingSector_withPartialRotation_returnsCorrectSector() {
        // Given: 8 sectors, each 45 degrees
        let sectorCount = 8
        let rotation = 90.0  // Should land on sector 2

        // When
        let index = WheelMath.landingSector(rotation: rotation, sectorCount: sectorCount)

        // Then
        XCTAssertEqual(index, 2)
    }

    func test_angularVelocity_calculatesFromDragDistance() {
        // Given
        let startAngle = 0.0
        let endAngle = Double.pi / 2  // 90 degrees
        let duration = 0.1  // seconds

        // When
        let velocity = WheelMath.angularVelocity(
            startAngle: startAngle,
            endAngle: endAngle,
            duration: duration
        )

        // Then: velocity = angle / time = (π/2) / 0.1 ≈ 15.7 rad/s
        XCTAssertEqual(velocity, Double.pi / 2 / 0.1, accuracy: 0.01)
    }
}
```

### Example: ViewModel Tests

```swift
// DiningViewModelTests.swift
import XCTest
@testable import DiningDecider

final class DiningViewModelTests: XCTestCase {

    var sut: DiningViewModel!
    var mockLoader: MockRestaurantLoader!
    var mockLocation: MockLocationProvider!

    override func setUp() {
        super.setUp()
        mockLoader = MockRestaurantLoader()
        mockLocation = MockLocationProvider()
        sut = DiningViewModel(
            restaurantLoader: mockLoader,
            locationProvider: mockLocation
        )
    }

    override func tearDown() {
        sut = nil
        mockLoader = nil
        mockLocation = nil
        super.tearDown()
    }

    // MARK: - Spin Tests

    func test_spin_setsIsSpinningToTrue() {
        // When
        sut.spin()

        // Then
        XCTAssertTrue(sut.isSpinning)
    }

    func test_spinComplete_loadsRestaurantsForLandedCategory() {
        // Given
        let expected = [Restaurant.mock(name: "Test Restaurant")]
        mockLoader.mockRestaurants["Italian"] = expected

        // When
        sut.spinComplete(landedCategory: "Italian")

        // Then
        XCTAssertEqual(sut.results, expected)
        XCTAssertFalse(sut.isSpinning)
        XCTAssertTrue(sut.showResults)
    }

    func test_spinComplete_withNoRestaurants_showsEmptyState() {
        // Given
        mockLoader.mockRestaurants["Italian"] = []

        // When
        sut.spinComplete(landedCategory: "Italian")

        // Then
        XCTAssertTrue(sut.results.isEmpty)
        XCTAssertTrue(sut.showResults)
    }

    // MARK: - Vibe Tests

    func test_selectVibe_updatesCurrentVibe() {
        // When
        sut.selectVibe(.splurge)

        // Then
        XCTAssertEqual(sut.currentVibe, .splurge)
    }

    func test_selectVibe_updatesWheelCategories() {
        // When
        sut.selectVibe(.splurge)

        // Then
        XCTAssertEqual(sut.wheelCategories, VibeMode.splurge.categories)
    }

    // MARK: - Party Size Tests

    func test_incrementPartySize_increasesCount() {
        // Given
        sut.partySize = 2

        // When
        sut.incrementPartySize()

        // Then
        XCTAssertEqual(sut.partySize, 3)
    }

    func test_incrementPartySize_atMax_doesNotExceedMax() {
        // Given
        sut.partySize = 20

        // When
        sut.incrementPartySize()

        // Then
        XCTAssertEqual(sut.partySize, 20)
    }
}
```

### Example: Location Provider Mock

```swift
// MockLocationProvider.swift (in Tests target)
import CoreLocation
@testable import DiningDecider

final class MockLocationProvider: LocationProviding {
    var currentLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var requestPermissionCalled = false

    func requestPermission() {
        requestPermissionCalled = true
    }
}

// Usage in tests
func test_filtersByLocation_whenLocationAvailable() {
    // Given
    mockLocation.currentLocation = CLLocationCoordinate2D(
        latitude: 37.7749,
        longitude: -122.4194
    )
    mockLocation.authorizationStatus = .authorizedWhenInUse

    let nearbyRestaurant = Restaurant.mock(lat: 37.78, lng: -122.42)
    let farRestaurant = Restaurant.mock(lat: 40.71, lng: -74.00)
    mockLoader.mockRestaurants["Italian"] = [nearbyRestaurant, farRestaurant]

    // When
    sut.spinComplete(landedCategory: "Italian")

    // Then
    XCTAssertEqual(sut.results.count, 1)
    XCTAssertEqual(sut.results.first?.name, nearbyRestaurant.name)
}
```

### Example: Distance Calculator Tests

```swift
// DistanceCalculatorTests.swift
import XCTest
import CoreLocation
@testable import DiningDecider

final class DistanceCalculatorTests: XCTestCase {

    func test_distance_betweenSamePoint_isZero() {
        // Given
        let point = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // When
        let distance = DistanceCalculator.distanceInMiles(from: point, to: point)

        // Then
        XCTAssertEqual(distance, 0, accuracy: 0.001)
    }

    func test_distance_sfToOakland_isApproximately10Miles() {
        // Given
        let sf = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let oakland = CLLocationCoordinate2D(latitude: 37.8044, longitude: -122.2712)

        // When
        let distance = DistanceCalculator.distanceInMiles(from: sf, to: oakland)

        // Then: SF to Oakland is roughly 10 miles
        XCTAssertEqual(distance, 10, accuracy: 2)
    }

    func test_isWithinRadius_returnsTrue_whenInRange() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let nearby = CLLocationCoordinate2D(latitude: 37.78, longitude: -122.42)

        // When
        let isWithin = DistanceCalculator.isWithinRadius(
            point: nearby,
            center: center,
            radiusMiles: 5
        )

        // Then
        XCTAssertTrue(isWithin)
    }
}
```

### Test Helpers

```swift
// Restaurant+Mock.swift (in Tests target)
extension Restaurant {
    static func mock(
        id: UUID = UUID(),
        name: String = "Test Restaurant",
        lat: Double = 37.7749,
        lng: Double = -122.4194,
        priceLevel: Int = 2,
        averageCost: Int = 25,
        description: String = "A test restaurant",
        parking: String = "Street parking",
        mapQuery: String = "Test Restaurant SF"
    ) -> Restaurant {
        Restaurant(
            id: id,
            name: name,
            lat: lat,
            lng: lng,
            priceLevel: priceLevel,
            averageCost: averageCost,
            description: description,
            parking: parking,
            mapQuery: mapQuery
        )
    }
}
```

### Test File Structure (Actual Implementation)

```
DiningDeciderCore/Tests/DiningDeciderCoreTests/  # 161+ fast tests (~0.01s)
├── WheelMathTests.swift
├── WheelPhysicsTests.swift
├── DistanceCalculatorTests.swift
├── LuminanceCalculatorTests.swift
├── HapticManagerTests.swift
├── PartySizeTests.swift
├── SearchRadiusTests.swift
├── PriceCalculatorTests.swift
└── ThemeColorValuesTests.swift          # Dark mode color constants (20 tests)

DiningDeciderTests/                              # Main app tests (require simulator)
├── Mocks/
│   ├── MockLocationProvider.swift
│   ├── MockGeocodingService.swift
│   └── MockHapticProvider.swift
├── Models/
│   ├── RestaurantTests.swift
│   └── VibeModeTests.swift
├── Views/
│   ├── VibeSelectorTests.swift
│   ├── RestaurantCardTests.swift
│   └── SpinningWheelViewHapticTests.swift
├── Services/
│   ├── LocationManagerTests.swift
│   ├── RestaurantLoaderTests.swift
│   └── GeocodingServiceTests.swift
├── Utilities/
│   └── MapsHelperTests.swift
└── Extensions/
    ├── ColorLuminanceTests.swift
    └── ColorDarkModeTests.swift         # Dark mode adaptation tests (19 tests)
```
