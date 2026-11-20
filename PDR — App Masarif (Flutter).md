# PDR — App Masarif (Flutter)

Nov 20, 2026 · @Mohamed

Version 1.0 · Platform: Android + iOS (Flutter) · 3omla: Dirham maghribi (DH)

## 1. Lhadaf dyal l app (Goals)

L app katkhalli l user ytba3 masarifo o dakhlo b dirham, b tariqa sahla o sri3a, o ychouf fin kaymchiw flouso.

1. **Tsjil sri3**: zid masrouf f a9al mn 10 tawani (3 taps: mablagh → categorie → sauvegarder).
2. **Wodou7**: l user y3ref f ay wa9t ch7al dkhel, ch7al kharej, o ch7al bqa lih had chher.
3. **Synchronisation**: nfs l data f ga3 l appareils dyal l user (telephone Android, iPhone, tablette) b compte wa7ed.
4. **Lougha 9riba mn l user**: interface kamla b Darija Arabizi ("kharejt 50 DH", "dkhel lik 3000 DH").

### Mqayis dyal nja7 (KPIs)

- Tsjil masrouf jdid: ≤ 10 tawani.
- Sync bin appareils: ≤ 5 tawani mlli ykoun internet.
- Retention: 40% dyal users ki7allou l app ba3d 30 yawm.

### Kharej scope f V1 (Non-goals)

- Rbet m3a l banka (open banking) — la.
- Budgets b categorie o notifications dyal tjawoz — V2.
- 3omlat okhra ghir DH — V2.
- Partage dyal compte m3a chi wa7ed akhor — V2.

## 2. L user l mostahdaf (Persona)

**Youssef, 29 3am, Casablanca** — khddam b salaire chahri, kaykhles kra o fawatir, o kaybghi y3ref 3lach kaysali lflous qbel akhir chher. Kayst3mel telephone bzzaf, ma3ndouch sbar l Excel, o kayfdel lougha li kayhder biha.

## 3. Mafahim asasiya (Data model — bla code)

| Kiyan | Champs | Molahadat |
| --- | --- | --- |
| **User** | id, email, smiya, tarikh l inscription | Compte b email + mot de passe |
| **Mo3amala (Transaction)** | id, user\_id, naw3 (masrouf / dakhl), mablagh (DH), categorie\_id, tarikh, molahada (ikhtiyari), created\_at, updated\_at, deleted (soft delete) | Mablagh dima > 0, b 2 ar9am ba3d l fasila |
| **Categorie** | id, user\_id (null = jahza), smiya, icone, loun, naw3 (masrouf / dakhl), is\_default | Categories jahza ma kaytms7ouch, ghir kayweliw "ma kaybanouch" |

**Categories jahza (masarif):** Makla 🍽️ · Na9l 🚕 · Lekra 🏠 · Fawatir 💡 · Okhra 📦

**Categories jahza (dakhl):** Salaire 💼 · Okhra 💰

**Qawa3id:**

- "Li b9a" = majmou3 dakhl − majmou3 masarif f l fatra l mkhtara (par défaut: chher l7ali).
- Ila tmse7at categorie dyal l user, l mo3amalat dyalha kaymchiw l "Okhra" (ma kaytmse7ouch).
- Msse7 mo3amala = soft delete + possibilité "Rje3" (Undo) 5 tawani.

## 4. Features

### F1 — Compte o auth

- Inscription b email + mot de passe (min 8 7rouf).
- Connexion, déconnexion, "Nsit l mot de passe" (email dyal reset).
- Session tb9a m7loula 7ta y déconnecta l user.

### F2 — Masarif o dakhl (CRUD)

- **Zid**: mablagh, naw3 (masrouf/dakhl), categorie, tarikh (par défaut: lyoum), molahada.
- **3dl**: ay champ.
- **Msse7**: b confirmation o Undo.
- Liste mratba b tarikh (jdid lfo9), mjmou3a b nhar ("Lyoum", "Lbare7", "18 Nov").
- Filtre b categorie o b fatra; recherche f molahada.

### F3 — Categories

- Categories jahza (makla, na9l, Lekra, fawatir...).
- Zid categorie dyalk: smiya + icone + loun + naw3.
- 3dl / Msse7 categorie dyalk; "Ma tbanch" l categorie jahza.

### F4 — Graphe o ta7lil

