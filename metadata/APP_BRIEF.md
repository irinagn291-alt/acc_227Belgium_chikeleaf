<!-- gf-brief source=61707b7884c29f00599e0afe5164dbb31ea363e3d4298df6a4384d00be191707 written=2026-10-14T18:42:53+03:00 -->
# Hingeleaf

## What it is
Hingeleaf is a personal stamp album. A collector searches or scans a catalog issue, seats it on a perforation as a want, cancels that hinge when the paper stamp is in hand, then grades the owned copy from 1 to 5. Taste totals those cancelled grades by country. It is for people who file stamp wants and owned copies on one leaf.

## Launch and onboarding
After the system launch screen, a first run (or any run where onboarding has not been finished) shows three pages under the band **HINGELEAF**. **Skip** on any page finishes onboarding and opens the leaf. There is no back control and no swipe between pages.

1. Title: **Seat the next stamp.** Line: **Search or scan a catalog number onto an empty perforation.** Buttons: **Continue**, **Skip**.
2. Title: **Cancel the hinge.** Line: **When the paper stamp is in hand, cancel that perforation.** Buttons: **Continue**, **Skip**.
3. Title: **Grade only what you own.** Line: **Taste reads country from cancelled grades.** Buttons: **Start filing**, **Skip**.

**Start filing** and **Skip** both open the leaf. Later cold launches skip these pages and open **THE LEAF** with the album as it was left.

## Screens

### THE LEAF
Home. Band: **THE LEAF**. There is no tab bar. Other screens open as sheets from chips or from an empty perforation.

**When the album has no stamps yet**
- Title: **The leaf is blank. Find the first issue.**
- Line: **Search a country, a topic, or a catalog number.**
- Button: **Find a stamp** — opens **DISCOVER**.

**When any stamp is on the album (in the tray or on a perforation)**
Destination chips (left to right):
- **Wants** — opens **WANTS**.
- **Profile** — opens **TASTE**.
- **Crate** — opens **CRATE**.
- **Seen** — opens **SEEN**.
- **Settings** — opens **SETTINGS**.

Leaf pager:
- **Previous leaf** — goes to the earlier page of 12 perforations. Disabled on the first page.
- Caption: **Leaf X of Y** (device number format).
- **Next leaf** — goes to the later page. Disabled on the last page.
- **Add a leaf** — appends 12 empty perforations and jumps to that new page.

The perforated page:
- Empty spots show **Open**. VoiceOver: **Open perforation**. Tap opens **DISCOVER** for that spot.
- A seated stamp shows its title; the selected spot also shows the catalog number. VoiceOver: **“{title}, {catalog number}”**.
- A hinged stamp has a hinge tab and a dashed outline.
- A cancelled stamp has a circular cancel mark, a Roman grade **I**–**V** when graded, and the day-of-month from the cancel.
- Tap a filled spot to select it. It becomes the large spot; the others sit in a quieter grid.

**In the tray**
- Empty: **The tray is clear. Search fills it.**
- Otherwise a horizontal row of loose stamps (title and catalog number). VoiceOver: **Loose {title}**. Tap selects one.
- With a tray stamp selected:
  - **Cancel without a hinge** — records a skew (the stamp stays loose in the tray). Disabled while a mark is being written.
  - **Clear from tray** — removes that loose stamp from the album.

Bottom verbs (prompt depends on the selected perforation):
- Empty spot: **Pick a perforation, then hinge a stamp from the tray.**
- Hinged: **{title} is hinged. Cancel it.** Caption: **Hinged. Cancel when the stamp is in hand.**
- Cancelled: **{title} is cancelled. Grade the copy.** Caption: **Cancelled. Grade this copy from 1 to 5.**
- Loose (should not sit on a perforation in normal use): **{title} is still loose.** / **Loose in the tray.**
- After a successful cancel of a hinge, **In hand.** appears briefly.
- Grade capsules **1** **2** **3** **4** **5** (VoiceOver: **Grade 1** … **Grade 5**) — only after the selected stamp is cancelled. Tap sets that grade.
- Field **Local note** — only after cancel. Keyboard **Done** dismisses the keyboard and saves if a grade is already set.
- **Hinge** (while working: **Seating**) — only when a tray stamp is selected and the selected perforation is empty. Seats that stamp as a want. Disabled while working.
- **Cancel** (while working: **Cancelling**) — enabled only when the selected perforation holds a hinged want. Marks the copy in hand. Disabled on empty spots, loose tray-only stamps, and already cancelled copies.
- **Peel last mark** — asks **Peel the last mark?** Message: **The latest hinge or cancel comes off.** Buttons: **Keep it**, **Peel mark**. Disabled while working.
- Fault lines (exact): **That stamp is not on the leaf.** / **Pick a perforation first.** / **That perforation already holds a stamp.** / **This stamp already has a hinge.** / **Only a loose stamp can take a hinge.** / **This copy is already cancelled.** / **Grade from 1 to 5.** / **Grade only after you cancel the hinge.** / **Nothing left to peel.**

