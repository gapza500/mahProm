```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function hasRole(role) {
      return request.auth != null &&
        (request.auth.token.role == role ||
         (request.auth.token.roles is list && role in request.auth.token.roles));
    }

    function isApproved() {
      return request.auth.token.approved == true ||
        (request.resource.data.status == 'approved');
    }

    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if hasRole('admin');
      allow update: if hasRole('admin');
    }

    match /pets/{petId} {
      allow read: if hasRole('admin') || hasRole('tester');
      allow write: if hasRole('owner') || hasRole('admin');
    }
  }
}
```

## Role & Claims Seeding
1. Use Firebase Admin SDK to set custom claims:
   ```js
   admin.auth().setCustomUserClaims(uid, { roles: ['admin'] });
   ```
2. Ensure each user has `/users/{uid}` with fields `displayName`, `email`, `role`, `status`.
3. Approvals flip `status` to `approved`. Optionally set `approved: true` in claims.
