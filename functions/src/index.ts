/**
 * Cloud Functions — SmartSpend
 * https://firebase.google.com/docs/functions/typescript
 */

import {setGlobalOptions} from "firebase-functions";
import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue, Timestamp} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
import Stripe from "stripe";

initializeApp();

// For cost control, cap concurrent containers per function.
setGlobalOptions({maxInstances: 10});

// Stripe secret key lives only here (Secret Manager), never on the client.
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");

// Premium Plan: one-time payment (not a subscription).
const PREMIUM_PRICE_CENTS = 999; // USD 9.99
const PREMIUM_CURRENCY = "usd";

/**
 * Callable invoked from the app (step 8) when choosing Premium.
 * Creates/retrieves the user's Stripe Customer, an Ephemeral Key, and a
 * PaymentIntent for the fixed amount of the Premium plan, and returns what
 * is needed for `flutter_stripe` to open the `PaymentSheet`.
 *
 * The account status (Premium) is NOT marked here: it is confirmed via webhook
 * (`stripeWebhook`) when Stripe reports the payment as successful, so that
 * a client cannot self-grant Premium without paying.
 */
export const createPremiumPaymentSheet = onCall(
  {secrets: [stripeSecretKey]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be logged in to continue."
      );
    }

    const uid = request.auth.uid;
    const email = request.auth.token.email;
    const stripe = new Stripe(stripeSecretKey.value());
    const db = getFirestore();
    const userRef = db.collection("users").doc(uid);

    const userSnap = await userRef.get();
    let customerId = userSnap.data()?.stripeCustomerId as string | undefined;

    if (userSnap.data()?.isPremium === true) {
      throw new HttpsError(
        "already-exists",
        "This user already has the Premium plan."
      );
    }

    if (!customerId) {
      const customer = await stripe.customers.create({
        email,
        metadata: {firebaseUID: uid},
      });
      customerId = customer.id;
      await userRef.set({stripeCustomerId: customerId}, {merge: true});
    }

    const ephemeralKey = await stripe.ephemeralKeys.create(
      {customer: customerId},
      {apiVersion: Stripe.API_VERSION}
    );

    const paymentIntent = await stripe.paymentIntents.create({
      amount: PREMIUM_PRICE_CENTS,
      currency: PREMIUM_CURRENCY,
      customer: customerId,
      automatic_payment_methods: {enabled: true},
      metadata: {firebaseUID: uid, plan: "premium"},
    });

    return {
      paymentIntentClientSecret: paymentIntent.client_secret,
      ephemeralKeySecret: ephemeralKey.secret,
      customerId,
    };
  }
);

// The Stripe webhook needs the secret specific to that endpoint (distinct
// from the general secret key) to verify the signature of each event.
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");

/**
 * Stripe Webhook. Listens for `payment_intent.succeeded` for the Premium
 * plan and only then persists the account status change in
 * Firestore (step 3 / step 8), preventing the client from simulating a
 * successful payment.
 */
export const stripeWebhook = onRequest(
  {secrets: [stripeSecretKey, stripeWebhookSecret]},
  async (req, res) => {
    const signature = req.headers["stripe-signature"];
    const stripe = new Stripe(stripeSecretKey.value());

    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        signature as string,
        stripeWebhookSecret.value()
      );
    } catch (err) {
      logger.error("Invalid Stripe webhook signature", err);
      res.status(400).send("Invalid signature");
      return;
    }

    if (event.type === "payment_intent.succeeded") {
      const paymentIntent = event.data.object as Stripe.PaymentIntent;
      const uid = paymentIntent.metadata.firebaseUID;

      if (uid && paymentIntent.metadata.plan === "premium") {
        await getFirestore().collection("users").doc(uid).set(
          {
            isPremium: true,
            premiumSince: FieldValue.serverTimestamp(),
          },
          {merge: true}
        );
        logger.info(`User ${uid} upgraded to Premium.`);
      }
    }

    res.status(200).send("ok");
  }
);

// Grace period before an unverified account is eligible for cleanup — see
// `deleteUnverifiedUsers`. Independent of how often the job itself runs
// (below): a freshly-created account is never at risk, no matter when the
// schedule happens to fire.
const UNVERIFIED_ACCOUNT_GRACE_PERIOD_DAYS = 7;

/**
 * Scheduled cleanup (runs daily). Deletes accounts whose `users/{uid}`
 * profile still has `isEmailVerified: false` after
 * `UNVERIFIED_ACCOUNT_GRACE_PERIOD_DAYS` days (see the sign-up +
 * email-verification flow in the `auth` feature) — both the Firebase Auth
 * user and its Firestore profile, so the email address is freed up for a
 * fresh sign-up attempt.
 *
 * Requires a composite index on `users` (`isEmailVerified` asc,
 * `createdAt` asc) — see `firestore.indexes.json`.
 */
export const deleteUnverifiedUsers = onSchedule(
  "every 24 hours",
  async () => {
    const cutoff = Timestamp.fromMillis(
      Date.now() - UNVERIFIED_ACCOUNT_GRACE_PERIOD_DAYS * 24 * 60 * 60 * 1000
    );
    const db = getFirestore();
    const snapshot = await db
      .collection("users")
      .where("isEmailVerified", "==", false)
      .where("createdAt", "<=", cutoff)
      .get();

    if (snapshot.empty) {
      logger.info("No unverified accounts past the grace period.");
      return;
    }

    const auth = getAuth();
    let deletedCount = 0;

    for (const userDoc of snapshot.docs) {
      try {
        await auth.deleteUser(userDoc.id);
      } catch (err) {
        // Already gone from Auth (e.g. deleted by hand) — still clean up
        // the stale Firestore doc below. Any other error is left for the
        // next run to retry, so the two never drift out of sync.
        if ((err as {code?: string}).code !== "auth/user-not-found") {
          logger.error(`Failed to delete Auth user ${userDoc.id}`, err);
          continue;
        }
      }

      try {
        await userDoc.ref.delete();
        deletedCount++;
      } catch (err) {
        logger.error(`Failed to delete Firestore profile ${userDoc.id}`, err);
      }
    }

    logger.info(
      `Deleted ${deletedCount}/${snapshot.size} unverified accounts.`
    );
  }
);
