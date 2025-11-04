# GreenWise Development Roadmap
**Current Status:** MVP Complete ✅  
**Next Steps:** Feature Enhancement & Polish  
**Date:** November 4, 2025

---

## 🎯 Current State Assessment

### ✅ Completed Features (MVP)
- [x] **Core Infrastructure**
  - Clean architecture with feature-first organization
  - Riverpod state management
  - Hive + SharedPreferences persistence
  - Cross-platform support (Android, iOS, Web, Desktop)

- [x] **Content & Data**
  - 365 curated eco-tips (1 year of content)
  - 52 verified tips from authoritative sources
  - 4 categories: Device Care, Energy Saving, Disposal, Eco-Buying
  - Source attribution system

- [x] **User Experience**
  - Onboarding flow with particle effects
  - 4-tab navigation (Tips, Progress, Recycling, Settings)
  - Daily tip card with "Why it matters" explanations
  - Infinite vertical tips feed
  - Pull-to-refresh

- [x] **Habit Tracking**
  - Streak tracking (current + longest)
  - Weekly completion ring
  - 30-day heatmap visualization
  - Mark tip as "Done today"
  - Clear progress with confirmation

- [x] **Settings & Personalization**
  - Dark mode toggle
  - Reduce Motion accessibility
  - Category filters (backend ready)

- [x] **Resources**
  - Recycling & Trade-in directory
  - Philippines resources (Globe, DENR, Envirocycle, etc.)
  - Global resources (Apple, Dell, Best Buy, etc.)
  - External link launching

### ⏳ Partially Implemented
- [ ] **Notifications** (scheduled but UX needs polish)
  - Daily reminder scheduling works
  - Need: better onboarding, time picker UX, permission handling

- [ ] **Category Filtering** (logic ready, UI missing)
  - Backend filters tips by enabled categories
  - Need: Settings UI to toggle categories

### ❌ Not Yet Started
- [ ] Gamification (badges, achievements)
- [ ] Social/Community features
- [ ] Multi-language support (i18n)
- [ ] Import/Export progress data
- [ ] Accessibility audit
- [ ] Analytics & insights

---

## 📅 Development Phases

### **PHASE 1: Polish & User Experience** (2-3 weeks)
**Goal:** Refine existing features to production quality

#### 1.1 Notification System Enhancement
**Priority:** HIGH  
**Complexity:** Medium  
**Files:** `lib/services/notifications/`, `lib/settings/`

**Tasks:**
- [ ] Improve notification onboarding flow
  - Welcome screen explaining daily reminder benefits
  - Visual time picker (like iOS clock picker)
  - "Try it now" button to test notification immediately

- [ ] Better permission handling
  - Explain why notification permission is needed
  - Graceful fallback if user denies permission
  - Re-prompt option in settings

- [ ] Notification content enhancement
  - Include tip category in notification body
  - Rich notifications with action buttons (Mark Done, View More)
  - Custom notification sound (subtle, eco-themed)

- [ ] Testing
  - Test on Android 12+ (new permission model)
  - Test on iOS 15+ (notification summary)
  - Test timezone changes

**Estimated Time:** 5-7 days

---

#### 1.2 Category Filter UI
**Priority:** HIGH  
**Complexity:** Low  
**Files:** `lib/settings/settings_screen.dart`, `lib/settings/settings_provider.dart`

**Tasks:**
- [ ] Add "Tip Categories" section to Settings
  - Multi-select chip group or toggle switches
  - Visual category icons/colors
  - Show tip count per category

- [ ] Update UI when categories change
  - Invalidate tip providers
  - Show SnackBar confirming changes
  - Reset infinite feed to today

- [ ] Validation
  - Require at least 1 category enabled
  - Show warning if user tries to disable all

**Estimated Time:** 2-3 days

---

#### 1.3 Tip Source Attribution Display
**Priority:** MEDIUM  
**Complexity:** Low  
**Files:** `lib/features/tips/presentation/widgets/daily_tip_card_modern.dart`

