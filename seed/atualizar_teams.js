const admin = require('firebase-admin');
const sa = require('./serviceAccountKeyBolao.json');
admin.initializeApp({ credential: admin.credential.cert(sa) });
const db = admin.firestore();
const ref = db.collection('cups').doc('2026').collection('teams');
const subs = [
  ['euroa', 'TUR', 'Turquia'],
  ['eurob', 'SWE', 'Suecia'],
  ['euroc', 'CZE', 'Republica Tcheca'],
  ['eurod', 'BIH', 'Bosnia e Herzegovina'],
  ['intc1', 'COD', 'Rep. Dem. do Congo'],
  ['intc2', 'IRQ', 'Iraque'],
];
(async () => {
  for (const [antigo, novo, nome] of subs) {
    await ref.doc(antigo).delete();
    await ref.doc(novo).set({ name: nome });
    console.log('OK:', antigo, '->', novo, '(' + nome + ')');
  }
  console.log('Concluido!');
  process.exit(0);
})();
