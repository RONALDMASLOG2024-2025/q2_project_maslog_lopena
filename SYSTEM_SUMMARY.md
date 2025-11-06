# 📊 GreenWise - System Summary
**Technical Overview & Statistics**

Version: 1.4.0+4 | November 6, 2025

---

## 🎯 System Overview

**GreenWise** is a cross-platform mobile application built with Flutter that promotes sustainable electronics practices through daily eco-tips and habit-forming interactions.

### Core Purpose
Help users reduce their electronic waste footprint through:
- Daily actionable eco-tips
- Habit tracking and streaks
- Educational content about environmental impact
- Resources for responsible e-waste disposal

---

## 📱 Technical Specifications

### Platform Support
- **Primary:** Android 7.0+ (API Level 24+)
- **Architecture:** ARM64-v8a, ARMv7, x86_64
- **Future:** iOS, Web, Desktop (via Flutter)

### Build Information
- **Current Version:** 1.4.0 (build 4)
- **APK Size (ARM64):** 18.5 MB
- **APK Size (ARMv7):** 16.3 MB
- **APK Size (x86_64):** 19.7 MB
- **Minimum SDK:** 24 (Android 7.0 Nougat)
- **Target SDK:** 36 (Android 12+)
- **Compile SDK:** 36

### Technology Stack
- **Framework:** Flutter 3.35.1-stable
- **Language:** Dart ^3.9.0
- **State Management:** Riverpod ^2.6.1
- **Local Storage:** 
  - Hive (settings)
  - SharedPreferences (completions/streaks)
  - SQLite (tips database - desktop only)
- **Notifications:** flutter_local_notifications + Native Android AlarmManager
- **External Links:** url_launcher ^6.3.1
- **Utilities:** connectivity_plus, http, flutter_svg

---

## 📊 Content Statistics

### Eco-Tips Database
- **Total Tips:** 365 (one for every day of the year)
- **Approved Source Tips:** 52 (14.2%)
- **AI-Generated Tips:** 313 (85.8%)

#### Approved Sources Breakdown
- **PCMag:** 9 tips (device maintenance, optimization)
- **LG Electronics:** 4 tips (battery care, longevity)
- **Natural History Museum UK:** 6 tips (e-waste impact, recycling)
- **Honor:** 7 tips (Android device care)
- **Norton:** 10 tips (computer maintenance)
- **EPA:** 6 tips (e-waste disposal guidelines)
- **Android Authority:** 10 tips (battery health, charging)

#### Tips by Category
- **Energy Saving:** ~35% (battery, power management)
- **Device Care:** ~30% (maintenance, longevity)
- **Responsible Disposal:** ~20% (recycling, trade-in)
- **Eco-Buying:** ~15% (sustainable purchasing)

### Recycling Resources
- **Total Resources:** 17 programs
- **Local Philippines:** 4 resources
- **National Philippines:** 5 programs
- **International:** 8 global programs

---

## 🏗️ Architecture

### Feature-First Organization
```
lib/
├── main.dart                 # App entry, initialization
├── app_shell.dart           # 4-tab navigation
├── core/                    # Shared (theme, constants)
├── data/                    # Models, repositories
├── features/                # Feature modules
│   ├── common/             # Shared widgets (EcoNavBar)
│   ├── onboarding/         # Welcome flow
│   ├── progress/           # Streaks, stats, heatmap
│   ├── resources/          # Recycling directory
│   ├── tips/               # Daily tips feed
│   └── settings/           # Preferences
├── services/               # Platform services
└── splash/                 # Initialization screen
```

### State Management Pattern
- **Provider-based architecture:** All state via Riverpod providers
- **No singletons:** Repository pattern with dependency injection
- **Reactive UI:** Providers automatically notify widgets of changes
- **Invalidation cascade:** Mutations trigger dependent provider updates

### Data Flow
1. User completes tip → `completeTodayProvider`
2. Update SharedPreferences → Store completion date
3. Invalidate dependent providers:
   - `streakProvider` (recalculate streak)
   - `weeklyCompletionProvider` (update weekly stats)
   - `recentCompletionsProvider` (refresh 30-day data)
   - `weeklyDaysProvider` (update heatmap)
