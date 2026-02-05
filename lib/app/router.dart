import 'package:begin_first/app/main_screen.dart';
import 'package:begin_first/features/checkout/screens/checkout_screen.dart';
import 'package:begin_first/features/items/screens/item_detail_screen.dart';
import 'package:begin_first/features/items/screens/item_form_screen.dart';
import 'package:begin_first/features/items/screens/items_screen.dart';
import 'package:begin_first/features/nudges/screens/intent_form_screen.dart';
import 'package:begin_first/features/nudges/screens/nudges_screen.dart';
import 'package:begin_first/features/onboarding/screens/onboarding_flow_screen.dart';
import 'package:begin_first/features/records/screens/camera_screen.dart';
import 'package:begin_first/features/records/screens/record_complete_screen.dart';
import 'package:begin_first/features/records/screens/record_detail_screen.dart';
import 'package:begin_first/features/retrieve/screens/retrieve_screen.dart';
import 'package:begin_first/features/scenes/screens/scene_detail_screen.dart';
import 'package:begin_first/features/scenes/screens/scene_form_screen.dart';
import 'package:begin_first/features/scenes/screens/scenes_screen.dart';
import 'package:begin_first/features/settings/screens/settings_screen.dart';
import 'package:begin_first/features/settings/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final isFirstLaunch = ref.watch(appSettingsProvider.select((settings) => settings.isFirstLaunch));
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (isFirstLaunch && state.uri.path != '/onboarding') {
        return '/onboarding';
      }
      if (!isFirstLaunch && state.uri.path == '/onboarding') {
        return '/items';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/items',
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/items',
                builder: (context, state) => const ItemsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const ItemFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final itemId = state.pathParameters['id']!;
                      return ItemDetailScreen(itemId: itemId);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final itemId = state.pathParameters['id']!;
                          return ItemFormScreen(itemId: itemId);
                        },
                      ),
                      GoRoute(
                        path: 'record',
                        builder: (context, state) {
                          final itemId = state.pathParameters['id']!;
                          final sceneId = state.uri.queryParameters['sceneId'];
                          return CameraScreen(itemId: itemId, sceneId: sceneId);
                        },
                        routes: [
                          GoRoute(
                            path: 'complete',
                            builder: (context, state) {
                              final itemId = state.pathParameters['id']!;
                              return RecordCompleteScreen(itemId: itemId);
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'retrieve',
                        builder: (context, state) {
                          final itemId = state.pathParameters['id']!;
                          return RetrieveScreen(itemId: itemId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scenes',
                builder: (context, state) => const ScenesScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const SceneFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final sceneId = state.pathParameters['id']!;
                      return SceneDetailScreen(sceneId: sceneId);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final sceneId = state.pathParameters['id']!;
                          return SceneFormScreen(sceneId: sceneId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/nudges',
                builder: (context, state) => const NudgesScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const IntentFormScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) {
                      final intentId = state.pathParameters['id']!;
                      return IntentFormScreen(intentId: intentId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingFlowScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/records/:id',
        builder: (context, state) {
          final recordId = state.pathParameters['id']!;
          return RecordDetailScreen(recordId: recordId);
        },
      ),
    ],
  );
});
