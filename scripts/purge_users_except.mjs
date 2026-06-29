/**
 * purge_users_except.mjs
 *
 * Deletes ALL Firestore users/{uid} docs + their pre_training/post_training
 * docs + their Firebase Auth accounts, EXCEPT:
 *   - the uid in KEEP_UID below
 *   - any user whose Firestore `role` field === 'admin'
 *
 * Safety:
 *   - Defaults to DRY RUN — prints exactly what would happen, deletes nothing.
 *   - Pass --confirm to actually delete.
 *   - Before deleting anything, writes a full JSON backup of every doc about
 *     to be removed to scripts/backups/purge-backup-<timestamp>.json.
 *   - Auth accounts that have NO matching Firestore users/ doc are reported
 *     separately and are NOT auto-deleted (can't classify them as admin/keep).
 *
 * Run (preview):  node scripts/purge_users_except.mjs
 * Run (for real): node scripts/purge_users_except.mjs --confirm
 * Requires: scripts/serviceAccountKey.json OR GOOGLE_APPLICATION_CREDENTIALS
 */

import {
  initializeApp,
  cert,
  applicationDefault,
} from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import { readFileSync, existsSync, mkdirSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

const KEEP_UID = 'PrDzlpC3YXhpizfytfZstSpmuFC3';
const KEEP_EMAIL = 'bkrashrf160@gmail.com';

const DRY_RUN = !process.argv.includes('--confirm');

// ── Init firebase-admin ───────────────────────────────────────────────────────

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
const auth = getAuth();

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  console.log(
    DRY_RUN
      ? '\n*** DRY RUN — nothing will be deleted. Re-run with --confirm to actually delete. ***\n'
      : '\n*** LIVE RUN — deleting for real. ***\n'
  );

  const usersSnap = await db.collection('users').get();
  const usersById = new Map(usersSnap.docs.map((d) => [d.id, d.data()]));

  const keep = [];
  const toDelete = [];

  for (const doc of usersSnap.docs) {
    const data = doc.data();
    const isKeptUid = doc.id === KEEP_UID;
    const isAdmin = data.role === 'admin';
    if (isKeptUid || isAdmin) {
      keep.push({
        uid: doc.id,
        email: data.email,
        role: data.role,
        reason: isKeptUid ? 'kept-uid' : 'admin',
      });
    } else {
      toDelete.push({ uid: doc.id, email: data.email, role: data.role });
    }
  }

  if (!usersById.has(KEEP_UID)) {
    console.warn(
      `\n⚠ WARNING: kept uid ${KEEP_UID} has NO Firestore users/ doc. ` +
        `Double check this is the right uid before continuing.\n`
    );
  } else if (usersById.get(KEEP_UID).email !== KEEP_EMAIL) {
    console.warn(
      `\n⚠ WARNING: uid ${KEEP_UID} has email "${usersById.get(KEEP_UID).email}" ` +
        `which does NOT match the expected "${KEEP_EMAIL}". Keeping by uid anyway — verify this is correct.\n`
    );
  }

  // Auth accounts with no corresponding Firestore users/ doc — can't be
  // classified as admin/kept, so they're reported but never auto-deleted.
  const orphanAuthUsers = [];
  let pageToken;
  do {
    const page = await auth.listUsers(1000, pageToken);
    for (const u of page.users) {
      if (!usersById.has(u.uid) && u.uid !== KEEP_UID) {
        orphanAuthUsers.push({ uid: u.uid, email: u.email });
      }
    }
    pageToken = page.pageToken;
  } while (pageToken);

  console.log(`Total Firestore users: ${usersSnap.size}`);
  console.log(`\nKeeping ${keep.length}:`);
  keep.forEach((u) => console.log(`   KEEP    ${u.uid}  ${u.email}  (${u.reason})`));
  console.log(`\nDeleting ${toDelete.length}:`);
  toDelete.forEach((u) => console.log(`   DELETE  ${u.uid}  ${u.email}  role=${u.role ?? '(none)'}`));

  if (orphanAuthUsers.length) {
    console.log(
      `\n⚠ Found ${orphanAuthUsers.length} Auth account(s) with NO Firestore users/ doc (NOT auto-deleted, review manually):`
    );
    orphanAuthUsers.forEach((u) => console.log(`   ORPHAN  ${u.uid}  ${u.email}`));
  }

  if (toDelete.length === 0) {
    console.log('\nNothing to delete. Done.');
    return;
  }

  // ── Backup + delete ─────────────────────────────────────────────────────────

  const backup = [];
  let totalPre = 0;
  let totalPost = 0;

  console.log('');
  for (const u of toDelete) {
    const preSnap = await db.collection('pre_training').where('uid', '==', u.uid).get();
    const postSnap = await db.collection('post_training').where('uid', '==', u.uid).get();
    totalPre += preSnap.size;
    totalPost += postSnap.size;

    backup.push({
      user: { id: u.uid, ...usersById.get(u.uid) },
      preTraining: preSnap.docs.map((d) => ({ id: d.id, ...d.data() })),
      postTraining: postSnap.docs.map((d) => ({ id: d.id, ...d.data() })),
    });

    console.log(
      `  ${u.email}: ${preSnap.size} pre_training, ${postSnap.size} post_training doc(s)`
    );

    if (!DRY_RUN) {
      let batch = db.batch();
      [...preSnap.docs, ...postSnap.docs].forEach((d) => batch.delete(d.ref));
      batch.delete(db.collection('users').doc(u.uid));
      await batch.commit();
      try {
        await auth.deleteUser(u.uid);
      } catch (e) {
        console.warn(`   could not delete Auth user ${u.uid}: ${e.message}`);
      }
      console.log(`   ✓ deleted ${u.email}`);
    }
  }

  // Write the backup file even on dry runs, so you can inspect exactly what
  // would be captured before re-running with --confirm.
  const backupDir = join(__dirname, 'backups');
  mkdirSync(backupDir, { recursive: true });
  const backupPath = join(
    backupDir,
    `purge-backup-${new Date().toISOString().replace(/[:.]/g, '-')}.json`
  );
  writeFileSync(backupPath, JSON.stringify(backup, null, 2));
  console.log(`\nBackup written: ${backupPath}`);

  console.log(
    `\nTotals: ${toDelete.length} user(s), ${totalPre} pre_training doc(s), ${totalPost} post_training doc(s)` +
      `${DRY_RUN ? ' would be deleted (dry run, nothing touched).' : ' deleted.'}`
  );
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('❌ Error:', err);
    if (err.code === 7 || err.message?.includes('PERMISSION_DENIED')) {
      console.error('\n⚠ Permission denied. You need a service account key.');
      console.error('  1. Go to: https://console.firebase.google.com/project/tr-athletic-development/settings/serviceaccounts');
      console.error('  2. Click "Generate new private key"');
      console.error('  3. Save the file as: scripts/serviceAccountKey.json');
      console.error('  4. Re-run this script.');
    }
    process.exit(1);
  });