4. UI automatically rebuilds with new state

---

## 🔧 Key Features Implementation

### Daily Tips System
- **Deterministic rotation:** Daily tip = `date.dayOfYear % 365`
- **Category filtering:** Filter by user-enabled categories in settings
- **Infinite feed:** Vertical PageView with prefetching
- **Explanations:** Most tips include "Why it matters" context

### Progress Tracking
- **Weekly completion ring:** Shows current week progress (Sun-Sat)
- **Streak calculation:** Counts consecutive days from SharedPreferences
- **30-day heatmap:** Visual grid of last 30 days activity
- **Sliding window stats:** Dynamic calculation of completions in time range

### Notifications (Native Implementation)
- **Android AlarmManager.setAlarmClock()** for exact scheduling
- **BigPictureStyle notifications** with eco-themed images
- **Daily reminder:** Scheduled at user-preferred time
- **Exact alarm permission:** Required on Android 12+ for precise timing

### Recycling Directory
- **Static JSON data:** Local resource list
- **External browser launch:** Opens URLs via url_launcher
- **Categorized sections:** Local, National, International
- **Offline-first:** Data stored locally, only links need internet

---

## 🎨 Design System

### GreenWise Design Language
- **Color palette:** Earth tones (greens, blues, oranges)
- **Card style:** Frosted glass gradient effect (GWCard)
- **Typography:** Clean, readable system fonts
- **Spacing:** Consistent 8px grid (GWDs constants)
- **Accessibility:** Reduce motion toggle, high contrast

### Navigation
- **Custom EcoNavBar:** 4-tab bottom navigation
- **Vertical tip feed:** PageView with parallax card scaling
- **Smooth transitions:** Respects reduce motion setting

---

## 🔐 Privacy & Data Handling

### Data Storage (All Local)
- **Settings:** Hive box (`settings_box`)
- **Completions:** SharedPreferences (`completed_tip_YYYY-MM-DD`)
- **Streaks:** SharedPreferences (`streak_state_v1`)
- **Tips database:** SQLite (desktop), JSON asset (mobile)

### Privacy Guarantees
- ✅ **No network calls** for core functionality
- ✅ **No analytics** or tracking
- ✅ **No user accounts** required
- ✅ **No personal data** collection
- ✅ **Device-only storage**
- ✅ **No cloud sync** (currently)

### Permissions
- **Notifications:** Optional, for daily reminders
- **Exact alarms (Android 12+):** For precise notification timing
- **Internet:** Only for opening recycling directory links
- **Storage:** Implicit, for local data persistence

---

## 📈 Performance Optimizations

### v1.4.0 Improvements
- **Removed debug symbols:** Reduced APK size by 90% (428MB → 18.5MB)
- **Removed native debug info:** Eliminated `debugSymbolLevel = "FULL"`
- **Removed symbol preservation:** Deleted `keepDebugSymbols` packaging option
- **Split APKs by ABI:** Users download only needed architecture

### Resource Efficiency
- **Icon tree-shaking:** MaterialIcons reduced from 1.6MB to 10KB (99.4% reduction)
- **Lazy loading:** Providers load data on-demand
- **Minimal background processing:** No continuous sync or tracking
- **Offline-first:** No network dependency for core features

---

## 🧪 Testing & Quality

### Test Coverage
- **Unit tests:** Streak calculation, completion logic
- **Widget tests:** UI component rendering
- **Integration tests:** Navigation, state updates
- **Test suite:** 6/6 passing ✅

### Known Limitations
- **No cloud backup:** Progress lost if app uninstalled
- **No cross-device sync:** Progress tied to single device
- **No tip filtering UI:** Category filter set via settings (future enhancement)
- **No multi-language support:** English only (i18n planned)

---

## 🗺️ Roadmap & Future Enhancements

### Planned Features
- [ ] **Tip category filters** - UI to show/hide categories
- [ ] **Gamification** - Badges, achievements, milestones
- [ ] **Social sharing** - Share tips or streaks with friends
- [ ] **Carbon impact estimation** - Calculate total environmental impact
- [ ] **Multi-language support** - Filipino, Spanish, etc.
- [ ] **Cloud backup (optional)** - Preserve progress across devices
- [ ] **Widget support** - Home screen tip widget
- [ ] **Wear OS companion** - Quick tip glances on smartwatch

