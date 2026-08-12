# Kraze — Firebase Schema

## Firestore

### `users/{uid}`
Document ID = Firebase Auth UID.
| field | type | notes |
|---|---|---|
| name | string | display name |
| email | string | |
| phone | string | used for the Chat "call seller" dialer action |
| photoUrl | string | Storage download URL, `''` if none |
| createdAt | timestamp | server-set |

#### `users/{uid}/favorites/{productId}`
Presence of the document = favorited. No fields needed beyond `createdAt` (timestamp, server-set).

### `products/{productId}`
Document ID = auto-generated.
| field | type | notes |
|---|---|---|
| title | string | |
| price | number | |
| category | string | |
| description | string | |
| imageUrl | string | Storage download URL, `''` if none |
| sellerId | string | Auth UID — ownership check for rules |
| sellerName | string | denormalized at post time |
| sellerPhone | string | denormalized at post time |
| status | string | `'active'` (only status currently written/read) |
| createdAt / updatedAt | timestamp | server-set |

### `conversations/{conversationId}`
Document ID = `${productId}_${buyerId}` (deterministic — reopening the same listing's chat reuses the thread instead of duplicating it).
| field | type | notes |
|---|---|---|
| productId, productTitle, productImageUrl | | copied from the listing at creation |
| sellerId, sellerName, sellerPhone | | |
| buyerId, buyerName, buyerPhone | | |
| participantIds | array\<string\> | `[sellerId, buyerId]` — used by security rules and the `arrayContains` query that lists a user's conversations |
| lastMessageText, lastMessageSenderId, lastMessageAt | | denormalized preview, shown on the Messages screen without reading the subcollection |
| createdAt | timestamp | |

#### `conversations/{conversationId}/messages/{messageId}`
| field | type | notes |
|---|---|---|
| text | string | |
| senderId | string | Auth UID |
| sentAt | timestamp | server-set |

## Storage

- `users/{uid}/profile/avatar.jpg` — profile picture.
- `users/{uid}/listings/{listingId}/photo.jpg` — one photo per listing (the app currently posts a single image per listing).

Both paths: publicly readable, write restricted to the owning `{uid}`, 5MB/10MB size caps, image-only content type (see `storage.rules`).

## Security assumptions

- A listing's `sellerId` is trusted to be the *creator's own* UID (enforced in `firestore.rules`) — the app never lets a user set `sellerId` to someone else.
- Seller/buyer name & phone are **denormalized copies**, written once when a listing/conversation is created. If a user edits their profile afterward, past listings/conversations keep the old name/phone. This is a deliberate simplicity trade-off, not an oversight — re-propagating profile edits to every listing/conversation would need a Cloud Function, which is out of scope for a client-only backend.
- Messages are immutable — no update/delete rule is defined for them, so both are denied by default.

## Required indexes

Firestore will prompt for these composite indexes the first time each query runs (Firebase Console link appears in the error, or create manually):
1. `products`: `status` (ascending) + `createdAt` (descending) — powers Home's listings stream.
2. `conversations`: `participantIds` (array-contains) + `lastMessageAt` (descending) — powers the Messages screen.

No indexes need to be created manually ahead of time — Firestore will only complain the first time each query actually runs against real data, and the console link it prints creates the index in one click.
