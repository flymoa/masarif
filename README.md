# Masarif

**Kol dirham 3ndo blasto.** — App dyal masarif o dakhl b dirham (DH), kamla b Darija Arabizi.

Flutter (Android, iOS, Web) + Firebase (Auth b email, Firestore offline-first) — plan Spark gratuit.

## Chno kaydir

- Tsjil masrouf / dakhl f 3 taps, m3a categories wad7in (Makla, Tqdya, Na9l, Lekra, Fawatir, Se77a, Netflix…).
- **Li b9a lik** had chher f Ra2issya (m3a 3in bach tkhbi l mablagh).
- **I7sa2iyat**: simana / chher / 3am, donut dyal categories.
- **Dwayr zman**: khbi o jbed l flous, hadaf, o popup "Shat lik" f akhir chher.
- Sync bin ga3 l appareils, khddam bla internet.
- Mode fat7 / gham9, tswira dyal l profil, tanbihat.

## L dossiers

| Dossier | Chno fih |
| --- | --- |
| [`masarif_app/`](masarif_app/) | Code dyal l app (Flutter) |
| [`mockups/`](mockups/) | Design: mockups V2 (fat7 o gham9), brand, icones, [glossaire](mockups/GLOSSAIRE.md) |
| [`PDR — App Masarif (Flutter).md`](PDR%20%E2%80%94%20App%20Masarif%20(Flutter).md) | Cahier des charges (PDR) |

## Telecharger l APK

- **Releases**: ay tag `v*` (b7al `v1.0.0`) kaybni APK o kay7ttha f [Releases](../../releases).
- **Kol push l `main`**: l APK kayban f [Actions](../../actions) → akhir run → *Artifacts*.

> L APK dyal V1 msiniya b clé debug (mzyana l tests o partage). Bach tnzzlha f Play Store khass clé dyal release.

## Khddem l app 3la l PC

```powershell
cd masarif_app
flutter pub get
flutter run -d chrome
```

## Firebase

- Projet: `masarif-3120` (Auth email/password + Firestore).
- Les règles dyal sécurité: [`masarif_app/firestore.rules`](masarif_app/firestore.rules) — kol user kaychouf ghir data dyalo.
- Deploy dyal les règles: `firebase deploy --only firestore:rules`.
