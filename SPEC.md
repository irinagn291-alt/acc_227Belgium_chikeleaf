# Hingeleaf — Build Specification

> Portfolio app 200, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Search or scan catalog stamps, hinge them on your album leaf, and mark them verified when the copy arrives.

| Field | Value |
| --- | --- |
| Product name | Hingeleaf |
| Bundle identifier | `com.hingeleaf.folio` |
| Domain | https://hingeleaf-folio.pro |
| Contact URL | https://hingeleaf-folio.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `hlf_` |
| User-Agent | `Hingeleaf/1.0 (iOS; +https://hingeleaf-folio.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Hingeleaf -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A philatelist searches or scans a catalog issue onto the album leaf and cancels the hinge when the paper copy is verified so the collection separates wants from owned plates.

### 2.1 User flow

1. On home, tap an empty perforation on the active leaf to open search for the next issue to hinge.
2. Type a country, topic, or catalog number, or scan a retail pack barcode on the Discover sheet.
3. Open the issue detail and confirm Hinge to seat it on the chosen mount.
4. When the physical stamp arrives, tap the hinged cell and Cancel to mark the copy verified in-hand.
5. Grade cancelled issues from 1 to 5 and open Profile to read era and country taste from cancelled grades only.

### 2.2 Essential behaviour

- Colnect-backed issue search with paginated JSON and on-device cache of resolved issues
- Live EAN scan for retail stamp packs via AVCaptureMetadataOutput
- Perforated leaf grid as the persistent home surface with mount selection
- HingeMark and CancelMark fold with peel for the last mark
- Profile taste stats and country breakdown that fold only on Cancelled issues, never on hinged wants

---

## 3. Uniqueness assignment for Hingeleaf

| Axis | Assigned value |
| --- | --- |
| Architecture | **Hinge ADT fold (Loose | Hinged | Cancelled); the leaf is a fold over Issues; search or scan writes Loose; Hinge writes a HingeMark on an empty mount and folds Loose to Hinged; Cancel writes a CancelMark and folds Hinged to Cancelled; grade folds only Cancelled; Cancel on Loose writes SkewMark; Cancel without HingeMark writes DriftMark; a second Hinge on the same Issue is refused; Peel drops the last HingeMark or CancelMark; an empty leaf writes Blank** |
| UI approach | **SwiftUI WKWebView representable · canvas-first** |
| Naming convention | **Philately / album lexicon (Leaf, Mount, Issue, Loose, Hinged, Cancelled, HingeMark, CancelMark, SkewMark, DriftMark, Plate, Perforation)** |
| File organization | **By issue role (Leaf, Mount, Issue, HingeMark, CancelMark, SkewMark, DriftMark, Plate, Profile)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **vodafone · pop-tiles · branded** |
| Typography | **Iowan Old Style** |
| Navigation pattern | **Mount-locked chrome (the perforated album leaf never leaves; Discover, Wants and Profile arrive as sheets; hinge and cancel fuse on the active mount; Settings as a sheet; no tab bar)** |
| AI art style | **Bauhaus geometric · collage · take philately** |
| Functional twist | **Hinge-then-cancel (search or scan writes Loose; Hinge writes a HingeMark and folds Loose to Hinged; Cancel writes a CancelMark and folds Hinged to Cancelled; grade and Profile fold only Cancelled; Cancel on Loose writes SkewMark; hinged wants never enter taste)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — catalog_crate

**Core** — A philatelist searches or scans a catalog issue onto the album leaf and cancels the hinge when the paper copy is verified so the collection separates wants from owned plates.

**Audience** — Stamp collectors who hinge issues on-device and want owned versus want plates filed locally, not a Colnect account shell, a price guide, or a social swap feed.

**User flow**

1. On home, tap an empty perforation on the active leaf to open search for the next issue to hinge.
2. Type a country, topic, or catalog number, or scan a retail pack barcode on the Discover sheet.
3. Open the issue detail and confirm Hinge to seat it on the chosen mount.
4. When the physical stamp arrives, tap the hinged cell and Cancel to mark the copy verified in-hand.
5. Grade cancelled issues from 1 to 5 and open Profile to read era and country taste from cancelled grades only.

**Essential features**

- Colnect-backed issue search with paginated JSON and on-device cache of resolved issues
- Live EAN scan for retail stamp packs via AVCaptureMetadataOutput
- Perforated leaf grid as the persistent home surface with mount selection
- HingeMark and CancelMark fold with peel for the last mark
- Profile taste stats and country breakdown that fold only on Cancelled issues, never on hinged wants

**Twist** — Hinge-then-cancel. Home is the active album leaf. Search or scan writes an Issue as Loose. Hinge writes a HingeMark on the tapped empty mount and folds Loose to Hinged. Cancel writes a CancelMark and folds Hinged to Cancelled. Grade from 1 to 5 fuses only on Cancelled. Profile and taste fold only Cancelled grades. Cancel on Loose writes SkewMark and keeps Loose. Cancel on Hinged without a seated HingeMark writes DriftMark. A second Hinge on the same Issue is refused. Peel drops the last CancelMark or HingeMark. Seed leaves one Hinged issue on the leaf and one Loose in the tray so the opening live tap is Cancel. Home verb: cancel-the-hinge, not drop-the-needle, teach-the-rules, or burn-the-gate. Wants rail lists Hinged-only issues; Profile counts CancelMarks, not search history.

**Why this is not a repeat** — Same family as Deadwax and Playtile only at the search-and-crate layer; the persisted job is philatelic album filing (hinge layout, cancel when verified), not vinyl plays, board-game teach/table, or film burn/bill. No museum quiz, no OFF macros, no watchlist queue clone. Axis bundle matches the catalog_crate graph point with a fresh architecture ADT and Mount-locked navigation.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Discover is a crate/wall, not a generic search app.
- Invariant: One external catalog. Stay in one domain. Rate + local notes. Scan only if the domain has a code.
- Never: Add one rare verb: sleeve wall, quiz-from-crate, surprise-from-owned-stock, cook mode, or expiry rail — not all of them.
- Desk `pack_balance`: fill=Σvol/cap; balanceXY=weight-avg of zones; readiness mixes clip(weight), clip(fill), balance.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.
- Scan: AVFoundation + Vision; symbologies include `.qr`; digit runs 8–14 from QR/URL; UPC-A pad; Simulator chips + manual; stop session. Pre-permission CTA is Continue or Next (Guideline 5.1.1 — never Allow/Enable camera).
- Mini-ref `PagePocket`: steal Catalog search, ISBN scan, crate/rate/notes, cover wall, empty search. Never Alamofire wrapper, AppsFlyer, OneSignal, ContactUsWebView. Not book_quotes. New types and layout — do not reskin.

### 3.1 Architecture contract

IssueRole is a three-case fold, Loose, Hinged, or Cancelled, and Leaf is the fold over Issues seated on Mounts. Search or a retail scan writes an Issue as Loose in the tray and leaves every mount empty of that issue. Hinge on one empty mount writes a HingeMark and folds that Loose issue to Hinged, and a second Hinge on the same Issue is refused. Cancel on a Hinged issue that already holds a HingeMark writes a CancelMark and folds it to Cancelled, and a grade from 1 to 5 fuses only on Cancelled. Cancel on Loose writes a SkewMark and keeps Loose, Cancel without a seated HingeMark writes a DriftMark, Peel drops the last HingeMark or CancelMark, and an empty leaf writes Blank. Unit tests lock the fold, the refused second Hinge, grade only on Cancelled, Peel of the last mark, and Profile counts of CancelMarks from this one stamp catalog.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

LeafView is canvas-first. One UIViewRepresentable draws the perforated mount grid in Core Graphics, and that canvas is the only illustrated surface. WebKit, WKWebView, and SFSafariViewController stay out of the target, so the representable is a drawing host. DiscoverView, WantsView, ProfileView, CrateView, SeenView, IssueView, and SettingsView are stock SwiftUI sheets. ScanView is a full-screen cover whose preview layer is the capture session. There is no TabView. Pop tiles keep one active mount oversized and the other mounts quiet, with the loose tray as a horizontal rail under the grid so the two bands do not share a column structure. Kit radius is 28 and 14, elevation is hairline plus fill, and the primary control is a filled capsule ButtonStyle with default, pressed, disabled, and loading. Cancel wears the accent. Peel uses a destructive button style. Grouped reveals step 40 to 60 milliseconds and finish within 360 milliseconds. Reduce Motion fades the group in at once. Empty leaf, empty search, empty wants, and empty profile are full pages with generated art, one headline, one line, and a full-width bottom CTA. Copy is warm and brief.

### 3.3 Naming contract

Convention: Philately / album lexicon (Leaf, Mount, Issue, Loose, Hinged, Cancelled, HingeMark, CancelMark, SkewMark, DriftMark, Plate, Perforation).

Examples to follow: LeafView, MountGrid, HingeMark, CancelMark

### 3.4 Dependency contract

None. Zero external dependencies. project.yml has no packages key. No SPM entry, no CocoaPods, no vendored source, and no analytics SDK. System frameworks only: SwiftUI, UIKit, Core Graphics, AVFoundation, URLSession, and Foundation. Iowan Old Style is a system face, so the target bundles no font file. URLSession performs the stamp catalog search. AVFoundation runs the live pack scan. WebKit stays unlinked.

### 3.5 Navigation contract

Mount-locked chrome. LeafView never leaves, and the perforated grid is the root. Tapping an empty perforation sets the active mount and presents Discover. Discover, Wants, Profile, Crate, Seen, and Settings arrive as sheets. Issue arrives as a sheet from Discover. Scan opens as a full-screen cover from Discover. Hinge and Cancel fuse on the active mount inside LeafView. There is no tab bar and no TabView. Read ProcessInfo arguments once, after onboarding is finished. The launch key today shows LeafView, log shows WantsView, and goals shows ProfileView. Further keys discover, scan, settings, crate, and seen each open that named screen.

### 3.6 Screen composition contract

Leaf-root fused album (Leaf holds the perforated mount grid; Discover, Wants and Profile arrive as sheets; hinge and cancel fuse on Leaf; Scan opens as a full-screen cover from Discover; Settings as sheet; no TabView)

Physical screens: LeafView, DiscoverView, WantsView, ProfileView, ScanView, SettingsView, IssueView, CrateView, SeenView, OnboardingView. LeafView is the home mechanic, a perforated mount grid that fills the remaining height, with the loose tray docked beneath. The launch key today opens LeafView after onboarding. DiscoverView is a sheet and a wall of catalog issues, one oversized result and quieter tiles, searched by country, topic, or catalog number. WantsView lists Hinged issues only and is the log launch key. ProfileView reads era and country taste from Cancelled grades only, counts CancelMarks, and is the goals launch key. CrateView is the owned plate wall of Cancelled issues. SeenView is the CancelMark ledger in day order. IssueView confirms Hinge onto the active mount. ScanView is the full-screen cover from Discover. SettingsView holds re-run onboarding, reset all data with a named confirm, the contact link https://hingeleaf-folio.pro/contact-us, and a tappable Colnect credit at https://colnect.com. OnboardingView is three pages, Continue or Next full width at the bottom, and the simulator seed marks it complete. Empty states are full pages. The leaf headline is The leaf is blank. Find the first issue.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By issue role (Leaf, Mount, Issue, HingeMark, CancelMark, SkewMark, DriftMark, Plate, Profile)**

```
Hingeleaf/
  Leaf/LeafView.swift
  Leaf/LeafCanvasView.swift
  Mount/Mount.swift
  Issue/Issue.swift
  Issue/IssueRole.swift
  Issue/Shelf.json
  HingeMark/HingeMark.swift
  CancelMark/CancelMark.swift
  SkewMark/SkewMark.swift
  DriftMark/DriftMark.swift
  Plate/Plate.swift
  Profile/ProfileView.swift
  Discover/DiscoverView.swift
  Wants/WantsView.swift
  Crate/CrateView.swift
  Seen/SeenView.swift
  Scan/ScanView.swift
  Settings/SettingsView.swift
  Store/LeafChart.swift
  DesignTokens.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Discover
