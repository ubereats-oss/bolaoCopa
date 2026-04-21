// seed_jogadores_excel.js
// Lê jogadores_copa2026.xlsx e popula cups/2026/players no Firestore.
// Coloque este arquivo e o xlsx na pasta seed/ antes de executar.
// Executar: node seed_jogadores_excel.js

const admin = require('firebase-admin');
const sa = require('./serviceAccountKeyBolao.json');
const XLSX = require('xlsx');
const path = require('path');

admin.initializeApp({ credential: admin.credential.cert(sa) });
const db = admin.firestore();

const CUP_ID = '2026';
const ARQUIVO = path.join(__dirname, 'jogadores_copa2026.xlsx');

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function seed() {
  console.log('Lendo arquivo Excel...');
  const wb = XLSX.readFile(ARQUIVO);
  const ws = wb.Sheets[wb.SheetNames[0]];
  const linhas = XLSX.utils.sheet_to_json(ws);

  console.log(`Total de jogadores encontrados: ${linhas.length}`);

  const playersRef = db.collection('cups').doc(CUP_ID).collection('players');

  // Apaga todos os jogadores existentes antes de inserir
  console.log('Apagando jogadores existentes...');
  const existentes = await playersRef.get();
  for (const doc of existentes.docs) {
    await doc.ref.delete();
  }
  console.log(`${existentes.size} jogadores removidos.`);

  // Insere em lotes de 20
  let total = 0;
  for (const linha of linhas) {
    const teamId = String(linha['team_id'] || '').trim().toLowerCase();
    const name   = String(linha['name'] || '').trim();
    const pos    = String(linha['position'] || '').trim();
    const res    = String(linha['reserva'] || '').trim().toLowerCase();

    if (!teamId || !name || !pos) {
      console.warn('Linha ignorada (dados incompletos):', linha);
      continue;
    }

    await playersRef.add({
      name,
      team_id: teamId,
      position: pos,
      number: parseInt(linha['number']) || 0,
      reserva: res === 'true' || res === '1' || res === 'verdadeiro',
    });

    total++;
    if (total % 50 === 0) {
      console.log(`  ${total} jogadores inseridos...`);
      await sleep(300); // evita rate limit do Firestore
    }
  }

  console.log(`\nConcluido! ${total} jogadores inseridos no Firestore.`);
  process.exit(0);
}

seed().catch((err) => {
  console.error('Erro:', err);
  process.exit(1);
});
