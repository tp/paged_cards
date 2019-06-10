import 'package:flutter/material.dart';
import 'package:paged_cards/paged_cards.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Bookstore'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: MaterialButton(
        child: Text('Open Cards'),
        onPressed: () {
          _showCards();
        },
      ),
    );
  }

  void _showCards() {
    Navigator.of(context, rootNavigator: true).push(
      OverlayRoute(
        builder: (context) {
          return Container(
            child: PagedCards(
              cardCount: 4,
              builder: (context, index) {
                final color = index % 2 == 0 ? Colors.red : Colors.blue;

                return Scaffold(
                  appBar: AppBar(
                    title: Text('Card $index'),
                    backgroundColor: Colors.green,
                  ),
                  body: ListView.builder(
                    itemCount: 1000,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 30,
                        color: color,
                        child: Text('$index'),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        // fullscreenDialog: true,
      ),
    );
  }
}

class OverlayRoute extends ModalRoute<void> {
  OverlayRoute({
    @required this.builder,
  });

  final WidgetBuilder builder;

  @override
  Duration get transitionDuration => Duration(milliseconds: 0);

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
    // return builder(context);
    return Material(
      type: MaterialType.transparency,
      child: builder(context),
    );
  }
}
