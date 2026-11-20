/// Ga3 nsous dyal l app b Darija Arabizi — tba3 mockups/GLOSSAIRE.md.
/// Bddel kelma hna o kat tbddel f l app kamla.
class S {
  S._();

  static const appName = 'Masarif';
  static const tagline = '3ref fin kaymchiw flousek,\nb dirham o b darija.';
  static const loading = 'Kaychargi…';

  // Actions
  static const add = 'Zid';
  static const edit = '3dl';
  static const delete = 'Msse7';
  static const save = 'Sjel';
  static const saveEdit = 'Sjel t3dil';
  static const cancel = 'Lghi';
  static const undo = 'Rje3';
  static const yes = 'Iyeh';
  static const no = 'La';
  static const send = 'Sift';
  static const search = '9elleb f molahada…';
  static const seeAll = 'Chouf kolchi';
  static const hide = 'Ma tbanch';

  // Auth
  static const login = 'Dkhol';
  static const signup = 'T9eyd db';
  static const logout = 'Khrej';
  static const deleteAccount = 'Msse7 l compte';
  static const deleteAccountTitle = 'Bghiti tmse7 l compte dyalk?';
  static const deleteAccountBody =
      'Ghadi ytmsa7 kolchi: l mo3amalat, categories o Dwayr zman. Ma t9derch trje3hom. Kteb l mot de passe bach t2akked.';
  static const deleteAccountDone = 'Tmse7 l compte dyalk';
  static const slogan = 'Kol dirham\n3ndo blasto.';
  static const loginSub = '3ref fin kaymchiw flousek, o khbi li b9a l Dwayr zman.';
  static const verifySent = 'Siftna lik email bach t2akked l compte ✓';
  static const verifyBanner = 'Akked l email dyalk: chouf l boîte (o spam).';
  static const verifyResend = '3awd sift';
  static const signupSub = 'Compte wa7ed, data dyalk f telephone o tablette b7al b7al.';
  static const email = 'Email';
  static const password = 'Mot de passe';
  static const password2 = '3awd kteb mot de passe';
  static const name = 'Smiya';
  static const forgot = 'Nsit l mot de passe?';
  static const forgotSub = 'Machi mochkil. Kteb l email dyal compte dyalk o ghadi nsifto lik lien bach tbddel l mot de passe.';
  static const forgotSent = 'Siftna lik email ✓';
  static const forgotSentSub = 'Chouf l boîte dyalk (o spam). Mn ba3d rj3 tdkhol b l mot de passe jdid.';
  static const noAccount = 'Ma3ndkch compte?';
  static const haveAccount = '3ndk compte?';
  static const backToLogin = 'Rje3 l dkhoul';
  static const passMin = '8 7rouf 3la l a9al';
  static const passMismatch = 'Jouj mots de passe machi b7al b7al';
  static const badLogin = 'Email wla mot de passe ghalat';
  static const emailExists = 'Had l email 3ndo deja compte';
  static const badEmail = 'Kteb email s7i7';
  static const required = 'Had l khana khassha tt3mmer';

  // Tabs
  static const tabHome = 'Ra2issya';
  static const tabTx = 'Lmo3amalat';
  static const tabStats = 'I7sa2iyat';
  static const tabProfile = '7sabi';

  // Data
  static const expense = 'Masrouf';
  static const expenses = 'Masarif';
  static const income = 'Dakhl';
  static const all = 'Kolchi';
  static const amount = 'Mablagh';
  static const category = 'Categorie';
  static const categories = 'Categories';
  static const date = 'Tarikh';
  static const note = 'Molahada';
  static const noteHint = 'ikhtiyari';
  static const today = 'Lyoum';
  static const yesterday = 'Lbare7';
  static const details = 'Tafasil';
  static const leftThisMonth = 'Li b9a lik had chher';
  static const left = 'Li b9a';
  static const recent = 'Akhir mo3amalat';
  static const addTx = 'Zid mo3amala';
  static const editTx = '3dl l mo3amala';
  static const defaultCat = 'Jahza';
  static const mine = 'Dyali';
  static const icon = 'Icone';
  static const color = 'Loun';
  static const type = 'Naw3';
  static const editCat = '3dl categorie';
  static const addCat = 'Zid categorie';
  static const themeTitle = 'Loun';
  static const themeLight = 'Loun fat7';
  static const themeDark = 'Loun gham9';
  static const themeSystem = 'Tab3 l telephone';
  static const themeSub = 'Mode clair / sombre';
  static const pickTheme = 'Khtar ach men loun bghiti';
  static String spentPct(int p) => 'Khsserti $p% mn dakchi li dkhel lik had chher';

  // Stats
  static const vs = 'Masarif vs dakhl';
  static const last6 = '6 chhour lkhrin';
  static const topCats = 'Top categories';
  static const tapMonth = 'Brek 3la chi chher bach tchouf tafasil dyalo';

