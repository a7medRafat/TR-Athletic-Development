/**
 * seed_test_data.mjs
 * 1. Deletes all Firestore users + their pre/post training docs EXCEPT the admin.
 * 2. Creates 3 realistic test users (approved) with 30 days of pre+post training data.
 *
 * Run: node scripts/seed_test_data.mjs
 * Requires: GOOGLE_APPLICATION_CREDENTIALS env var OR firebase-admin with ADC
 */

import {
  initializeApp,
  cert,
  applicationDefault,
} from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import { readFileSync, existsSync } from 'fs';
import { execSync } from 'child_process';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

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

const db   = getFirestore();
const auth = getAuth();

// ── Helpers ───────────────────────────────────────────────────────────────────

const rand  = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
const randF = (min, max, dp = 1) => parseFloat((Math.random() * (max - min) + min).toFixed(dp));

function daysAgo(n) {
  const d = new Date();
  d.setDate(d.getDate() - n);
  d.setHours(8, rand(0, 59), 0, 0);
  return Timestamp.fromDate(d);
}

function postTimestamp(n) {
  const d = new Date();
  d.setDate(d.getDate() - n);
  d.setHours(18, rand(0, 59), 0, 0);
  return Timestamp.fromDate(d);
}

/** Delete all docs in a collection in batches */
async function deleteCollection(colRef, batchSize = 400) {
  const snap = await colRef.get();
  if (snap.empty) return;
  let batch = db.batch();
  let count = 0;
  for (const doc of snap.docs) {
    batch.delete(doc.ref);
    count++;
    if (count % batchSize === 0) {
      await batch.commit();
      batch = db.batch();
    }
  }
  if (count % batchSize !== 0) await batch.commit();
}

// ── Step 1: remove all non-admin users ───────────────────────────────────────

async function purgeNonAdminUsers() {
  console.log('\n── Step 1: purging non-admin users ──');

  const usersSnap = await db.collection('users').get();
  const adminUids = new Set();

  // Identify admins first
  for (const doc of usersSnap.docs) {
    if (doc.data().role === 'admin') {
      adminUids.add(doc.id);
      console.log(`  ↳ Keeping admin: ${doc.data().email} (${doc.id})`);
    }
  }

  const toDelete = usersSnap.docs.filter(d => !adminUids.has(d.id));
  console.log(`  ↳ Deleting ${toDelete.length} non-admin user(s) from Firestore…`);

  for (const doc of toDelete) {
    const uid = doc.id;

    // Delete sub-collections (pre/post training)
    const preSnap  = await db.collection('pre_training').where('uid', '==', uid).get();
    const postSnap = await db.collection('post_training').where('uid', '==', uid).get();

    let batch = db.batch();
    [...preSnap.docs, ...postSnap.docs].forEach(d => batch.delete(d.ref));
    batch.delete(doc.ref);
    await batch.commit();

    // Delete from Firebase Auth
    try { await auth.deleteUser(uid); } catch (_) {}
    console.log(`  ✓ Deleted: ${doc.data().email}`);
  }

  console.log('  Step 1 done.\n');
}

// ── Step 2: create 3 test users with 30-day data ─────────────────────────────

const TEST_USERS = [
  {
    email:    'khalid.sport@tr-test.com',
    password: 'Test@1234',
    fullName: 'خالد العمري',
    age: 24, weight: 78, height: 178, gender: 'Male',
    // Athlete profile: high performer, consistent, rare pain
    profile: 'athlete',
  },
  {
    email:    'sara.rehab@tr-test.com',
    password: 'Test@1234',
    fullName: 'سارة المطيري',
    age: 22, weight: 62, height: 165, gender: 'Female',
    // Rehab profile: ongoing injury, lower readiness, moderate fatigue
    profile: 'rehab',
  },
  {
    email:    'faisal.rookie@tr-test.com',
    password: 'Test@1234',
    fullName: 'فيصل الغامدي',
    age: 19, weight: 85, height: 182, gender: 'Male',
    // Rookie profile: inconsistent, high variability
    profile: 'rookie',
  },
];

