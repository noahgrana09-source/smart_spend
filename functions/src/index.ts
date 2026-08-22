/**
 * Cloud Functions — SmartSpend
 * https://firebase.google.com/docs/functions/typescript
 */

import {setGlobalOptions} from "firebase-functions";
import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import Stripe from "stripe";

initializeApp();

// For cost control, cap concurrent containers per function.
setGlobalOptions({maxInstances: 10});

// Stripe secret key lives only here (Secret Manager), never on the client.
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");

// Plan Premium: pago único (no suscripción).
const PREMIUM_PRICE_CENTS = 999; // USD 9.99
const PREMIUM_CURRENCY = "usd";

/**
 * Callable invocada desde la app (paso 8) al elegir Premium.
 * Crea/recupera el Stripe Customer del usuario, una Ephemeral Key y un
 * PaymentIntent para el monto fijo del plan Premium, y devuelve lo
 * necesario para que `flutter_stripe` abra el `PaymentSheet`.
 *
 * El estado de cuenta (Premium) NO se marca acá: se confirma vía webhook
 * (`stripeWebhook`) cuando Stripe reporta el pago como exitoso, para que
 * un cliente no pueda auto-otorgarse Premium sin pagar.
 */
export const createPremiumPaymentSheet = onCall(
  {secrets: [stripeSecretKey]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Debés iniciar sesión para continuar."
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
        "Este usuario ya tiene el plan Premium."
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

// El webhook de Stripe necesita el secret propio de ese endpoint (distinto
// de la secret key general) para verificar la firma de cada evento.
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");

/**
 * Webhook de Stripe. Escucha `payment_intent.succeeded` para el plan
 * Premium y recién ahí persiste el cambio de estado de cuenta en
 * Firestore (paso 3 / paso 8), evitando que el cliente pueda simular un
 * pago exitoso.
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
      logger.error("Firma de webhook de Stripe inválida", err);
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
        logger.info(`Usuario ${uid} pasó a Premium.`);
      }
    }

    res.status(200).send("ok");
  }
);
