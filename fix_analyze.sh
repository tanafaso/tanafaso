#!/bin/bash

# Fix 1: Remove unused _firebaseApp field from main.dart
sed -i '' '/late FirebaseApp _firebaseApp;/d' mobile/lib/main.dart
sed -i '' 's/_firebaseApp = await Firebase.initializeApp(/await Firebase.initializeApp(/' mobile/lib/main.dart

# Fix 2: Remove unused _offsetAnimation field
sed -i '' '/late Animation<Offset> _offsetAnimation;/d' mobile/lib/views/core_views/home/all_challenges/global_challenge_widget.dart

echo "Basic fixes applied. Running flutter analyze again..."
flutter analyze