function generatePreTraining(uid, dayAgo, profile) {
  let sleep, fatigue, soreness, mood, stress, energy, pain;

  // sleepQuality is 1-5 scale; mood is now 1-10; all others 1-10
  let sleepQuality;
  if (profile === 'athlete') {
    sleepQuality = rand(4, 5);    // 1-5
    sleep        = rand(7, 9);    // hours
    fatigue      = rand(1, 4);
    soreness     = rand(1, 3);
    mood         = rand(7, 10);   // 1-10
    stress       = rand(1, 3);
    energy       = rand(7, 10);
    pain         = Math.random() < 0.08;
  } else if (profile === 'rehab') {
    sleepQuality = rand(2, 3);    // 1-5
    sleep        = rand(5, 7);
    fatigue      = rand(4, 7);
    soreness     = rand(5, 8);
    mood         = rand(3, 6);    // 1-10
    stress       = rand(4, 7);
    energy       = rand(3, 6);
    pain         = Math.random() < 0.55;
  } else { // rookie
    sleepQuality = rand(3, 4);    // 1-5
    sleep        = rand(5, 9);
    fatigue      = rand(2, 7);
    soreness     = rand(2, 6);
    mood         = rand(5, 8);    // 1-10
    stress       = rand(2, 6);
    energy       = rand(4, 8);
    pain         = Math.random() < 0.2;
  }

  const hoursOfSleep = randF(sleep - 0.5, sleep + 0.5);

  // Mirror ReadinessCalculator.calculate() in Dart exactly (returns 1-10)
  let score = 0;
  score += (Math.min(hoursOfSleep, 8) / 8) * 20;           // sleep hours    0-20
  score += ((sleepQuality - 1) / 4) * 5;                    // sleep quality  0-5  (1-5 scale)
  score += ((energy - 1) / 9) * 20;                         // energy         0-20
  score += ((10 - fatigue) / 9) * 20;                       // fatigue inv    0-20
  score += ((10 - soreness) / 9) * 15;                      // soreness inv   0-15
  score += ((mood - 1) / 9) * 10;                           // mood           0-10 (1-10 scale)
  score += ((10 - stress) / 9) * 10;                        // stress inv     0-10
  if (pain) score -= 10;                                     // pain penalty
  const readiness = Math.min(10, Math.max(1, Math.round(score / 10)));

  return {
    uid,
    sleepQuality,
    hoursOfSleep,
    fatigueLevel:    fatigue,
    muscleSoreness:  soreness,
    mood,
    stressLevel:     stress,
    energyLevel:     energy,
    hasPainOrInjury: pain,
    painLocation:    pain ? (profile === 'rehab' ? 'الركبة اليمنى' : 'أسفل الظهر') : null,
    readinessToTrain: readiness,
    createdAt:       daysAgo(dayAgo),
  };
}

function generatePostTraining(uid, dayAgo, profile) {
  let rpe, completed, feltPain, injury, fatigue, duration;

  if (profile === 'athlete') {
    rpe       = rand(6, 9);   // max 9
    completed = Math.random() < 0.92;
    feltPain  = Math.random() < 0.1;
    injury    = false;
    fatigue   = rand(3, 5);
    duration  = rand(75, 110);
  } else if (profile === 'rehab') {
    rpe       = rand(4, 7);   // max 9
    completed = Math.random() < 0.65;
    feltPain  = Math.random() < 0.6;
    injury    = Math.random() < 0.05;
    fatigue   = rand(3, 5);
    duration  = rand(40, 70);
  } else {
    rpe       = rand(5, 8);   // max 9
    completed = Math.random() < 0.75;
    feltPain  = Math.random() < 0.2;
    injury    = false;
    fatigue   = rand(3, 5);
    duration  = rand(50, 90);
  }

  return {
    uid,
    rpe,
    completedWorkout: completed,
    feltPain,
    painLocation: feltPain ? 'أسفل الظهر' : null,
    injury,
    fatigue,
    notes: null,
    trainingDuration: duration,
    createdAt: postTimestamp(dayAgo),
  };
}