- Graphe b barres: masarif vs dakhl, b chher (6 chhour lkhrin).
- Carte "Li b9a" (dakhl − masarif) b loun: khder ila +, 7mer ila −.
- Top categories dyal masarif f chher l mkhtar (b nisba %).
- Tap 3la barre → ychouf détail dyal dak chher.

### F5 — Sync cloud

- Data kat tsjel f cloud database marbouta b compte.
- **Offline-first**: l user y9der yzid/y3dl bla internet; l sync kaydar mlli yrj3 l internet.
- Conflit: "akhir t3dil kaydi" (last-write-wins 3la updated\_at).
- Indicateur sghir: "Msynchronizi ✓" / "Bla internet — ghadi nsynchronizi mlli trje3 connexion".

### F6 — Interface o lougha

- Ga3 nsous b Darija Arabizi (chouf l9ism 8).
- Responsive: telephone sghir, kbir, tablette (portrait + paysage).
- Mode clair / sombre — label "Loun dyal système" (tab3 l système).
- Format dyal flous: "1 250,00 DH".

### F7 — Dwayr zman (Epargne)

L flous li l user kaykhbi, b jouj torq:

- **Li shat f chher**: f awwel ftou7 dyal l app f chher jdid, l app katsowl: "Shat lik {x} DH f {chher}. N7ttohom f Dwayr zman?", b jouj boutons "Iyeh, khbihom" / "La". F Paramètres kayn option "Dir had l khdma automatiquement" (bla ma tsowl).
- **Khbi b yeddi**: f ay wa9t, l user y9der yzid mablagh l Dwayr zman ("Khbi 500 DH").
- **Jbed**: l user y9der yjbed mn Dwayr zman ila e7taj ("Jbedt 200 DH"). Ma y9derch yjbed kter mn li kayn.
- **Hadaf (ikhtiyari)**: mablagh mostahdaf (ex: 10 000 DH) m3a barre dyal ta9addom (%).
- **Qa3ida dyal l 7isab**: "Li b9a" = dakhl − masarif − li tkhba had chher + li tjbed had chher. Flous Dwayr zman ma kaymchiwch f "masarif" o ma kayban'ouch f graphe dyal masarif.
- **Kiyan jdid f data model**: *Haraka dyal epargne* — id, user\_id, naw3 (khbi / jbed), mablagh, tarikh, masdar (shat\_chher / yadawi), chher\_marbout (ila shat\_chher). Sold Dwayr zman = majmou3 khbi − majmou3 jbed. Hadaf kaytsjel f l User (epargne\_goal, ikhtiyari).

## 5. L pages (Screens)

| # | Page | Lhadaf | Mo7tawa ra2isi | Actions |
| --- | --- | --- | --- | --- |
| P1 | **Splash** | Ychargi o ychouf session | Logo | Auto → P2 wla P4 |
| P2 | **Tsjil  dkhoul (Login)** | Ydkhol l compte | Email, mot de passe | "Dkhol", "Nsit l mot de passe" → P3b, "Ma3ndkch compte?" → P3 |
| P3 | **T9eyd db** | Ycréer compte | Smiya, email, mot de passe x2 | "Sjel" → P4, "3ndk compte?" → P2 |
| P3b | **Nsit l mot de passe** | Reset | Email | "Sift" → message → P2 |
| P4 | ** Ra2issya ****(Home / Dashboard)** | Ra2i sri3 | Carte "Li b9a had chher", dakhl, masarif, 5 akhir mo3amalat | FAB "+" → P6, "Chouf kolchi" → P5, tap 3la mo3amala → P7 |
| P5 | **Lmo3amalat (Liste)** | Kolchi | Liste b nhar, filtres, recherche | Tap → P7, FAB "+" → P6, swipe → Msse7 |
| P6 | **Zid mo3amala** | Tsjil | Toggle masrouf/dakhl, mablagh (clavier ar9am), categories (grille), tarikh, molahada | "Sjel" → rj3 l page li jat mnha, "Lghi" → rj3 |
| P7 | **Tafasil / 3dl mo3amala** | Chouf o 3dl | Nfs champs dyal P6 m3ammrin | "Sjel t3dil", "Msse7" (confirmation) → rj3 |
| P8 | **Ar9am (Stats)** | Ta7lil | Graphe barres 6 chhour, "Li b9a", top categories | Tap barre → P8b, tap categorie → P5 m filtrya |
| P8b | **Tafasil chher** | Détail | Majmou3 + liste dyal categories dyal chher | Tap categorie → P5 m filtrya |
| P9 | Anwa3 | Tsyir | Liste masarif / dakhl (tabs) | Tap → P10, "+" → P10 (khawi) |
| P10 | **Zid / 3dl naw3** | Tsyir | Smiya, icone, loun, naw3 | "Sjel", "Msse7" (ghir dyal l user) → P9 |
| P11 | **7sabi (Profil o Paramètres)** | Compte | Email, smiya, mode sombre, état sync, "Categories" | "Categories" → P9, "Khrej" → P2 |