### Infrastructure Improvements
- [ ] **Backend integration** - Optional Firebase/Supabase for sync
- [ ] **A/B testing** - Optimize onboarding and engagement
- [ ] **Analytics (privacy-first)** - Aggregate usage insights (opt-in)
- [ ] **Push notifications** - Smart reminders based on usage patterns
- [ ] **In-app tip submission** - User-contributed eco-tips

---

## 📝 Development Notes

### Build Commands
```powershell
# Development
flutter run

# Release build (split APKs)
flutter build apk --split-per-abi --release

# Release build (universal APK)
flutter build apk --release

# Clean build
flutter clean; flutter pub get; flutter build apk --split-per-abi --release
```

### Version History
- **v1.0.0** - Initial release (tips, progress, settings)
- **v1.3.0** - Native notification implementation
- **v1.3.1** - Notification images (BigPictureStyle)
- **v1.3.2** - Bug fixes (weekly progress, button state, explanations)
- **v1.4.0** - Debug UI removal, production release
- **v1.4.0+4** - Android compatibility fix (minSdk 24), size optimization

### Code Quality
- **Flutter analyze:** 0 errors, 0 warnings
- **Code style:** Dart conventions, linted
- **Documentation:** Inline comments, architecture docs
- **Git workflow:** Feature branches, descriptive commits

---

## 🌍 Environmental Impact Potential

### Individual User Impact (Projected)
If one user follows tips for 1 year:
- **Device lifespan:** +6-12 months average extension
- **Energy savings:** ~50-100 kWh/year (varies by device)
- **E-waste prevented:** 1-2 devices from premature disposal
- **CO₂ reduction:** ~25-50 kg equivalent (from energy + manufacturing)

### Scale Potential
If 10,000 users adopt GreenWise habits:
- **Devices saved:** 10,000-20,000 devices/year
- **E-waste diverted:** 50-100 metric tons/year
- **Energy saved:** 500,000-1,000,000 kWh/year
- **CO₂ reduction:** 250-500 metric tons equivalent/year

*Note: Estimates based on average device lifespans, energy consumption patterns, and typical e-waste recycling rates.*

---

## 📞 Project Information

### Development Team
- **Project:** GreenWise
- **Repository:** github.com/RONALDMASLOG2024-2025/greenwise
- **Current Branch:** main
- **Documentation:** USER_DOCUMENTATION.md, QUICK_START_GUIDE.md

### Contact & Support
- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions
- **Documentation:** `/docs` folder

### License
- **Status:** To Be Determined (consider MIT/Apache 2.0)
- **Open Source:** Planned for public release

---

## 🎓 Educational Value

GreenWise serves as a practical learning tool for:
- **Students:** Green computing and sustainability concepts
- **Households:** Responsible electronics management
- **Professionals:** Sustainable IT practices
- **Communities:** Collective environmental awareness

### Curriculum Alignment
Supports learning objectives in:
- Environmental Science
- Computer Science (green computing)
- Consumer Education
- Sustainable Development Goals (SDGs)

---

## 📊 Success Metrics

### User Engagement (Planned Tracking)
- Daily active users
- Streak retention (7-day, 30-day)
- Tip completion rate
- Notification engagement
- Recycling directory usage

### Environmental Impact (Aggregate)
- Total tips completed (all users)
- Estimated devices saved
- Estimated energy saved
- E-waste recycling referrals

---

## 🙌 Acknowledgments

### Data Sources
- EPA (US Environmental Protection Agency)
- PCMag technology guidelines
- Natural History Museum UK e-waste research
- Android Authority battery optimization
- Norton computer care guides
- LG Electronics device longevity
- Honor smartphone maintenance

### Inspiration
- Global E-Waste Monitor reports
- UN Sustainable Development Goals
- Philippines DENR e-waste initiatives
- Green computing advocacy organizations

---

**Built with Flutter | Mission: Sustainable Digital Living** 🌱

*For user-facing documentation, see USER_DOCUMENTATION.md*
*For quick reference, see QUICK_START_GUIDE.md*
