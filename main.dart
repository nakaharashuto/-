------------------------------main.dart------------------------------

// ファイルパス: lib/main.dart
// 役割: アプリのエントリーポイント、テーマ設定、認証ラッパー

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_provider.dart';
import 'providers/master_pin_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/set_pin_screen.dart';

void main() {
	runApp(const ProviderScope(
		child: SecureNotesApp(),
	));
}

class SecureNotesApp extends StatelessWidget {
	const SecureNotesApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Secure Notes',
			debugShowCheckedModeBanner: false,
			theme: ThemeData(
				colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple, 
                    surface: Colors.grey.shade50
                ),
				useMaterial3: true,
				textTheme: Theme.of(context).textTheme,
			),
			home: const AuthWrapper(),
		);
	}
}

class AuthWrapper extends ConsumerWidget {
	const AuthWrapper({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final isAuthenticated = ref.watch(authProvider);
		
		final masterPinAsyncValue = ref.watch(masterPinProvider);

		return masterPinAsyncValue.when(
			loading: () => const Scaffold(
				body: Center(child: CircularProgressIndicator()),
			),
			error: (e, st) => Scaffold(
				body: Center(child: Text('PINデータのロードエラー: $e')),
			),
			data: (masterPinState) {
				final isPinSet = masterPinState.isPinSet; 

				if (isAuthenticated) {
					return const HomeScreen();
				} else {
					return isPinSet ? const AuthScreen() : const SetPinScreen(); 
				}
			},
		);
	}
}

------------------------------------------------------------------------------------------