**Pages jdad dyal Dwayr zman:**

| # | Page | Lhadaf | Mo7tawa ra2isi | Actions |
| --- | --- | --- | --- | --- |
| P12 | **Dwayr zman** | Chouf l epargne | Sold kamel, hadaf + barre %, liste dyal l harakat (khbi / jbed) | "Khbi" → P13, "Jbed" → P13, "Bddel l hadaf" → P13 |
| P13 | **Khbi / Jbed (modal)** | Tsjil haraka | Toggle khbi/jbed, mablagh, tarikh, (wla champ dyal hadaf) | "Sjel" → P12, "Lghi" → P12 |
| M1 | **Popup "Shat lik"** | Akhir chher | "Shat lik {x} DH f {chher}. N7ttohom f Dwayr zman?" | "Iyeh" → P12 + toast, "La" → P4 |

F **P4 (Lwla)** tzad carte "Dwayr zman: {sold} DH" → tap → P12. F **P11** tzad "Dwayr zman automatique" (on/off) o lien "Dwayr zman" → P12.

## 6. Navigation

**Barre l ta7t (Bottom navigation) — 4 onglets** f P4, P5, P8, P11:

1. 🏠 **Ra2issya **(P4)
2. 📋 **Lmo3amalat** (P5)
3. 📊 **Ar9am** (P8)
4. 👤 **7sabi** (P11)

Bouton **"+"** (FAB) dima zahr f P4 o P5 → P6 (modal mn l ta7t).

### Kharita dyal l rwabet (kol page fin katwsel o mnin katji)

| Page | Mnin katdkhel liha | Fin katwsellek | Rjou3 (Back) |
| --- | --- | --- | --- |
| P1 Splash | Fat7 l app | P2 (bla session), P4 (b session) | — |
| P2 Login | P1, P3, P3b, P11 (Khrej) | P4, P3, P3b | Khrej mn l app |
| P3 Inscription | P2 | P4, P2 | P2 |
| P3b Nsit l mot de passe | P2 | P2 | P2 |
| P4 Lwla | P1, P2, P3, tab | P6, P5, P7, tabs | Khrej mn l app |
| P5 Lmo3amalat | Tab, P4, P8, P8b | P7, P6, tabs | P4 |
| P6 Zid | FAB f P4/P5 | Rj3 l P4/P5 | Lghi → page l9dima |
| P7 Tafasil/3dl | P4, P5 | Rj3 l page l9dima | Page l9dima |
| P8 Ta7lil | Tab | P8b, P5 (filtre), tabs | P4 |
| P8b Tafasil chher | P8 | P5 (filtre) | P8 |
| P9 Categories | P11 | P10 | P11 |
| P10 Zid/3dl categorie | P9 | P9 | P9 |
| P11 Profil | Tab | P9, P2 (Khrej), tabs | P4 |

| Page | Mnin katdkhel liha | Fin katwsellek | Rjou3 (Back) |
| --- | --- | --- | --- |
| P12 Dwayr zman | Carte f P4, lien f P11, M1 ("Iyeh") | P13 | Page l9dima (P4 wla P11) |
| P13 Khbi/Jbed | P12 | P12 | P12 |
| M1 Popup "Shat lik" | Awwel ftou7 f chher jdid (ila l mode automatique m9fol o li shat > 0) | P12 wla P4 | Ysdd → P4 |

✅ Ta page ma m7loula (orpheline): kol page 3ndha madkhal o makhraj.

## 7. User flows

### UF1 — Awwel merra (Onboarding)

1. P1 → ma kayn session → P2.
2. "Ma3ndkch compte?" → P3 → 3ammer → "Sjel".
3. Compte tcréa + categories jahza t'zadou → P4 khawi b message: "Mazal ma zdti walou. Brek 3la + bach tzid awwel masrouf".

### UF2 — Zid masrouf ("kharejt 50 DH f taxi")

