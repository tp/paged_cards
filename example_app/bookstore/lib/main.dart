import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:paged_cards/paged_cards.dart';

void main() => runApp(MyApp());

class Book {
  Book(this.title, this.url);

  final String title;
  final Uri url;
}

final books = [
  Book(
    'Alice\'s Adventures',
    Uri.parse(
        'https://upload.wikimedia.org/wikipedia/en/7/72/Alicesadventuresinwonderland1898.jpg'),
  ),
  Book(
    'The Count of Monte Cristo',
    Uri.parse(
        'https://upload.wikimedia.org/wikipedia/commons/d/d6/Louis_Français-Dantès_sur_son_rocher.jpg'),
  ),
  Book(
    'Phantom of the Opera',
    Uri.parse(
        'https://upload.wikimedia.org/wikipedia/commons/7/76/André_Castaigne_Fantôme_Opéra1.jpg'),
  ),
  Book(
    'Les Misérables',
    Uri.parse(
        'https://upload.wikimedia.org/wikipedia/commons/f/fd/Monsieur_Madeleine_par_Gustave_Brion.jpg'),
  ),
  Book(
    'The Picture of Dorian Gray',
    Uri.parse(
        'https://upload.wikimedia.org/wikipedia/en/0/00/The_title_card_of_an_1891_print_of_The_Picture_of_Dorian_Gray%2C_by_Oscar_Wilde.png'),
  ),
];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Bookstore'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCards(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return InkWell(
            child: BookRow(book: books[index]),
            onTap: () {
              _showCards(index);
            },
          );
        },
        itemCount: books.length,
      ),
    );
  }

  void _showCards(int initialPageIndex) {
    Navigator.of(context, rootNavigator: true).push(
      FullscreenOverlayRoute(
        child: Container(
          child: PagedCards(
            cardCount: books.length,
            initialPage: initialPageIndex,
            builder: (context, index) {
              return BookDetail(book: books[index]);
            },
          ),
        ),
      ),
    );
  }
}

class BookRow extends StatelessWidget {
  BookRow({
    Key key,
    @required this.book,
  }) : super(key: key);

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            child: Image.network(book.url.toString()),
          ),
          Text(book.title, style: Theme.of(context).textTheme.headline),
        ],
      ),
    );
  }
}

class BookDetail extends StatelessWidget {
  const BookDetail({
    Key key,
    @required this.book,
  }) : super(key: key);

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        backgroundColor: Colors.red,
      ),
      body: Navigator(
        onGenerateRoute: (_) {
          return MaterialPageRoute(
            settings: RouteSettings(isInitialRoute: true),
            builder: (context) {
              return Container(
                color: Color.fromARGB(5, 0, 0, 0),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                    itemCount: 1000,
                    itemBuilder: (context, index) {
                      if (index == 0)
                        return AspectRatio(
                          aspectRatio: 0.75,
                          child: Image.network(
                            book.url.toString(),
                          ),
                        );

                      if (index == 1)
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(book.title,
                                style: Theme.of(context).textTheme.headline),
                          ),
                        );

                      if (index == 2) {
                        return Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.' *
                              2,
                        );
                      }

                      return Container(
                        height: 30,
                        child: Text('Filler Row #${index - 1}'),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FullscreenOverlayRoute extends PageRoute<void> {
  FullscreenOverlayRoute({
    @required this.child,
  }) : super(fullscreenDialog: true);

  final Widget child;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.white.withOpacity(0.75);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          GestureDetector(
            child: Container(color: Colors.transparent),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          child,
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final theme = Theme.of(context).pageTransitionsTheme;

    return AnimatedBuilder(
      animation: animation,
      child: theme.buildTransitions<void>(
        this,
        context,
        animation,
        secondaryAnimation,
        child,
      ),
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(animation.value * 0.75),
          child: child,
        );
      },
    );
  }
}
