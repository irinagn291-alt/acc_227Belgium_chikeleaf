# Hingeleaf

Hingeleaf is the album leaf for a stamp collection. You search or scan a catalog stamp, hinge it on an empty perforation, and cancel that hinge when the paper copy is in your hand. Wants stay hinged. Taste and grades start only after the cancel. That split is why you would pick this app instead of a plain catalog list.

Search or a retail scan writes the stamp as Loose. Hinge seats it on an empty perforation. Cancel marks the paper copy verified. Grade and Profile read only cancelled copies.

## Why this shape

The album is a fold, not a status flag you edit in place. `IssueRole` is Loose, Hinged, or Cancelled. `IssueFold` is the only writer of that role. A hinge writes a `HingeMark` and folds Loose to Hinged. A second hinge on the same issue is refused. Cancel on a seated hinge writes a `CancelMark` and folds Hinged to Cancelled. Cancel on Loose writes a `SkewMark` and stays Loose. Cancel without a hinge mark writes a `DriftMark`. Peel drops the last hinge or cancel and unfolds that step. An empty leaf reads as Blank. Taste sums grades only where the role is Cancelled, so hinged wants never enter Profile.

That matches the job: wants stay hinged until the stamp is in hand, and owned plates are the cancelled ones.

## Home

The perforated leaf is the root. Discover, Wants, Profile, Crate, Seen, and Settings are sheets. Scan is a full-screen cover from Discover. There is no tab bar.

## Catalog

One client, Colnect stamp search, with a bundled shelf when the network misses. Credit: https://colnect.com
