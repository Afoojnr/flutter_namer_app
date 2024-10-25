import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var pairs = <WordPair>[];

  void getNext() {
    pairs.add(current);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      // break;
      case 1:
        page = FavoritesPage();
      // break;
      default:
        throw UnimplementedError("No widget for $selectedIndex");
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: DisplayPreviousPairs()),
          Expanded(
            child: Column(
              children: [
                BigCard(pair: pair),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        appState.toggleFavorite();
                      },
                      icon: Icon(icon),
                      label: Text('Like'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        appState.getNext();
                      },
                      child: Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }
    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("You have ${favorites.length} favorites"),
        ),
        SizedBox(
          height: 10,
        ),
        for (var favorite in favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                appState.removeFavorite(favorite);
              },
            ),
            title: Text(favorite.asLowerCase),
          ),
      ],
    );
  }
}

class DisplayPreviousPairs extends StatelessWidget {
  const DisplayPreviousPairs({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pairs = appState.pairs;
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.primary,
    );

    if (pairs.isEmpty) {
      return Center(
        child: Text(''),
      );
    }
    return Center(
      child: ListView(
        // shrinkWrap: true,
        reverse: true,
        children: [
          for (var pair in pairs)
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(appState.favorites.contains(pair)
                      ? Icons.favorite
                      : null),
                  SizedBox(width: 10),
                  Text(
                    pair.asLowerCase,
                    style: style,
                  ),
                ],
              ),
            ),
          // ListTile(
          //   leading: appState.favorites.contains(pair)
          //       ? Icon(Icons.favorite)
          //       : SizedBox(),
          //   title: Center(child: Text(pair.asLowerCase)),
          // )
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pair.first,
              style: style.copyWith(fontWeight: FontWeight.w200),
            ),
            Text(
              pair.second,
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}
