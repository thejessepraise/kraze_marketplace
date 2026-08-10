# Changelog

## Firebase marketplace integration

- Initialized Firebase before `runApp` with the existing generated options.
- Replaced simulated authentication with Firebase email/password, password reset, auth persistence routing, Google sign-in, and Firestore user profiles.
- Replaced sample products with Firestore listing streams, category and prefix search queries.
- Added Firebase Storage-backed product image publishing and product detail loading.
- Added persistent Firestore favorites, profile listing display, and logout.
- Added production-oriented Firestore and Storage rules plus Firebase deployment configuration.
- Added `SETUP.md` with required Firebase Console, CLI, run, deploy, and smoke-test steps.

Chat UI did not exist in the supplied prototype, so it was not fabricated. The rules include a secure conversation/message structure ready for a future matching UI.