1. P4 → "+" → P6 (masrouf mkhtar par défaut).
2. Kteb 50 → khtar "Na9l" → (molahada: "taxi") → "Sjel".
3. Rj3 l P4 + toast: "Khlesti 50,00 DH f Na9l ✓". "Li b9a" kaytbddel f l7in.

### UF3 — Zid dakhl

1. "+" → toggle "Dakhl" → 8000 → "Salaire" → "Sjel".
2. Toast: "Tzadt lik 8 000,00 DH ✓".

### UF4 — 3dl wla Msse7

1. P5 → tap 3la mo3amala → P7 → bddel mablagh → "Sjel t3dil" → toast "Tbddlat ✓".
2. Wla: swipe f P5 / "Msse7" f P7 → confirmation "Bghiti tmse7 had l masrouf?" → "Iyeh" → toast "Tmse7" + "Rje3" (5 tawani).

### UF5 — Zid categorie dyali

1. P11 → "Categories" → P9 → "+" → P10.
2. Smiya "9hwa", icone ☕, loun → "Sjel" → tban f P9 o f grille dyal P6.

### UF6 — Ta7lil masarif

1. Tab "Ar9am" → P8 → ychouf barres 6 chhour + "Li b9a".
2. Tap 3la barre dyal Novembre → P8b → tap "Makla" → P5 m filtrya 3la Makla + Novembre.

### UF7 — Sync bin appareils

1. User kaydkhel b nfs email f appareil jdid → P2 → P4.
2. Data kat telecharga mn cloud; indicateur "Kaytsynchronizi…" → "Msynchronizi ✓".
3. Ay t3dil f appareil wa7ed kaybán f l akhor f ≤ 5 tawani (ila kayn internet).

### UF8 — Dwayr zman

1. 1 Decembre, l user kayfte7 l app → M1: "Shat lik 1 200 DH f Novembre. N7ttohom f Dwayr zman?" → "Iyeh" → P12 + toast "Tkhbaw 1 200,00 DH f Dwayr zman ✓".
2. Wla: P4 → carte "Dwayr zman" → P12 → "Khbi" → P13 → 500 → "Sjel" → toast "Khbiti 500,00 DH ✓"; "Li b9a" f P4 kaynqs b 500.
3. Jbed: P12 → "Jbed" → 200 → "Sjel" → toast "Jbedti 200,00 DH mn Dwayr zman". Ila l mablagh kter mn sold: "Ma 3ndekch had l mablagh f Dwayr zman".

## 8. Nsous dyal l interface (Microcopy b Arabizi)

### Glossaire (validé)

Kelma wa7da l kol ma3na; qa3ida: **9** dima f blast q. Nfs l lista f `mockups/GLOSSAIRE.md`.

| Ma3na | Kelma |
| --- | --- |
| Ajouter / Modifier / Supprimer | **Zid** / **3dl** / **Msse7** |
| Enregistrer / Annuler / Undo | **Sjel** / **Lghi** / **Rje3** |
| Oui / Non / Envoyer | **Iyeh** / **La** / **Sift** |
| Rechercher / Choisir / Voir tout | **9elleb** / **Khtar** / **Chouf kolchi** |
| Cacher categorie jahza | **Ma tbanch** |
| Login / Inscription / Logout | **Dkhol** / **T9eyd** / **Khrej** |
| Onglets | **Ra2issya** · **Lmo3amalat** · **Ar9am** · **7sabi** |
| Détails | **Tafasil** |
| Transaction / Dépense / Revenu | **Mo3amala** / **Masrouf** / **Dakhl** |
| Catégorie / par défaut | **Categorie** / **Jahza** |
| Montant / Date / Note | **Mablagh** / **Tarikh** / **Molahada** |
| Ce qui reste | **Li b9a** |
| Mois / aujourd'hui / hier | **Chher** / **Lyoum** / **Lbare7** |
| Épargne / Objectif | **Dwayr zman** / **Lhadaf** |
| Mettre de côté / Retirer | **Khbi** / **Jbed** |
| Mode sombre | **Loun dyal système** |

### Messages

