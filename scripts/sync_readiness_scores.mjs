/**
 * sync_readiness_scores.mjs
 *
 * Repair script: re-derives users/{uid}.lastReadinessScore + lastSessionAt
 * for every user from their actual most-recent pre_training doc (or nulls
 * both out if they have none). Fixes staleness left over from before
 * AdminFirebaseService started auto-syncing these fields on session
 * edit/delete — safe to re-run any time, it's idempotent.
 *
 * Run: node scripts/sync_readiness_scores.mjs
 * Requires: scripts/serviceAccountKey.json OR GOOGLE_APPLICATION_CREDENTIALS
 */

import { initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { readFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

let credential;
const keyPath = join(__dirname, 'serviceAccountKey.json');
if (existsSync(keyPath)) {
  credential = cert(JSON.parse(readFileSync(keyPath, 'utf8')));
  console.log('✓ Using service account key');
} else {
  credential = applicationDefault();
  console.log('✓ Using Application Default Credentials');
}

initializeApp({ credential, projectId: 'tr-athletic-development' });
const db = getFirestore();

async function main() {
  const usersSnap = await db.collection('users').get();
  let fixed = 0;
  let unchanged = 0;

  for (const userDoc of usersSnap.docs) {
    const uid = userDoc.id;
    const data = userDoc.data();

    const preSnap = await db
      .collection('pre_training')
      .where('uid', '==', uid)
      .orderBy('createdAt', 'desc')
      .limit(1)
      .get();

    let newScore = null;
    let newSessionAt = null;
    if (!preSnap.empty) {
      const latest = preSnap.docs[0].data();
      newScore = latest.readinessToTrain;
      newSessionAt = latest.createdAt;
    }

    const currentScore = data.lastReadinessScore ?? null;
    const currentSessionAtMs = data.lastSessionAt ? data.lastSessionAt.toMillis() : null;
    const newSessionAtMs = newSessionAt ? newSessionAt.toMillis() : null;

    if (currentScore === newScore && currentSessionAtMs === newSessionAtMs) {
      unchanged++;
      continue;
    }

    await userDoc.ref.update({
      lastReadinessScore: newScore,
      lastSessionAt: newSessionAt,
    });
    fixed++;
    console.log(
      `  fixed ${data.email ?? uid}: lastReadinessScore ${currentScore} -> ${newScore}`
    );
  }

  console.log(`\nDone. Fixed ${fixed}, already correct ${unchanged}, total ${usersSnap.size}.`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('❌ Error:', err);
    process.exit(1);
  });
