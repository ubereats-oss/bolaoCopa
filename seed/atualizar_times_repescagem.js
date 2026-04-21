// atualizar_times_repescagem.js
// Atualiza home_team_id e away_team_id nos jogos que ainda referenciam
// os placeholders das repescagens, substituindo pelo codigo FIFA correto.
// Executar na pasta seed/: node atualizar_times_repescagem.js

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKeyBolao.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const CUP_ID = '2026';

const SUBSTITUICOES = {
  euroa: 'TUR',
  eurob: 'SWE',
  euroc: 'CZE',
  eurod: 'BIH',
  intc1: 'COD',
  intc2: 'IRQ',
};

async function atualizarJogos() {
  let totalAtualizados = 0;

  // Jogos de grupos
  console.log('Verificando jogos de grupos...');
  const groupsSnap = await db
    .collection('cups')
    .doc(CUP_ID)
    .collection('groups')
    .get();

  for (const groupDoc of groupsSnap.docs) {
    const matchesSnap = await groupDoc.ref.collection('matches').get();
    for (const matchDoc of matchesSnap.docs) {
      const data = matchDoc.data();
      const update = {};

      if (SUBSTITUICOES[data.home_team_id]) {
        update.home_team_id = SUBSTITUICOES[data.home_team_id];
      }
      if (SUBSTITUICOES[data.away_team_id]) {
        update.away_team_id = SUBSTITUICOES[data.away_team_id];
      }

      if (Object.keys(update).length > 0) {
        await matchDoc.ref.update(update);
        console.log(`  Grupo ${groupDoc.id} | ${matchDoc.id} ->`, update);
        totalAtualizados++;
      }
    }
  }

  // Jogos do mata-mata
  console.log('Verificando jogos do mata-mata...');
  const knockoutSnap = await db
    .collection('cups')
    .doc(CUP_ID)
    .collection('knockout_matches')
    .get();

  for (const matchDoc of knockoutSnap.docs) {
    const data = matchDoc.data();
    const update = {};

    if (SUBSTITUICOES[data.home_team_id]) {
      update.home_team_id = SUBSTITUICOES[data.home_team_id];
    }
    if (SUBSTITUICOES[data.away_team_id]) {
      update.away_team_id = SUBSTITUICOES[data.away_team_id];
    }

    if (Object.keys(update).length > 0) {
      await matchDoc.ref.update(update);
      console.log(`  Mata-mata | ${matchDoc.id} ->`, update);
      totalAtualizados++;
    }
  }

  console.log(`\nConcluido! ${totalAtualizados} jogo(s) atualizado(s).`);
  process.exit(0);
}

atualizarJogos().catch((err) => {
  console.error('Erro:', err);
  process.exit(1);
});