A first-class screen for **Discover**. Must render empty, populated and error states.

### 5.3 Crate
A first-class screen for **Crate**. Must render empty, populated and error states.

### 5.4 Seen
A first-class screen for **Seen**. Must render empty, populated and error states.

### 5.5 Profile
A first-class screen for **Profile**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


**Scan (camera families). Mechanics from the white book scanner — add `.qr`.**

Capture:
- AVFoundation session + Vision `VNDetectBarcodesRequest` (or `AVCaptureMetadataOutput` with the same set).
- Symbologies must include `.qr` plus `.ean13`, `.ean8`, `.upce` (Code 128/39/93 if the domain uses them). Linear-only misses QR packs and QR-encoded EANs.
- Permission: notDetermined → `requestAccess` (system alert is the first ask). A pre-screen is allowed only if the proceed button is **Continue** or **Next**.
- Guideline 5.1.1 reject: any CTA that directs the grant — `Allow camera`, `Enable camera`, `Grant camera`, `Allow camera access`, or a bare `Allow` / `Enable` / `Grant` on the button that calls `requestAccess`.
- Denied/restricted → copy + Open Settings (`UIApplication.openSettingsURLString`). Never a second Allow/Enable button.
- No capture device (Simulator): sample-code chips + mandatory manual field. Fully usable without a camera.
- Start the session on appear; `stopRunning` on disappear and on background.
- Cooldown 1.5–2.0 s after a decode. Skip frames (every 3rd is enough). Ignore the same payload while a lookup is in flight.
- Continuous autofocus / autoexposure when supported. `alwaysDiscardsLateVideoFrames`. Preview `resizeAspectFill`.