| Blasa | Nass |
| --- | --- |
| Toast masrouf | "Khlesti {mablagh} DH f {categorie} ✓" |
| Toast dakhl | "Tzadt lik {mablagh} DH ✓" |
| Carte home | "Li b9a lik had chher: {x} DH" |
| Li b9a salbi | "Fatti dakchi li khassek tsref b {x} DH ⚠️" |
| Liste khawya | "Mazal ma zdti walou. Brek 3la + bach tbda" |
| Mablagh ghalat | "Kteb mablagh s7i7 (kter mn 0)" |
| Categorie mafihash | "Khtar categorie" |
| Confirmation msse7 | "Bghiti tmse7 had l mo3amala?" — "Iyeh" / "La" |
| Sync ok | "Msynchronizi ✓" |
| Offline | "Bla internet — ghadi nsynchronizi mlli trje3 connexion" |
| Login ghalat | "Email wla mot de passe ghalat" |
| Email deja kayn | "Had l email 3ndo deja compte" |
| Popup akhir chher | "Shat lik {x} DH f {chher}. N7ttohom f Dwayr zman?" — "Iyeh, khbihom" / "La" |
| Toast khbi / jbed | "Khbiti {x} DH ✓" / "Jbedti {x} DH mn Dwayr zman" |
| Jbed kter mn sold | "Ma 3ndekch had l mablagh f Dwayr zman" |

## 9. Mtatallabat ghir wadifiya (Non-functional)

- **Performance**: l app tfte7 f ≤ 2 tawani; liste dyal 1000 mo3amala tscrolli bla t9ل.
- **Amn**: mots de passe ma kaytsjlouch f l appareil; kol user ychouf ghir data dyalo (règles d'accès f l cloud 3la user\_id); HTTPS.
- **Offline**: kolchi khddam bla internet ghir auth.
- **Accessibilité**: boutons ≥ 48 px, contraste mzyan, taille dyal l khatt t9der tkbar.
- **Plateformes**: Android 8+ o iOS 15+.

## 10. Choix tqniya mqtar7a (bla code)

- **Frontend**: Flutter (codebase wa7ed l Android o iOS).
- **Backend / Cloud DB**: Firebase (Authentication b email + Cloud Firestore m3a offline persistence) — kaygiw b sync o offline jahzin. Alternative: Supabase.
- **Graphe**: library dyal charts f Flutter (b7al fl\_chart).
- **State management**: Riverpod wla Bloc — khtar wa7ed o b9a 3lih.

## 11. Critères d'acceptation (Definition of done)

- [ ] User y9der ycréer compte, ydkhol, ykhrej, o y reset mot de passe.
- [ ] Zid / 3dl / Msse7 masrouf o dakhl b mablagh, categorie, tarikh, molahada.
- [ ] 5 categories jahza dyal masarif + 2 dyal dakhl kaynin mn l bdya.
- [ ] User y9der yzid, y3dl, ymse7 categorie dyalo.
- [ ] Graphe barres masarif vs dakhl 6 chhour + "Li b9a" s7i7 (testé b ar9am ma3roufa).
- [ ] T3dil f appareil A kaybán f appareil B.
- [ ] Tzid masrouf offline → kaytsynchroni mlli yrj3 l internet.
- [ ] Ga3 l pages P1–P11 + P3b + P8b mwssoulin kima f l9ism 6.
- [ ] Ga3 nsous b Darija Arabizi; ta nass b l'anglais ma b9a.

* [ ] Dwayr zman: khbi, jbed, hadaf, popup "Shat lik" o mode automatique khddamin, o "Li b9a" kayt7sseb b qa3ida dyal F7.

## 12. Tartib dyal l khdma (Roadmap mqtar7)

1. **Sprint 1**: Setup Flutter + Firebase, auth (P1–P3b).
2. **Sprint 2**: Data model, CRUD mo3amalat (P4–P7), categories jahza.
3. **Sprint 3**: Categories dyal l user (P9–P10), Profil (P11), sync + offline.
4. **Sprint 4**: Ta7lil (P8–P8b), microcopy, mode sombre, tests o publication f stores.

## 13. Mxatir o noqat khassek tqrrer fihom

- **Arabizi machi standard**: glossaire t9arrer (l9ism 8). Ay nass jdid khasso ytba3o, wla l interface ghadi tban mkhrbqa.
- **Firebase gratuit 3ndo limites**: mzyan l V1, walakin 7sseb l coût ila kber 3dad users.
- **Last-write-wins** y9der ydi3 t3dil ila t3dlat nfs l mo3amala f 2 appareils offline f nfs l wa9t — risque mqboul f V1.
- **Bla budgets**, l app katwsef chnou w9e3 walakin ma kat7bsekch — hada howa l feature lwla f V2.
