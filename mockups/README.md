# Masarif — Mockups

Live canvas: https://claude.ai/artifact/6yQrMTcS9Bf7QGz8RHWhe6

- `light/` — 16 screens (mode clair), `dark/` — 16 screens (mode sombre). 390×844 each.
- `canvas.json` — layout dyal l canvas (titles P1 → P13, M1).

## Screens → files

| PDR | File |
| --- | --- |
| P1 Splash | Main.dc.html |
| P2 Login | Login.dc.html |
| P3 T9eyd db | Signup.dc.html |
| P3b Nsit l mot de passe | ForgotPassword.dc.html |
| P4 Ra2issya | Home.dc.html |
| P5 Lmo3amalat | Transactions.dc.html |
| P6 Zid mo3amala | AddTransaction.dc.html |
| P7 Tafasil / 3dl | TransactionDetail.dc.html |
| P8 Ta7lil | Stats.dc.html |
| P8b Tafasil chher | MonthDetail.dc.html |
| P9 Categories | Categories.dc.html |
| P10 Zid / 3dl naw3 | CategoryEdit.dc.html |
| P11 Profil | Profile.dc.html |
| P12 Dwayr zman | DwayrZman.dc.html |
| P13 Khbi / Jbed | DwayrZmanMove.dc.html |
| M1 Popup "Shat lik" | PopupShat.dc.html |

## Design tokens (l Flutter ThemeData)

| Token | Light | Dark |
| --- | --- | --- |
| background | #EDF1EE | #0D1512 |
| surface (cards) | #FFFFFF | #16211C |
| text | #15201B | #EEF2EC |
| text muted | #5B665F | #9AA79F |
| border | #D9E1DB | #2A3832 |
| divider | #E8EDE9 | #22302A |
| primary (green) | #134232 | #134232 (cards) / #7FD3A4 (links, active) |
| accent (gold, buttons) | #E9B949, text #1B1A12 | same |
| positive (dakhl) | #17714A | #5FC48E |
| danger (7yed) | #B42318 | #F28B82 |

**Categories (bg / icon):** Makla #FCE8D8 / #B0541C · Na9l #E0E9F7 / #2E5AA8 · Lekra #EDE3F6 / #6B3FA0 · Fawatir #F7EDCB / #8A6512 · Okhra #E8E6E1 / #55524B · Salaire #DDEFE4 / #17714A

**Typo:** Space Grotesk (titres, ar9am kbar) · Inter (body). **Radius:** cards 18–24, inputs/buttons 16, chips 999. **Spacing:** padding l page 20. **Boutons** ≥ 48 px.

---

## V2 (design jdid — li m3tamed)

| Dossier | Chno fih |
| --- | --- |
| `v2/light/` | 17 écrans V2 f mode fat7 (V2Home, V2Transactions, V2Add, V2Stats, V2Savings, V2Profile, V2Notifs, V2Login, V2Signup, V2Forgot, V2TxDetail, V2Month, V2Categories, V2CatEdit, V2Move, V2Popup, V2Splash) |
| `v2/dark/` | Nfs les 17 écrans f mode gham9 (DarkV2…) |
| `brand/` | Ikhtiyarat dyal font, logo o animation dyal dekhla |
| `icons/` | `icon.png` (icone dyal l app 1024px), `icon_fg.png` (Android adaptive), `logo-khatam.svg` |
| `icons/categories/` | Icones dyal categories (SVG): car, coffee, cart, resto, pharma, bolt, play, home, box, salary, netflix, spotify |

**Tokens V2:** khalfiya `#F2F4F1` / `#0C1411` · cartes `#FFFFFF` / `#16211C` · khder `#0F3B2C` · dhbi `#E8B53C` · texte `#13201A` / `#EEF2EC` · font **Lexend**.