async function seedTestUsers() {
  console.log('── Step 2: creating 3 test users with 60-day data ──');

  for (const u of TEST_USERS) {
    // Create or get Firebase Auth user
    let uid;
    try {
      const existing = await auth.getUserByEmail(u.email);
      uid = existing.uid;
      console.log(`  ↳ Auth user already exists: ${u.email}`);
    } catch {
      const created = await auth.createUser({
        email: u.email,
        password: u.password,
        displayName: u.fullName,
      });
      uid = created.uid;
      console.log(`  ✓ Created auth user: ${u.email} (${uid})`);
    }

    // Create Firestore user doc
    await db.collection('users').doc(uid).set({
      uid,
      email:       u.email,
      fullName:    u.fullName,
      phoneNumber: '+9665500000' + rand(10, 99),
      age:         u.age,
      weight:      u.weight,
      height:      u.height,
      gender:      u.gender,
      role:        'user',
      status:      'approved',
      createdAt:   daysAgo(65),
      approvedAt:  daysAgo(62),
      approvedBy:  'admin',
      medicalHistory: null,
      lastReadinessScore: null,
      lastSessionAt: null,
    });

    // Write 60 days of pre+post training.
    // Days 60-29 (older half): guaranteed session every day — ensures the
    // 28-day chronic window is always satisfied regardless of rest-day skips.
    // Days 28-1 (recent month): realistic ~15% rest-day skip for variety.
    const preDocs  = [];
    const postDocs = [];
    let lastReadiness = 0;
    let lastSessionAt = null;

    for (let day = 60; day >= 1; day--) {
      const isOlderHalf = day > 28;
      if (!isOlderHalf && Math.random() < 0.15) continue; // rest day only in recent 28

      const pre  = generatePreTraining(uid, day, u.profile);
      const post = generatePostTraining(uid, day, u.profile);

      preDocs.push(pre);
      postDocs.push(post);

      // track most recent session (day counts down, so last update = day 1)
      lastReadiness = pre.readinessToTrain;
      lastSessionAt = pre.createdAt;
    }

    // Commit in batches of 400 to stay within Firestore limits
    for (let i = 0; i < preDocs.length; i += 400) {
      const b = db.batch();
      preDocs.slice(i, i + 400).forEach(d => b.set(db.collection('pre_training').doc(), d));
      await b.commit();
    }
    for (let i = 0; i < postDocs.length; i += 400) {
      const b = db.batch();
      postDocs.slice(i, i + 400).forEach(d => b.set(db.collection('post_training').doc(), d));
      await b.commit();
    }

    // Update user with last session info
    await db.collection('users').doc(uid).update({
      lastReadinessScore: lastReadiness,
      lastSessionAt,
    });

    console.log(`  ✓ Seeded 60-day data for ${u.fullName} [${u.profile}] (${preDocs.length} sessions)`);
  }

  console.log('  Step 2 done.\n');
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  try {
    await purgeNonAdminUsers();
    await seedTestUsers();
    console.log('✅ All done!');
  } catch (err) {
    console.error('❌ Error:', err.message);
    if (err.code === 7 || err.message?.includes('PERMISSION_DENIED')) {
      console.error('\n⚠ Permission denied. You need a service account key.');
      console.error('  1. Go to: https://console.firebase.google.com/project/tr-athletic-development/settings/serviceaccounts');
      console.error('  2. Click "Generate new private key"');
      console.error('  3. Save the file as: scripts/serviceAccountKey.json');
      console.error('  4. Re-run this script.');
    }
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

main();
