const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// 1. Add Coupons (Admin/Owner or System use)
exports.addCoupons = functions.https.onCall(async (data, context) => {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const { userId, messId, count } = data;
  
  if (!userId || !messId || !count) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters.');
  }

  try {
    await db.collection('users').doc(userId).update({
      [`coupons.${messId}`]: admin.firestore.FieldValue.increment(count)
    });
    return { success: true, message: `Added ${count} coupons for mess ${messId}` };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Failed to add coupons', error);
  }
});

// 2. Redeem Coupon
exports.redeemCoupon = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const { userId, messId, count } = data;
  // Allow user to redeem their own, or owner to redeem for user? 
  // Usually student redeems when placing order.
  
  // Verify ownership if student is redeeming
  if (context.auth.uid !== userId) {
     // Check if caller is the mess owner? For now, let's assume strict user ownership or admin.
     // If mess owner scans QR, they might call this. Let's allow if auth exists for now, but in prod check roles.
  }

  const userRef = db.collection('users').doc(userId);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'User not found');
  }

  const userData = userDoc.data();
  const currentCoupons = userData.coupons && userData.coupons[messId] ? userData.coupons[messId] : 0;

  if (currentCoupons < count) {
    throw new functions.https.HttpsError('failed-precondition', 'Insufficient coupons');
  }

  try {
    await userRef.update({
      [`coupons.${messId}`]: admin.firestore.FieldValue.increment(-count)
    });
    return { success: true, message: `Redeemed ${count} coupons` };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Failed to redeem coupons', error);
  }
});

// 3. Add Wallet Money
exports.addWalletMoney = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }
  
  // In a real app, verify payment gateway signature here!
  const { userId, amount } = data;

  try {
    await db.collection('users').doc(userId).update({
      wallet: admin.firestore.FieldValue.increment(amount)
    });
    return { success: true, message: `Added ${amount} to wallet` };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Failed to add money', error);
  }
});

// 4. Deduct Wallet Money
exports.deductWalletMoney = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const { userId, amount } = data;
  const userRef = db.collection('users').doc(userId);
  
  return db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }
    
    const newBalance = (userDoc.data().wallet || 0) - amount;
    if (newBalance < 0) {
      throw new functions.https.HttpsError('failed-precondition', 'Insufficient funds');
    }
    
    transaction.update(userRef, { wallet: newBalance });
    return { success: true, newBalance };
  });
});

// 5. Purchase Subscription
exports.purchaseSubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const { userId, messId, planPrice, couponCount } = data;
  
  // Validate inputs...
  
  const userRef = db.collection('users').doc(userId);
  const messRef = db.collection('messes').doc(messId);

  return db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    const messDoc = await transaction.get(messRef);

    if (!userDoc.exists || !messDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User or Mess not found');
    }

    const currentWallet = userDoc.data().wallet || 0;
    if (currentWallet < planPrice) {
      throw new functions.https.HttpsError('failed-precondition', 'Insufficient wallet balance');
    }

    // Deduct money
    transaction.update(userRef, { 
      wallet: admin.firestore.FieldValue.increment(-planPrice),
      [`coupons.${messId}`]: admin.firestore.FieldValue.increment(couponCount)
    });

    // Add transaction record (optional but good practice)
    const transactionRef = db.collection('transactions').doc();
    transaction.set(transactionRef, {
      userId,
      messId,
      amount: planPrice,
      type: 'subscription_purchase',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      details: `Purchased ${couponCount} coupons for ${messId}`
    });

    return { success: true, message: 'Subscription purchased successfully' };
  });
});