### DISCOVER
Band: **DISCOVER**. Navigation title: **Discover**. Toolbar: **Close** (VoiceOver: **Close discover**).

Always at the top:
- Field: **Country, topic, or number**. Keyboard **Done**. Submit runs search.
- **Search** (while working: **Searching**) — disabled when the field is empty or a search is in flight.
- **Scan** — opens **SCAN**.

States:
- First visit / no results and no error: **The crate is empty.** Line: **Type a country, a topic, or a catalog number.** Button: **Scan a pack** — opens **SCAN**.
- Searching with no results yet: placeholder tiles. VoiceOver: **Searching the catalog**.
- Catalog failure with no tiles: **The catalog did not answer.** Body is the notice, or **Try the search again, or read the saved shelf.** Buttons: **Search again**, **Show the shelf**.
- Results: optional notice, then one large first issue and a two-column wall. Each tile shows country (uppercase), title, catalog number, topic. Tap opens **HINGE** for that issue.

Notices that can appear on this wall or after a failed lookup:
- **The catalog had no match. Showing the album shelf.**
- **That code is not in the catalog. Showing the album shelf.**
- **The catalog did not answer. Showing the album shelf.**
- **The catalog did not answer.**
- **No catalog code in that scan. Showing the album shelf.**
- **No pack matched. Showing the album shelf.**

**Show the shelf** fills the wall with the saved album shelf (see Starter content). A successful **Search** also drops matching issues into **In the tray** on the leaf.

### HINGE
Opened from a Discover tile or from a successful scan. Band: **HINGE**. Toolbar: **Close** (VoiceOver: **Close hinge**).

Shows country (uppercase), title, catalog number, topic, and year when the catalog has one. Card copy:
- **Hinge seats this stamp on the open spot as a want. Cancel later, when the paper is in hand.**
- **Taste ignores it until you cancel.**

If no perforation is selected: **Pick an open spot on the page first.** and **Hinge** is disabled.

**Hinge** (while working: **Seating**) seats the stamp on the open spot that was current when Discover or Scan opened, then closes this screen. Same fault lines as the leaf if the spot is taken or the stamp already has a hinge.

### SCAN
Full-screen. Band: **SCAN**.

If this device has a camera and access is not decided:
- **The next step asks the system about the camera so a pack barcode can be read.**
- **Continue** — presents the system camera alert. The system alert is the only control that says Allow.

If the camera is denied or restricted:
- **The camera is off for Hingeleaf. Open Settings to change that, or type the pack code.**
- **Open Settings** — opens iOS Settings for this app.

If the camera is allowed, a live preview reads pack barcodes and QR codes.

If there is no camera:
- **No camera on this device. Use a sample code or type the pack number.**
- Sample chips: **5012345678901**, **012345678905**, **4006381333931**.

Always:
- Field: **Pack code or link**. Keyboard **Done**.
- **Look up** (while working: **Looking**) — disabled when the field is empty or a lookup is in flight.
- **Close**.

A readable code or a successful look-up closes Scan (and Discover) and opens **HINGE** for the first match. If nothing matches, Scan stays up with a notice such as **No catalog code in that scan.**, **The catalog did not answer. Try the code again.**, **Showing the album shelf.**, or the shelf notices above.

It expects an 8-to-14-digit run from a retail pack barcode, a QR code, a typed pack number, or a link that contains such digits.

### WANTS
Band: **WANTS**. Toolbar: **Close** (VoiceOver: **Close wants**). Lists hinged stamps only.

- Empty: **No hinged wants yet.** Line: **Search a country or a catalog number, then hinge it. It stays here until you cancel.** Button: **Find a stamp** — opens **DISCOVER**.
- If the album could not be read and the list is empty: **The wants could not be read.** Line is the recovery sentence. Button: **Try the leaf again** — dismisses the notice.
- Populated: first want is large; tap (VoiceOver: **Open {title} on the leaf**) closes Wants and selects that perforation on the leaf. Stats: **Hinged** (count) and **Still loose** (tray count). Each later row repeats country, title, catalog number, topic, the hinge day (medium date in the device locale), and **Still a want. Cancel it when the paper arrives.** Tap a row the same way as the first want.

### TASTE
Opened from **Profile**. Band: **TASTE**. Toolbar: **Close** (VoiceOver: **Close taste**). Counts cancelled grades only. Hinged wants are excluded.

