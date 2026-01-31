## KrishiMitra - Complete Setup Guide

### CRITICAL: Before Running the App

1. **UPDATE Backend URL**  
   Open `lib/config/apiconfig.dart` and replace line 6:
   ```dart
   static const String baseUrl = "http://YOUR_ACTUAL_EC2_IP:PORT";
   ```

2. **Create Asset Directories** (Optional - for custom images):
   ```bash
   mkdir -p assets/images
   mkdir -p assets/icons
   ```
   Or remove these lines from `pubspec.yaml` (lines 51-52)

3. **Run Flutter Commands**:
   ```bash
   cd /home/tejasbargujepatil/Desktop/KrishiMitra
   flutter pub get
   flutter run
   ```

### Project Status

✅ **Complete**: All screens, services, models, widgets  
✅ **Complete**: Bilingual localization (English/Marathi)  
✅ **Complete**: REST API integration foundation  
✅ **Complete**: Android configuration with permissions  
⚠️ **Note**: Localization files auto-generate on first build

### Testing Checklist

- [ ] Update EC2 IP in apiconfig.dart
- [ ] Run `flutter pub get`
- [ ] Run `flutter run` or `flutter build apk`
- [ ] Test login/register flow
- [ ] Test language switching in settings
- [ ] Verify GPS permission prompt on registration
- [ ] Test crop management (add/list/view)
- [ ] Verify agent dashboard displays all sections

### Known Setup Notes

- Localization files (`app_localizations.dart`) are generated automatically during build
- Android uses v2 embedding (modern Flutter)
- All API requests require backend to be running

See `walkthrough.md` for complete documentation.
