# kit721-assignment4
## Hasini Gayathri De Silva Andra Hannadhi - 771480
Interior Quoter — KIT721 Assignment 4

---

## Device & Orientation
- **Device:** Medium Phone API 37.0 (Android Emulator)
- **Orientation:** Portrait only

---

## Screens & Navigation

### Screens

| Screen | Description |
|--------|-------------|
| HouseListScreen | Home screen with house list, search bar, and empty state |
| AddEditHouseScreen | Add or edit a house with phone number validation |
| HouseDetailScreen | Room list for a selected house with Generate Quote button |
| AddEditRoomScreen | Add or edit a room with optional gallery photo picker |
| RoomDetailScreen | Windows and floor spaces for a room |
| AddEditWindowScreen | Add or edit a window with product API, constraint checker and colour variant |
| AddEditFloorScreen | Add or edit a floor space with product API and colour variant |
| QuoteScreen | Itemised quote display with room checkboxes, per-room totals, labour cost and CSV share |

### Navigation Flow
- `HouseListScreen` → `AddEditHouseScreen` (tap + Add House or edit icon)
- `HouseListScreen` → `HouseDetailScreen` (tap house card)
- `HouseDetailScreen` → `AddEditRoomScreen` (tap + Add Room or edit icon)
- `HouseDetailScreen` → `QuoteScreen` (tap Generate Quote)
- `HouseDetailScreen` → `RoomDetailScreen` (tap room card)
- `RoomDetailScreen` → `AddEditWindowScreen` (tap + Add next to Windows)
- `RoomDetailScreen` → `AddEditFloorScreen` (tap + Add next to Floor Spaces)
- `RoomDetailScreen` → `QuoteScreen` (tap Generate Quote)


---

## Custom Feature
Room Duplication — Long press any room card in the room list to duplicate it. A confirmation dialog shows the new room name preview. On confirm, the room is copied with all its windows and floor spaces to new Firestore documents. The duplicated room appears in the list named "[Original Name] (Copy)" and is highlighted in teal to distinguish it from the original.

---

## Separate Firebase Project
A separate Firebase project (InteriorQuoterFlutter) was created for this assignment rather than reusing the Assignment 2/3 project. This was to avoid data conflicts while Assignment 3 was still being marked, and to prevent structural changes from causing bugs in the iOS assignment.

---

## References

### Tutorials
KIT305/KIT721 Tutorial base code — Flutter Provider pattern used as base for all list screens and state management

### Libraries
- Provider — https://pub.dev/packages/provider
- Firebase Core — https://pub.dev/packages/firebase_core
- Cloud Firestore — https://pub.dev/packages/cloud_firestore
- Image Picker — https://pub.dev/packages/image_picker (gallery photo selection for rooms)
- HTTP — https://pub.dev/packages/http (product API calls)
- Share Plus — https://pub.dev/packages/share_plus (CSV quote sharing)
- Flutter Launcher Icons — https://pub.dev/packages/flutter_launcher_icons (app icon generation)

### External API
- Product API: https://utasbot.dev/kit305_2026/product — provided by unit coordinator

### Official Flutter Documentation
- FlutterFire setup — https://firebase.flutter.dev/docs/overview
- Image picker — https://pub.dev/packages/image_picker
- Share plus — https://pub.dev/packages/share_plus

---

## Generative AI Usage
Claude AI (Anthropic Claude Sonnet) was used as a development assistant for parts of this assignment that go beyond the tutorial content covered in KIT305/KIT721.

For the following areas, Claude was used for debugging, understanding workflow concepts, and syntax guidance — not for copying complete code solutions:

- REST API integration — How to fetch products from API and populate a dropdown with caching
- CSV sharing — Implementing share_plus for plain text CSV output
- Flutter launcher icons — Setting up adaptive icons for Android, iOS and web
- Image picker — Gallery photo selection and displaying local file path
- Provider scoping — Understanding how to scope ChangeNotifierProvider to specific screens to avoid cross-route access errors

Areas completed independently using prior assignment experience (Assignment 2 Android and Assignment 3 iOS):
- Firebase Firestore setup, FlutterFire CLI configuration and CRUD operations
- Flutter Provider/ChangeNotifier pattern (tutorial pattern)
- Screen navigation with Navigator.push/pop
- Data models (House, Room, WindowSpace, FloorSpace, Product)
- Form validation pattern
- Window constraint logic 
- Cascade delete logic 
- Room duplication 
- Quote screen calculations 

Shared AI conversation links:
- AI conversation link: https://claude.ai/share/bc9740d5-3ab7-409f-a830-26b7b8e72cc5

---

## Notes
- All data in Firestore is sensible test data 
- App tested on Medium Phone API 37.0 emulator in portrait orientation
- A separate Firebase project (InteriorQuoterFlutter) was used for this assignment