  // Dwayr zman
  static const savings = 'Dwayr zman';
  static const savingsBalance = 'Sold kamel';
  static const goal = 'Lhadaf';
  static const changeGoal = 'Bddel l hadaf';
  static const put = 'Khbi';
  static const take = 'Jbed';
  static const moves = 'L harakat';
  static const savingsAuto = 'Dwayr zman automatique';
  static const savingsAutoSub = 'Khbi li shat f kol chher bla ma nsowlek';
  static const savingsNote = '"Li b9a" dyal had chher ghadi ytbddel. Had l flous ma kayt7sbouch f masarif.';
  static const putManual = 'Khbi b yeddi';
  static const autoTag = 'automatique';
  static const yesPut = 'Iyeh, khbihom';
  static const doAuto = 'Dir had l khdma automatiquement';
  static const notEnough = 'Ma 3ndekch had l mablagh f Dwayr zman';
  static const noGoal = 'Ma 3ndekch hadaf. Zid wa7ed bach tchouf ta9addom.';

  // Messages
  static String toastExpense(String a, String cat) => 'Khlesti $a f $cat ✓';
  static String toastIncome(String a) => 'Tzadt lik $a ✓';
  static String negative(String x) => 'Fatti dakchi li khassek tsref b $x ⚠️';
  static const empty = 'Mazal ma zdti walou. Brek 3la + bach tbda';
  static const synced = 'Msynchronizi ✓';
  static const offline = 'Bla internet — ghadi nsynchronizi mlli trje3 connexion';
  static const badAmount = 'Kteb mablagh s7i7 (kter mn 0)';
  static const pickCat = 'Khtar categorie';
  static const confirmDelete = 'Bghiti tmse7 had l mo3amala?';
  static const deleted = 'Tmse7';
  static const updated = 'Tbddlat ✓';
  static String toastPut(String a) => 'Khbiti $a ✓';
  static String toastTake(String a) => 'Jbedti $a mn Dwayr zman';
  static String popupTitle(String x, String month) => 'Shat lik $x f $month';
  static const popupBody = 'N7ttohom f Dwayr zman?';
  static const catDeleteNote = 'Categories jahza ma kaytms7ouch, walakin t9der ma tbanhomch. Ila msse7ti categorie dyalk, l mo3amalat dyalha kaymchiw l "Okhra".';
  // ─── V2
  static const leftCaps = 'LI B9A LIK';
  static const hideAmount = 'Khbi l mablagh';
  static const showAmount = 'Werri l mablagh';
  static const notifications = 'Tanbihat';
  static const markAllRead = '9rit kolchi';
  static const newNotifs = 'JDAD';
  static const oldNotifs = '9DAM';
  static const noNotifs = 'Ma kayn ta tanbih daba.';
  static const otherCat = 'Haja akhra';
  static const whereSpent = 'Fin khlesti?';
  static const whereFrom = 'Mnin dkhel?';
  static const spentCaps = 'KHLESTI';
  static const gotCaps = 'DKHEL LIK';
  static const howMuchPut = 'CH7AL BGHITI TKHBI?';
  static const howMuchTake = 'CH7AL BGHITI TJBED?';
  static const goalCaps = 'LHADAF DYALK';
  static const savingsFull = 'Dwayr zman kaynin…\no nta wajed.';
  static const savingsEmpty = 'Ash katsena mazal, dir 3lash terj3';

  /// Message dyal carte Dwayr zman 3la 7sab ch7al wselti mn l hadaf.
  /// [goal] null = ma kaynch hadaf.
  static String savingsMessage(double balance, double? goal) {
    if (balance <= 0) return savingsEmpty;
    if (goal == null || goal <= 0) return 'Bditi mzyan…\n7tt hadaf bach tchouf fin wasel.';
    final p = balance / goal * 100;
    if (p >= 100) return savingsFull;
    if (p >= 80) return 'Ba9i ghir chwiya…\nrak qrib bzaf!';
    if (p >= 60) return 'Kter mn ness…\nl hadaf kayqreb.';
    if (p >= 40) return 'Wselti l ness…\nma t7bessch daba.';
    if (p >= 20) return 'Rak f triq…\nkmel b had l7al.';
    return 'Bditi…\nkol dirham kayt7seb.';
  }
  static const periodThis = 'Had chher';
  static const periodLast = 'Chher li fat';
  static const periodAll = 'Kolchi';
  static const filter = 'Filtre';
  static const week = 'Simana';
  static const month = 'Chher';
  static const year = '3am';
  static const thisWeekSpent = 'HAD SIMANA · MASARIF';
  static const thisMonthSpent = 'HAD CHHER · MASARIF';
  static const thisYearSpent = 'HAD L3AM · MASARIF';
  static const byCategory = 'B CATEGORIE';
  static const changePhoto = 'Bddel tswira';
  static const nameEmail = 'Smiya o email';
  static const themeShortLight = 'Fat7';
  static const themeShortDark = 'Gham9';
  static const later = 'La, mn b3d';
  static const income2 = 'Dkhel';
  static const expense2 = 'Khrej';
  static const saved2 = 'Khbiti';
  static const leftInMonth = 'LI B9A F HAD CHHER';
  static String biggestDay(String day, String amount) => 'Nhar $day kan akbar nhar · $amount';
  static String lessThan(int p) => '↘ $p% 9el';
  static String moreThan(int p) => '↗ $p% kter';
  static String saveBtn(String a) => 'Khbi $a';
  static String takeBtn(String a) => 'Jbed $a';
  static String addBtn(String a, String cat) => 'Sjel $a f $cat';
}

const monthNames = [
  'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
];
const monthShort = ['Jan', 'Fév', 'Mars', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'];