Payload (camera, typed, pasted URL):
- Keep digit runs of length 8–14. A QR/URL may be text — extract those runs; do not require the whole payload to be digits.
- 12-digit UPC-A → prefix `0`.
- Try every candidate before miss. EAN-8/13, UPC-A/E, QR carrying any of those.

---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Title** — named per this app's convention.
- **CrateItem** — named per this app's convention.
- **Rating** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **vodafone · pop-tiles · branded**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#FFFFFF` | Screen background |
| `surface` | `#FFFFFF` | Cards, rows, sheets |
| `ink` | `#000000` | Primary text and icons |
| `accent` | `#E60000` | Primary action, key figure, progress fill |
| `muted` | `#6B6B6B` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Hingeleaf/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Iowan Old Style**

Iowan Old Style is the only face, reached through one accessor with six Dynamic Type steps: display, title, headline, body, caption, and micro. Display is IowanOldStyle-Bold, short, wide, and uppercase, one or two lines, for the leaf title and the Cancel verb. Body is IowanOldStyle-Roman on the body step, about 17 points, and it tracks Dynamic Type. The one playful moment is IowanOldStyle-Italic on the catalog number. Grades, mount counts, and day labels go through NumberFormatter with tabular figures. Custom sizes use ScaledMetric or Font.custom relative to a text style, never a fixed size that ignores Dynamic Type. At the largest accessibility size the display steps down inside the same scale so a title stays whole. No second family and no bundled font file. Day edges use Calendar.current.startOfDay and then an Int in YYYYMMDD form.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **28pt** for cards, sheets and primary surfaces; **14pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **hairline+fill** — a 1pt hairline border plus a flat fill tint, reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI WKWebView representable · canvas-first**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI WKWebView representable · canvas-first** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **vodafone** — steal rhythm and restraint, not their colours or logos.

