import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/app_localizations.dart';
import '../features/auth/auth_controller.dart';
import '../features/cars/car.dart';
import '../features/cars/car_repository.dart';
import '../features/notifications/notification_service.dart';
import '../features/settings/settings_controller.dart';
import '../shared/responsive.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final signedIn = ref.watch(authControllerProvider).signedIn;
  return GoRouter(
    initialLocation: signedIn ? '/' : '/login',
    redirect: (context, state) {
      final atLogin = state.matchedLocation == '/login';
      if (!signedIn && !atLogin) return '/login';
      if (signedIn && atLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/cars',
            builder: (context, state) => const CarsScreen(),
          ),
          GoRoute(
            path: '/cars/:id',
            builder: (context, state) =>
                CarDetailsScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class Lab9AdaptiveApp extends ConsumerWidget {
  const Lab9AdaptiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'Car rental',
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      themeMode: settings.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController(text: 'student@example.com');
  final password = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.t('app'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: email,
                  decoration: InputDecoration(labelText: l.t('email')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l.t('password')),
                ),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      l.t(auth.error!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    final ok = await ref
                        .read(authControllerProvider.notifier)
                        .signIn(email.text, password.text);
                    if (ok && context.mounted) context.go('/');
                  },
                  child: Text(l.t('login')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final compact = Responsive.compact(context);
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l.t('home'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.directions_car_outlined),
        selectedIcon: const Icon(Icons.directions_car),
        label: l.t('cars'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l.t('settings'),
      ),
    ];
    final location = GoRouterState.of(context).matchedLocation;
    final index = location.startsWith('/cars')
        ? 1
        : location.startsWith('/settings')
        ? 2
        : 0;

    void go(int value) {
      context.go(
        value == 0
            ? '/'
            : value == 1
            ? '/cars'
            : '/settings',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('app')),
        actions: [
          IconButton(
            tooltip: l.t('logout'),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Row(
        children: [
          if (!compact)
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: go,
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: Text(l.t('home')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.directions_car_outlined),
                  selectedIcon: const Icon(Icons.directions_car),
                  label: Text(l.t('cars')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(l.t('settings')),
                ),
              ],
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: compact
          ? NavigationBar(
              selectedIndex: index,
              onDestinationSelected: go,
              destinations: destinations,
            )
          : null,
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cars = ref.watch(carsProvider).valueOrNull ?? [];
    final favorites = cars.where((e) => e.favorite).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InfoCard(
              title: l.t('cars'),
              value: '${cars.length}',
              icon: Icons.directions_car,
            ),
            _InfoCard(
              title: l.t('favorite'),
              value: '$favorites',
              icon: Icons.favorite,
            ),
            _InfoCard(
              title: l.t('version'),
              value: 'Flutter',
              icon: Icons.info,
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.go('/cars'),
          icon: const Icon(Icons.list),
          label: Text(l.t('cars')),
        ),
      ],
    );
  }
}

class CarsScreen extends ConsumerWidget {
  const CarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(carsProvider);
    return Scaffold(
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (cars) => LayoutBuilder(
          builder: (context, constraints) {
            final columns = Responsive.columns(context);
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 2.4 : 2.0,
              ),
              itemCount: cars.length,
              itemBuilder: (context, index) => CarCard(car: cars[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const CarFormDialog(),
        ),
        icon: const Icon(Icons.add),
        label: Text(l.t('add')),
      ),
    );
  }
}

class CarCard extends ConsumerWidget {
  const CarCard({required this.car, super.key});

  final Car car;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/cars/${car.id}'),
        onLongPress: () =>
            ref.read(carsProvider.notifier).toggleFavorite(car.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      car.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(carsProvider.notifier).toggleFavorite(car.id),
                    icon: Icon(
                      car.favorite ? Icons.favorite : Icons.favorite_border,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(car.address, overflow: TextOverflow.ellipsis),
              Text('${car.pricePerDay.toStringAsFixed(0)} BYN/day'),
            ],
          ),
        ),
      ),
    );
  }
}

class CarDetailsScreen extends ConsumerWidget {
  const CarDetailsScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final car = _findCar(ref.watch(carsProvider).valueOrNull ?? [], id);
    if (car == null) return Center(child: Text(l.t('details')));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Icon(
          Icons.directions_car,
          size: 96,
          color: Theme.of(context).colorScheme.primary,
        ),
        Text(car.title, style: Theme.of(context).textTheme.headlineMedium),
        Text(car.address),
        Text('${car.pricePerDay.toStringAsFixed(2)} BYN/day'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => CarFormDialog(car: car),
              ),
              icon: const Icon(Icons.edit),
              label: Text(l.t('edit')),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(carsProvider.notifier).delete(car.id);
                if (context.mounted) context.go('/cars');
              },
              icon: const Icon(Icons.delete),
              label: Text(l.t('delete')),
            ),
          ],
        ),
      ],
    );
  }
}

Car? _findCar(List<Car> cars, String id) {
  for (final car in cars) {
    if (car.id == id) return car;
  }
  return null;
}

class CarFormDialog extends ConsumerStatefulWidget {
  const CarFormDialog({this.car, super.key});

  final Car? car;

  @override
  ConsumerState<CarFormDialog> createState() => _CarFormDialogState();
}

class _CarFormDialogState extends ConsumerState<CarFormDialog> {
  late final brand = TextEditingController(text: widget.car?.brand ?? '');
  late final model = TextEditingController(text: widget.car?.model ?? '');
  late final price = TextEditingController(
    text: widget.car?.pricePerDay.toStringAsFixed(0) ?? '',
  );
  late final address = TextEditingController(text: widget.car?.address ?? '');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.car == null ? l.t('add') : l.t('edit')),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: brand,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
            TextField(
              controller: model,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: address,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final value = double.tryParse(price.text.replaceAll(',', '.')) ?? 0;
            if (brand.text.isEmpty || model.text.isEmpty || value <= 0) return;
            await ref
                .read(carsProvider.notifier)
                .addOrUpdate(
                  Car(
                    id:
                        widget.car?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    brand: brand.text.trim(),
                    model: model.text.trim(),
                    pricePerDay: value,
                    address: address.text.trim(),
                    available: true,
                    favorite: widget.car?.favorite ?? false,
                  ),
                );
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l.t('add')),
        ),
      ],
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(settingsProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.t('settings'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
          ],
          selected: {state.themeMode},
          onSelectionChanged: (value) =>
              ref.read(settingsProvider.notifier).setTheme(value.first),
        ),
        const SizedBox(height: 12),
        SegmentedButton<Locale>(
          segments: const [
            ButtonSegment(value: Locale('ru'), label: Text('RU')),
            ButtonSegment(value: Locale('en'), label: Text('EN')),
            ButtonSegment(value: Locale('be'), label: Text('BE')),
          ],
          selected: {state.locale},
          onSelectionChanged: (value) =>
              ref.read(settingsProvider.notifier).setLocale(value.first),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () async {
            await ref.read(settingsProvider.notifier).clearCache();
            if (context.mounted) {
              NotificationService().show(context, l.t('clearCache'));
            }
          },
          icon: const Icon(Icons.cleaning_services),
          label: Text(l.t('clearCache')),
        ),
        const SizedBox(height: 12),
        Text(l.t('version')),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
