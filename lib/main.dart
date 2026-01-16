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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 149, 75, 184),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];
  var selectedIndex = 0;

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
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
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    // bool responsiveNav() {
    //   return MediaQuery.of(context).size.width >= 600;
    // }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Scaffold(
            body: mainArea,
            bottomNavigationBar: NavigationBar(
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          );
        } else {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
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
                ),
                Expanded(
                  child: mainArea,
                ),
              ],
            ),
          );
        }
      },
    );
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
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    } else {
      return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        // The .map function starts here
        ...appState.favorites.map(
          (favorite) => ListTile(
            title: Text(favorite.asPascalCase),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // This uses the "singular" variable to target one item
                appState.favorites.remove(favorite);
                // You must call a function to refresh the UI
                appState.getNext(); //notifyListeners();
              },
            ),
          ),
        ),

        // for (var pair in appState.favorites)
        //   ListTile(
        //     leading: Icon(Icons.favorite),
        //     title: Text(pair.asLowerCase),
        //   ),
      ],
    );
    }
  }
}

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<MyAppState>();
//     var pair = appState.current;

//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             BigCard(pair: pair),
//             //  SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     appState.toggleFavorite();
//                   },
//                   icon: Icon(
//                     appState.favorites.contains(pair)
//                         ? Icons.favorite
//                         : Icons.favorite_border,
//                     color: appState.favorites.contains(pair)
//                         ? Colors.red
//                         : null,
//                     size: 24,
//                   ),
//                   label: Text(
//                     appState.favorites.contains(pair) ? 'Dislike' : 'Like',
//                   ),
//                 ),
//                 SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     print('button pressed!');
//                     // appState.current = WordPair.random();
//                     // appState.notifyListeners();
//                     appState.getNext();
//                   },
//                   child: Text('Next'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(2, 2),
          blurRadius: 3,
        ),
      ],
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      elevation: 15,
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: MergeSemantics(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  pair.first,
                  style: style.copyWith(fontWeight: FontWeight.w200),
                ),
                Text(
                  pair.second,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                ),  
              ]
            )
          ),
        ),
      ),
    );
    


  }
}