**Tasks:**
- [ ] Add "Source" badge to tip cards
  - "Verified" badge with checkmark for authoritative sources
  - Show source name on tap/long-press
  - Subtle styling (don't distract from tip content)

- [ ] Tip detail/expanded view
  - Show full source citation
  - "Learn More" button linking to original article (if URL available)
  - Share button to share tip + source

- [ ] Filter by source (optional)
  - "Show only verified tips" toggle in settings
  - Useful for users who want authoritative content only

**Estimated Time:** 3-4 days

---

#### 1.4 Onboarding Improvements
**Priority:** MEDIUM  
**Complexity:** Low  
**Files:** `lib/features/onboarding/`

**Tasks:**
- [ ] Add screen explaining source attribution
  - Educate users about verified vs AI-generated tips
  - Build trust through transparency

- [ ] Permission requests during onboarding
  - Notification permission with clear explanation
  - Optional: storage permission for export

- [ ] Skip button
  - Let users skip onboarding if they want
  - Mark as "seen" so it doesn't re-appear

**Estimated Time:** 2 days

---

#### 1.5 Accessibility Audit
**Priority:** MEDIUM  
**Complexity:** Medium  
**Files:** All UI files

**Tasks:**
- [ ] Screen reader support
  - Add semantic labels to all interactive elements
  - Test with TalkBack (Android) and VoiceOver (iOS)
  - Ensure navigation is logical with screen reader

- [ ] Keyboard navigation (desktop/web)
  - Tab order makes sense
  - All actions accessible via keyboard
  - Focus indicators visible

- [ ] Text scaling
  - Test with large text sizes (Android accessibility settings)
  - Ensure layouts don't break with 200% text scale
  - Use relative sizing (not absolute px)

- [ ] Color contrast
  - Ensure sufficient contrast ratios (WCAG AA: 4.5:1)
  - Test dark mode contrast
  - Don't rely solely on color to convey information

- [ ] Motion preferences
  - Respect "Reduce Motion" in all animations
  - Provide alternative visual feedback when animations disabled

**Estimated Time:** 5-6 days

---

### **PHASE 2: Feature Expansion** (3-4 weeks)
**Goal:** Add new features that enhance engagement and value

#### 2.1 Gamification System
**Priority:** HIGH  
**Complexity:** High  
**Files:** New `lib/features/gamification/`

**Tasks:**
- [ ] Badge/Achievement system
  - Design badge types:
    - Streak badges (7-day, 30-day, 100-day, 365-day)
    - Category badges (complete 10 tips per category)
    - Explorer badge (view 100 different tips)
    - Early bird (complete tip before 8am)
    - Night owl (complete tip after 10pm)
  - Badge artwork (SVG icons)
  - Badge unlocking animations
  - Badge collection screen

- [ ] Levels & XP
  - Earn XP for completing tips (10 XP per tip)
  - Bonus XP for streaks (2x on 7-day, 3x on 30-day)
  - Level up system (Level 1-50)
  - Visual level indicator in UI

- [ ] Weekly/Monthly Challenges
  - "Complete 5 energy saving tips this week"
  - "Try a tip from each category"
  - "Share a tip with a friend"
  - Challenge cards on home screen
  - Bonus rewards for completion

**Estimated Time:** 10-12 days

---

#### 2.2 Progress Analytics & Insights
**Priority:** MEDIUM  
**Complexity:** Medium  
**Files:** `lib/features/progress/`, new analytics widgets

**Tasks:**
- [ ] Environmental Impact Calculator
  - Track completed tips by category
  - Estimate carbon saved, e-waste prevented
  - "You've prevented X kg of e-waste this month"
  - Visual impact metrics (trees saved, energy conserved)

- [ ] Progress Charts
  - Line chart: completion trend over time
  - Pie chart: tips completed by category
  - Bar chart: weekly comparison

- [ ] Personal Bests
  - Longest streak
  - Most productive day/week/month
  - Favorite category
  - Total tips completed

- [ ] Milestones
  - Celebrate 10, 50, 100, 365 tips completed
  - Special animations/confetti
  - Share milestone to social media

**Estimated Time:** 7-8 days

---

#### 2.3 Data Import/Export
**Priority:** MEDIUM  
**Complexity:** Medium  
**Files:** `lib/features/progress/`, `lib/data/`

**Tasks:**
- [ ] Export progress data
  - JSON format with all completion dates, streaks, badges
  - CSV format for spreadsheet analysis
  - File picker integration
  - Share via system share sheet

- [ ] Import progress data
  - Validate JSON structure
  - Merge with existing data (handle conflicts)
  - Show preview before importing
  - Undo option

- [ ] Backup to cloud (optional)
  - Google Drive / iCloud integration
  - Auto-backup setting
  - Restore from cloud

**Estimated Time:** 6-7 days

---

#### 2.4 Social Features (Lite)
**Priority:** LOW  
**Complexity:** High  
**Files:** New `lib/features/social/`

**Tasks:**
- [ ] Share tips
  - Beautiful share cards (tip + source + app branding)
  - Share to WhatsApp, Twitter, Facebook
  - Copy tip text to clipboard

- [ ] Friends/Family Groups (optional - needs backend)
  - Create private groups (household, classroom)
  - See group members' streaks
  - Group challenges
  - Leaderboard

- [ ] Public tip feed (optional - needs moderation)
  - User-submitted tips (pending approval)
  - Voting/rating system
  - Community verification

**Note:** Social features likely need backend (Firebase/Supabase)

**Estimated Time:** 12-15 days (if implementing)

---

### **PHASE 3: Localization & Distribution** (2-3 weeks)
**Goal:** Prepare for global release

#### 3.1 Multi-Language Support (i18n)
**Priority:** HIGH (if targeting non-English markets)  
**Complexity:** Medium  
**Files:** All UI strings, new `lib/l10n/`

**Tasks:**
- [ ] Setup Flutter localization
  - Add `flutter_localizations` package
  - Create ARB files for translations
  - Extract all hardcoded strings

- [ ] Priority languages
  - English (default) ✅
  - Filipino/Tagalog (Philippine market)
  - Spanish (large user base)
  - Chinese (global reach)

- [ ] Translate tips database
  - Create separate tips.json per language
  - Maintain source attribution in translations
  - Quality check translations (native speakers)

- [ ] RTL support (if needed for Arabic, Hebrew)
  - Test layout mirroring
  - Adjust custom widgets

**Estimated Time:** 10-12 days

---

#### 3.2 App Store Optimization (ASO)
**Priority:** HIGH  
**Complexity:** Low  
**Files:** Metadata, screenshots, assets

**Tasks:**
- [ ] App Store listings
  - Compelling app description
  - Keywords for discoverability
  - Privacy policy page
  - Support/contact page

- [ ] Screenshots
  - 5-7 beautiful screenshots per platform
  - Show key features (tips, progress, recycling)
  - Localized screenshots for each language

- [ ] App icon refinement
  - Test on various backgrounds
  - Adaptive icon for Android
  - App Store icon (no transparency)

- [ ] Promotional materials
  - Feature graphic for Google Play
  - Preview video (30-60 seconds)
  - Press kit with logos, screenshots

**Estimated Time:** 4-5 days

---

#### 3.3 Release Preparation
**Priority:** HIGH  
**Complexity:** Medium  
**Files:** Build configuration, CI/CD

**Tasks:**
- [ ] App signing & certificates
  - Android keystore (production)
  - iOS distribution certificate
  - Secure key storage

- [ ] Version management
  - Semantic versioning (1.0.0)
  - Changelog maintenance
  - Release notes

- [ ] Testing
  - Beta testing program (TestFlight, Play Console)
  - Internal testing (team members)
  - Closed beta (50-100 users)
  - Open beta (public)

- [ ] CI/CD pipeline
  - GitHub Actions for automated builds ✅ (already exists)
  - Automated testing on PR
  - Deploy to TestFlight/Play Console on merge

- [ ] Analytics setup (optional)
  - Firebase Analytics or similar
  - Track key metrics (DAU, retention, feature usage)
  - Crash reporting (Crashlytics, Sentry)

**Estimated Time:** 8-10 days

---

### **PHASE 4: Post-Launch Iteration** (Ongoing)
**Goal:** Respond to user feedback and improve

#### 4.1 User Feedback Loop
- [ ] In-app feedback form
- [ ] App Store review monitoring
- [ ] Bug triage and prioritization
- [ ] Feature request tracking

#### 4.2 Content Expansion
- [ ] Add more verified tips (continue scraping)
- [ ] User-submitted tips (with moderation)
- [ ] Seasonal/timely tips (e.g., Earth Day)
- [ ] Advanced tips for power users

#### 4.3 Performance Optimization
- [ ] App size optimization
- [ ] Load time improvements
- [ ] Battery usage profiling
- [ ] Memory leak detection

#### 4.4 Platform-Specific Features
- [ ] Android widgets (home screen tip widget)
- [ ] iOS widgets (lock screen, home screen)
- [ ] Wear OS companion app
- [ ] Apple Watch app
- [ ] Desktop tray app

---

## 🎯 Recommended Priority Order

### **Immediate (Next 2 weeks)**
1. ✅ **Notification UX Polish** - Critical for daily engagement
2. ✅ **Category Filter UI** - Core feature already built, just needs UI
3. ✅ **Tip Source Display** - Build trust with verified sources

### **Short-term (Weeks 3-6)**
4. **Accessibility Audit** - Expand user base, comply with guidelines
5. **Gamification Basics** - Badges + levels for retention
6. **Progress Analytics** - Show environmental impact

### **Medium-term (Weeks 7-12)**
7. **Multi-language Support** - If targeting PH/global markets
8. **Data Import/Export** - User data ownership
9. **ASO & Release Prep** - Prepare for launch

### **Long-term (Post-launch)**
10. Social features (if user demand exists)
11. Platform-specific widgets
12. Content expansion

---

## 📊 Success Metrics to Track

### Engagement Metrics
- Daily Active Users (DAU)
- Tip completion rate
- Average streak length
- Session duration

### Retention Metrics
- Day 1, 7, 30 retention
- Churn rate
- Feature adoption (settings, progress, recycling)

### Impact Metrics
- Total tips completed (all users)
- Estimated e-waste prevented (kg)
- App Store rating & reviews
- Organic vs. paid user acquisition

---

## 💡 Quick Wins (1-2 days each)

These can be done anytime to show progress:

1. **Add "Share Tip" button** - Easy viral growth
2. **Tip of the week email** - Email capture + engagement
3. **App rate prompt** - After 7-day streak, ask for review
4. **Easter eggs** - Hidden badge for completing tips on Earth Day
5. **Loading tips** - Show random eco-facts during splash
6. **Haptic feedback** - Subtle vibration when marking tip done
7. **Confetti animation** - Celebrate milestones
8. **Dark mode auto-switch** - Based on time of day

---

## 🚧 Technical Debt to Address

1. **TODO in progress_screen.dart** - File picker for import
2. **Analyzer warnings** - Fix directive ordering, file naming
3. **Test coverage** - Increase from current 6 tests
4. **Error handling** - Add global error boundary
5. **Logging** - Structured logging for debugging

---

## 🎓 Learning Resources

If implementing features you're unfamiliar with:

- **Gamification:** Look at Duolingo, Habitica for inspiration
- **i18n:** Flutter's official internationalization guide
- **Accessibility:** Google's Material accessibility guidelines
- **Notifications:** Flutter Local Notifications package examples
- **Analytics:** Firebase for Flutter quickstart

---

## ✅ Next Action Items

**This week:**
1. Choose Phase 1 features to tackle (recommend notifications + categories)
2. Set up project board to track tasks
3. Create feature branches for parallel work

**This month:**
1. Complete Phase 1 (Polish & UX)
2. Start Phase 2 (Gamification or Analytics)
3. Recruit beta testers

**This quarter:**
1. Complete Phase 2 & 3
2. Launch v1.0 to app stores
3. Gather user feedback

---

**Would you like me to start implementing any specific phase or feature?** I can begin with:
- Notification UX improvements
- Category filter UI
- Tip source attribution display
- Accessibility enhancements
- Or any other feature you'd like to prioritize!
