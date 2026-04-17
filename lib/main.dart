import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/service/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize your specific Enterprise DB
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'note-curetutors',
  );

  debugPrint('Connected to database: ${firestore.databaseId}');

  // --- ONE-TIME MIGRATION ---
  // This will scan your existing notes and add the 'titleLowerCase' field.
  // You can remove this block once your search is working.
  await _runMigration(firestore);

  // Set the background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize FCM Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Loops through existing notes and adds titleLowerCase if missing
Future<void> _runMigration(FirebaseFirestore firestore) async {
  try {
    final snapshot = await firestore.collection('notes').get();

    final WriteBatch batch = firestore.batch();
    int count = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      // If the field is missing, we add it to the batch update
      if (!data.containsKey('titleLowerCase')) {
        final String title = data['title'] ?? "";
        batch.update(doc.reference, {'titleLowerCase': title.toLowerCase()});
        count++;
      }
    }

    if (count > 0) {
      await batch.commit();
      debugPrint('MIGRATION SUCCESS: Updated $count existing notes.');
    } else {
      debugPrint('MIGRATION: No documents needed updating.');
    }
  } catch (e) {
    debugPrint('MIGRATION FAILED: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}