Mood: **Global telecom brand. Monumental uppercase display, Vodafone Red chapter bands.**.

Home rhythm (`pop-tiles`, airy): Pop tiles, one oversized, the rest quiet.

High-end agency: huge type, air, one accent, hairline depth. Layout `pop-tiles`, density airy. Kit 28/14, hairline+fill, filled capsule. Palette recipe `branded`. Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Soft rounded UI type, one playful moment, no serif. Reference type feel: agency.

Motion (`stagger`): Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

UserDefaults stores one Codable Chart root, LeafChart, under the single key hlf.chart.v1. LeafChart holds the mounts, the issues, the cached search sessions, the hinge runs, and the marks HingeMark, CancelMark, SkewMark, and DriftMark, which is this album's reading of the assigned single record of Islands, Books, Sessions, Runs, and Rhumbs. A Plate on a Cancelled issue stores the grade from 1 to 5 and a short local note. Each mark schedules a debounced save of about 400 milliseconds, with a flush when scenePhase leaves active. Day values are Ints in YYYYMMDD form from Calendar.current.startOfDay. schemaVersion starts at 1. A decode failure restores an empty leaf and does not crash. Views talk to one store seam. resetAllData deletes the key from Settings. Search uses the cgi search pl parameter shape, search_terms, json=1, page, and page_size 20, against https://colnect.com/en/stamps/list with User-Agent Hingeleaf/1.0 (iOS; +https://hingeleaf-folio.pro). JSONDecoder uses useDefaultKeys. A bundled shelf answers when the catalog returns nothing or fails. The simulator seed runs once behind hlf.demo.v1, marks onboarding complete, and is absent from device builds. It seats two Cancelled plates with grades, one Hinged issue whose Cancel control is enabled, and one Loose issue in the tray.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Hingeleaf/1.0 (iOS; +https://hingeleaf-folio.pro)` on every request. Never reuse another app's string.
Use the **cgi search pl** search endpoint for this app.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.entertainment`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_NSCameraUsageDescription: The camera reads barcodes on retail stamp packs so you can find the matching catalog issue and add it to your album leaf.
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.entertainment
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Hinge-then-cancel (search or scan writes Loose; Hinge writes a HingeMark and folds Loose to Hinged; Cancel writes a CancelMark and folds Hinged to Cancelled; grade and Profile fold only Cancelled; Cancel on Loose writes SkewMark; hinged wants never enter taste)

Home is the perforated album leaf, and the home verb is cancel-the-hinge. Search or scan writes an Issue as Loose, Hinge writes a HingeMark on the tapped empty mount and folds Loose to Hinged, and Cancel writes a CancelMark and folds Hinged to Cancelled. Grade from 1 to 5 and Profile taste fold only on Cancelled issues, and the Wants rail lists Hinged issues only. Cancel on Loose writes a SkewMark and keeps Loose, Cancel on Hinged without a seated HingeMark writes a DriftMark, a second Hinge on the same Issue is refused, and Peel drops the last CancelMark or HingeMark. The simulator seed seats one Hinged issue on the leaf and one Loose issue in the tray so the opening live tap is Cancel.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Bauhaus geometric · collage · take philately**


This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

Base prompt, reused and extended for every asset:

```
Bauhaus geometric collage taking philately. Flat paper planes, solid discs for perforations, a thick hinge tab, and a stamp plate reduced to a rectangle and a bar. Hard edges, overlapping cut paper, album geometry. Solid masses with real weight. No letters, no photographs of postmarks, no clay, no glass, no hollow frames. Mood is monumental and calm, technique is collage of geometric philatelic parts. Palette is applied later, so the prompt names no hues.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `hlf_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `hlf_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `hlf_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `hlf_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `hlf_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `hlf_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `hlf_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `hlf_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `hlf_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `hlf_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `hlf_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Hinge-then-cancel (search or scan writes Loose; Hinge writes a HingeMark and folds Loose to Hinged; Cancel writes a CancelMark and folds Hinged to Cancelled; grade and Profile fold only Cancelled; Cancel on Loose writes SkewMark; hinged wants never enter taste)' feature screen. |
| 11 | `hlf_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `hlf_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`hlf_AppIcon`** — 1024x1024

```
Bauhaus geometric collage emblem of a solid stamp plate seated on a perforated square, filling the canvas edge to edge, no letters, no transparency, no rounded outer mask.
```

**`hlf_Splash`** — 1290x2796

```
Vertical Bauhaus collage of an album leaf, quiet center band for a wordmark, solid perforation discs along the edges, flat overlapping paper planes, full bleed.
```

**`hlf_Onboarding1`** — 1024x1536

```
Solid cutout of a closed stamp album as one thick opaque mass, Bauhaus planes, philately in a single glance, subject centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hlf_Onboarding2`** — 1024x1536

```
Solid cutout of a hinge tab seating a stamp plate, mid gesture, opaque geometric collage, subject centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hlf_Onboarding3`** — 1024x1536

```
Solid cutout of a verified stamp plate crossed by a thick cancellation bar, opaque, accumulated collection, subject centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hlf_EmptyHome`** — 1024x1024

```
Solid closed album block, fully opaque, calm and inviting, waiting to be filled, Bauhaus geometric collage, subject centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hlf_EmptyList`** — 1024x1024

```
Solid rectangular mount plate with a row of perforation discs along one edge, opaque, quiet, subject centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hlf_CardBackdrop`** — 1200x800

```
Full-bleed Bauhaus geometric collage of wide paper planes and a few solid discs, low detail so type can sit on it.
```

**`hlf_ControlFace`** — 512x512

```
Solid filled hinge tab, thick opaque wafer, the face of the mount control, Bauhaus geometry, subject centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hlf_TwistHero`** — 1024x1024

```
Solid emblem of a hinge tab meeting a cancellation bar, opaque geometric collage, philately, subject centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hlf_SuccessMark`** — 512x512

```
Solid filled confirmation disc crossed by a thick bar, opaque mass in the center, Bauhaus, not an outline.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`hlf_HeaderDecor`** — 1200x600

```
Wide Bauhaus band of solid perforation discs and one horizontal bar, collage, no letters, full width ornament.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`hlf.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `HingeleafTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Hingeleaf/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Hingeleaf -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Hinge ADT fold (Loose | Hinged | Cancelled); the leaf is a fold over Issues; search or scan writes Loose; Hinge writes a HingeMark on an empty mount and folds Loose to Hinged; Cancel writes a CancelMark and folds Hinged to Cancelled; grade folds only Cancelled; Cancel on Loose writes SkewMark; Cancel without HingeMark writes DriftMark; a second Hinge on the same Issue is refused; Peel drops the last HingeMark or CancelMark; an empty leaf writes Blank** with no leakage across layers.
- [ ] UI approach matches **SwiftUI WKWebView representable · canvas-first**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Mount-locked chrome (the perforated album leaf never leaves; Discover, Wants and Profile arrive as sheets; hinge and cancel fuse on the active mount; Settings as a sheet; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Iowan Old Style** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Hingeleaf
xcodegen generate
xcodebuild build-for-testing -scheme Hingeleaf -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.hingeleaf.folio/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Hingeleaf -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.hingeleaf.folio/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Hingeleaf -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.hingeleaf.folio/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