- Empty: **No cancelled grades yet.** Line: **Cancel a hinge, then grade the copy. Taste counts those cancels.** Button: **Back to the leaf**.
- Recovery when empty: **Taste could not be read.** Button: **Try the leaf again**.
- Populated card: badge **CANCELS**, the cancel count, **Copies in hand, not search history.**, **Average grade X.X**, **Skew X. Drift Y.**
- One row per country: country name and **Grade total {sum} across {count}**.
- **Eras** when years exist: **Classic**, **Early Modern**, **Mid-Century**, **Contemporary**, each with a count.
- **Notes** — the **Local note** lines from graded cancelled copies.

### CRATE
Band: **CRATE**. Toolbar: **Close** (VoiceOver: **Close crate**). Cancelled copies only.

- Empty: **The crate is empty.** Line: **Cancel a hinge and the copy lands here.** Button: **Find a stamp** — opens **DISCOVER**.
- Recovery when empty: **The crate could not be read.** Button: **Try the leaf again**.
- Populated: first copy is large (**Owned and graded.**); later rows say **In the crate.** Each shows country, title, catalog number, **Grade {n}** when graded, and the local note when one exists. Rows are not buttons.

### SEEN
Band: **SEEN**. Toolbar: **Close** (VoiceOver: **Close seen**). Cancel days in order, newest day last. Skew and drift are not listed here.

- Empty: **No cancels on the ledger.** Line: **When you cancel a hinge, the day lands here.** Button: **Back to the leaf**.
- Recovery when empty: **The ledger could not be read.** Button: **Try the leaf again**.
- Populated: the cancel count, **Cancels, newest day last.**, then rows of title (or **Stamp** if the issue is missing), the day label, and catalog number. Rows are not buttons.

### SETTINGS
Band: **SETTINGS**. Toolbar: **Close** (VoiceOver: **Close settings**).

- **Run onboarding again** — closes Settings and replays the three **HINGELEAF** pages. The album is kept.
- **Haptics** — toggle, on by default.
- **Export album folio** — writes a one-page folio. The control then becomes **Share album folio** and opens the system share sheet. The folio title on the page is **Chikeleaf**. Lines are catalog number, title, role (**loose** / **hinged** / **cancelled**), and **grade N** when graded. If nothing is seated: **The leaf is blank.**
- Heading **Erase everything**. Line: **This deletes hinges, cancels, and grades on this device.** Button: **Erase everything** — alert **Erase everything?** Message: **Hinges, cancels, and grades on this device are deleted.** Buttons: **Keep it**, **Erase everything**. Confirming clears the album, closes Settings, and shows onboarding again.
- **Contact Hingeleaf** — opens the support page in the browser.
- **Catalog credit, Colnect** — opens the catalog credit page in the browser.

Recovery sentences that can appear as the body of the empty Wants / Taste / Crate / Seen states: **Recovered the last good album leaf.** / **The album file was unreadable. Started a blank leaf.** / **The album could not be saved.** / **The album copy on disk could not be written. The leaf on screen is unchanged.**

## Features
- Perforated **leaf** with pages of 12 spots; **Add a leaf**, **Previous leaf**, **Next leaf**
- **Open** perforations; tap to **Discover**
- **Discover** search by country, topic, or catalog number
- **Scan** a retail pack barcode, QR code, or typed **Pack code or link**
- Saved **album shelf** when the catalog has no match or does not answer
- **In the tray** for loose stamps; search fills the tray
- **Hinge** a loose stamp onto an empty perforation as a want
- **Wants** list of hinged stamps until they are cancelled
- **Cancel** a hinge when the paper is in hand (**In hand.**)
- **Cancel without a hinge** (counts as skew on Taste; the stamp stays in the tray)
- **Clear from tray**
- **Grade** 1 to 5 only after cancel
- **Local note** on a graded cancelled copy
- **Taste** (from **Profile**): country grade totals, average grade, eras, notes, skew and drift counts
- **Crate** of owned cancelled copies
- **Seen** cancel ledger by day
- **Peel last mark** (undo the latest hinge or cancel)
- **Export album folio** / **Share album folio**
- **Haptics**
- **Run onboarding again**
- **Erase everything**
- **Contact Hingeleaf**
- **Catalog credit, Colnect**

