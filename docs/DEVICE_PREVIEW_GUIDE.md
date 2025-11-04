# Device Preview Guide

## What is Device Preview?

**Device Preview** allows you to preview your Flutter app on different devices and screen sizes **without needing physical devices or emulators**. It's perfect for testing responsive layouts and ensuring your app looks good on various phones, tablets, and desktops.

## ✅ Installation Complete

Device Preview has been added to your project:
- **Package**: `device_preview: ^1.3.1` (latest version)
- **Enabled**: Only in debug mode (automatically disabled in release builds)
- **Integration**: Fully integrated in `main.dart`

## How to Use

### 1. Run Your App Normally

```bash
flutter run
```

When you run the app in **debug mode**, you'll see:
- A device frame around your app (simulating different phones/tablets)
- A toolbar on the side with device selection and controls

### 2. DevicePreview Features

#### 📱 **Device Selection**
Click on the device icon to choose from:
- **iPhone** (SE, 13, 14 Pro, etc.)
- **iPad** (Air, Pro)
- **Android phones** (Pixel, Samsung Galaxy)
- **Android tablets**
- **Desktop** (Custom sizes)

#### 🎨 **Theme Toggle**
Switch between light and dark mode instantly

#### 📐 **Orientation**
- Portrait mode
- Landscape mode
- Auto-rotate

#### 🔍 **Inspector Tools**
- View widget boundaries
- Check text scaling
- Test accessibility features

#### 📸 **Screenshot**
Take screenshots of your app on different devices

#### ⚙️ **Custom Settings**
- Change locale/language
- Adjust text scaling
- Test accessibility settings

### 3. Keyboard Shortcuts (in DevicePreview)

| Shortcut | Action |
|----------|--------|
| `R` | Rotate device |
| `D` | Toggle dark mode |
| `F` | Toggle frame |
| `S` | Take screenshot |

### 4. Testing Responsive Layouts

Use DevicePreview to verify:
- ✅ UI adapts to different screen sizes
- ✅ No text overflow on small screens
- ✅ Proper spacing on large screens
- ✅ Navigation works on all devices
- ✅ Images scale correctly

### Example: Test Progress Screen

1. Run the app: `flutter run`
2. Navigate to Progress tab
3. In DevicePreview toolbar:
   - Select "iPhone SE" → Check if heatmap fits
   - Select "iPad Pro" → Verify layout uses space well
   - Select "Pixel 6" → Check streak counter positioning
   - Rotate to landscape → Ensure no overflow

## Configuration (Already Set Up)

Your `main.dart` is configured to:

```dart
runApp(
  DevicePreview(
    enabled: !kReleaseMode,  // Only in debug mode
    builder: (context) => const ProviderScope(child: GreenWiseApp()),
  ),
);
```

And in `MaterialApp`:

```dart
MaterialApp(
  locale: DevicePreview.locale(context),  // Respect preview locale
  builder: DevicePreview.appBuilder,      // Wrap with device frame
  // ... other settings
)
```

## Disable DevicePreview

### Temporarily (for testing)
Change in `main.dart`:
```dart
DevicePreview(
  enabled: false,  // Disable
  builder: (context) => const ProviderScope(child: GreenWiseApp()),
)
```

### Permanently Remove
1. Remove from `pubspec.yaml`:
   ```yaml
   dependencies:
     device_preview: ^1.3.1  # Remove this line
   ```

2. Update `main.dart`:
   ```dart
   // Remove import
   import 'package:device_preview/device_preview.dart';
   
   // Change runApp
   runApp(const ProviderScope(child: GreenWiseApp()));
   
   // Remove from MaterialApp
   locale: DevicePreview.locale(context),  // Remove
   builder: DevicePreview.appBuilder,       // Remove
   ```

3. Run: `flutter pub get`

## Tips & Best Practices

### ✅ DO:
- Use DevicePreview during development to test layouts
- Test on small devices (iPhone SE) and large tablets (iPad Pro)
- Check both portrait and landscape orientations
- Verify dark mode looks good on all devices
- Use it to take marketing screenshots

### ❌ DON'T:
- Don't rely solely on DevicePreview - test on real devices too
- Don't enable in production (already disabled via `!kReleaseMode`)
- Don't forget to test web builds separately

## Common Use Cases

### 1. Check Responsive Design
```
iPhone SE (small) → No overflow?
Pixel 6 (medium) → Comfortable spacing?
iPad Pro (large) → Proper use of space?
```

### 2. Test Navigation
```
Small phone → Bottom nav accessible?
Tablet → Consider side navigation?
Desktop → Top nav bar?
```

### 3. Verify Card Layouts
```
Daily tip card → Readable on all sizes?
Progress ring → Scales properly?
Recycling cards → Grid adapts?
```

### 4. Test Settings Screen
```
Toggle switches → Tap target large enough?
Category chips → Wrap on small screens?
Buttons → Not too cramped?
```

## Troubleshooting

### Issue: "DevicePreview not showing"
**Solution**: Make sure you're running in debug mode:
```bash
flutter run --debug
```

### Issue: "App looks different in DevicePreview vs real device"
**Solution**: DevicePreview is an approximation. Always test on real devices for final validation.

### Issue: "Hot reload not working"
**Solution**: Hot reload works normally with DevicePreview. If issues occur, try hot restart (`R` in terminal).

### Issue: "Performance slow"
**Solution**: DevicePreview adds a wrapper layer. For performance testing, disable it temporarily.

## Advanced: Custom Devices

You can add custom device presets:

```dart
DevicePreview(
  enabled: !kReleaseMode,
  devices: [
    ...Devices.all,
    // Add custom device
    const Device(
      name: 'Custom Phone',
      platform: TargetPlatform.android,
      screenSize: Size(480, 960),
      pixelRatio: 2.0,
    ),
  ],
  builder: (context) => const ProviderScope(child: GreenWiseApp()),
)
```

## Resources

- **Official Docs**: https://pub.dev/packages/device_preview
- **GitHub**: https://github.com/aloisdeniel/flutter_device_preview
- **Video Tutorial**: Search "Flutter Device Preview" on YouTube

## Summary

✅ **Installed**: `device_preview: ^1.3.1`  
✅ **Integrated**: Fully configured in `main.dart`  
✅ **Auto-Disabled**: Only runs in debug mode  
✅ **Ready to Use**: Run `flutter run` and start testing!

**Pro Tip**: Use DevicePreview alongside Chrome DevTools for the best development experience. DevicePreview for layout testing, DevTools for performance profiling.

---

**Enjoy testing your app on all devices without leaving your desk! 🚀**
