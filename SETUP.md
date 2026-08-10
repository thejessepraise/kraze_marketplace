# Kraze Firebase setup

The app is configured for the existing `krazemarketplace` Firebase client project on Android and web. No server credentials are included or needed.

## One-time Firebase console steps

1. In **Authentication → Sign-in method**, enable Email/Password and Google.
2. Add your Android app's SHA-1/SHA-256 fingerprints for Google sign-in, then download a refreshed `android/app/google-services.json` if Firebase prompts you to do so.
3. In Firestore, create the database in production mode and select the same region as Storage.
4. Enable Firebase Storage.

## Deploy access rules

Install and authenticate the Firebase CLI, then from this project directory run:

```powershell
npm install -g firebase-tools
firebase login
firebase use krazemarketplace
firebase deploy --only firestore:rules,storage
```

## Run locally

```powershell
flutter pub get
flutter run -d chrome
# or
flutter run -d android
```

## Smoke test

1. Register an account, then confirm `users/{uid}` appears in Firestore.
2. Use **Post an item**, choose one or more photos, and publish. Confirm images appear under `product_images/{uid}/{productId}` and the product document contains their download URLs.
3. Favorite a product and confirm `users/{uid}/favorites/{productId}` exists.
4. Sign out, sign back in, and confirm favorites and listings persist.

Search uses Firestore's `array-contains` prefix-keyword query. This provides title/category word-prefix matching without downloading the full marketplace database; it is not arbitrary full-text search.