## Behaviours that can look like bugs
- **Search** and **Look up** stay dim until the field has text. Type a country, topic, number, or pack code.
- **Hinge** on the leaf is hidden until a tray stamp is selected and an **Open** perforation is selected. Select both, then tap **Hinge**.
- **Hinge** on the **HINGE** screen stays dim if no spot was current. Close, tap an **Open** perforation (that opens Discover), then hinge. If the current spot already holds a stamp, **Hinge** is enabled but then shows **That perforation already holds a stamp.** Tap an empty **Open** spot first.
- A second hinge on the same issue shows **This stamp already has a hinge.** It is already a want; go to the leaf and **Cancel**.
- **Cancel** on the leaf stays dim until the selected spot is a hinged want. Hinge first, or open **Wants** and tap the want to jump to that spot.
- **Cancel without a hinge** does not move the stamp to the crate and does not show **In hand.** The stamp stays loose. Taste’s **Skew** count rises. To own the copy, **Hinge** then **Cancel**.
- Grade capsules and **Local note** appear only after a hinge is cancelled. A note does not persist until a grade **1**–**5** is chosen.
- **Peel last mark** is always offered; with nothing to undo it shows **Nothing left to peel.** Peel of a cancel returns that stamp to hinged and drops its grade and note. Peel of a hinge returns it to the tray and leaves the spot **Open**.
- **Previous leaf** / **Next leaf** do nothing at the ends of the pager. **Add a leaf** if more empty spots are needed.
- There is no **Discover** chip on the leaf. After the first stamps exist, tap an **Open** perforation, or use **Find a stamp** from empty Wants or Crate. If every visible spot is filled, **Add a leaf** first.
- Discover’s first empty state is titled **The crate is empty.** even though this is not the Crate screen. Type a query and tap **Search**, or tap **Scan a pack**.
- **Show the shelf** only fills Discover. Those shelf stamps enter the tray when a later search remembers them, or when **Hinge** is confirmed.
- **Profile** opens a screen titled **TASTE**, not Profile.
- **In hand.** disappears on its own after a short moment; the cancel has already been recorded.
- **Export album folio** must be tapped once before **Share album folio** appears. The shared page is titled **Chikeleaf**, not Hingeleaf.
- **Erase everything** also replays onboarding. **Run onboarding again** replays onboarding but keeps the album. **Skip** or **Start filing** returns to the leaf.
- **Try the leaf again** only clears a recovery notice; it does not load stamps that were never hinged or cancelled.

## Starter content and resume
The leaf starts blank: 12 **Open** perforations, empty tray, no wants, no crate, no taste, no ledger.

A saved album shelf can appear in Discover after **Show the shelf**, a no-match search, or a failed catalog / scan lookup. Those issues, as shown:

- **Penny Red** — **GREAT BRITAIN** — **Queen Victoria** — **GB 8** — **1858**
- **Sower** — **FRANCE** — **Allegory** — **FR 130** — **1903**
- **Crane** — **JAPAN** — **Birds** — **JP 214** — **1949**
- **Fort Bliss** — **UNITED STATES** — **Flags** — **US 899** — **1940**
- **Castle** — **GERMANY** — **Buildings** — **DE 44** — **1924**
- **Roman Forum** — **ITALY** — **Monuments** — **IT 77** — **1929**
- **Pack Code** — **GERMANY** — **Commerce** — **DE 400** — **1998**
- **Z Grill** — **UNITED STATES** — **Franklin** — **US 85** — **1868**
- **Ashoka Capital** — **INDIA** — **Emblem** — **IN 201** — **1949**
- **Coffee Branch** — **BRAZIL** — **Agriculture** — **BR 412** — **1938**
- **Kangaroo** — **AUSTRALIA** — **Fauna** — **AU 1** — **1913**
- **Heavenly Gate** — **CHINA** — **Architecture** — **CN 88** — **1964**
- **Aurora** — **SWEDEN** — **Sky** — **SE 310** — **1986**

On a device with no camera, the sample chips **5012345678901**, **012345678905**, and **4006381333931** look up **Penny Red**, **Fort Bliss**, and **Pack Code**.

Unfinished work resumes. Finished onboarding, extra leaves, loose tray stamps, hinged wants, cancels, grades, local notes, and haptics preference return on the next launch. **Erase everything** is the only in-app wipe.

## Permissions
Camera, only on **SCAN**, and only after **Continue** when access has not been decided. Usage description: **The camera reads barcodes on retail stamp packs so you can find the matching catalog issue and add it to your album leaf.**

If already allowed, the preview starts when Scan opens. If denied or restricted, the app does not ask again; it shows **Open Settings** and the type-in field.

No other permissions.

## Absent
Genuinely absent: login or accounts, in-app purchase, ads, App Tracking Transparency prompt, account deletion flow. There is no public feed or posting. The only writing is a private **Local note** on a cancelled copy. There is no in-app analytics screen.

## Data and support
Hinges, cancels, grades, and notes stay on this device (**This deletes hinges, cancels, and grades on this device.**). Discover search looks up a stamp catalog. **Contact Hingeleaf** is the support control; **Catalog credit, Colnect** is the catalog credit.

## Scanning and health
The app scans retail pack barcodes and QR codes, and accepts a typed **Pack code or link**. It looks for an 8-to-14-digit catalog or pack code in that payload. It does not show health, medical, or product-health information.

## Platform
English UI only. Dates and counts follow the device locale. No region lock. Light appearance only. Portrait only, full screen, on iPhone and iPad. Minimum iOS 17.0.

## Category
Entertainment
