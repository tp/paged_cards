import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:paged_cards/paged_cards.dart';

class PagedCards extends StatefulWidget {
  const PagedCards({Key key, @required this.cards})
      : assert(cards != null),
        super(key: key);

  final List<CardPage> cards;

  @override
  _PagedCardsState createState() => _PagedCardsState();
}

class _PagedCardsState extends State<PagedCards> {
  final PageController controller = PageController(
    viewportFraction: 0.9,
  );

  @override
  initState() {
    super.initState();

    controller.addListener(() {
      final currentPage = controller.hasClients &&
              // Enable workaround for a crasher on first render
              controller.position?.minScrollExtent != null
          ? controller.page.round()
          : null;

      if (currentPage != null && currentPage != _activePage) {
        setState(() {
          _activePage = currentPage;
          _currentCardOffset = 0;
          print('new active page = ${currentPage}');
        });
      }
    });
  }

  int _activePage = 0;
  int _currentCardOffset = 0;

  @override
  Widget build(BuildContext context) {
    print('_currentCardOffset = $_currentCardOffset');

    final index = 1;

    // return Stack(children: [
    //   Positioned(
    //     top: 50,
    //     left: -(MediaQuery.of(context).size.width - 100) + 40,
    //     width: MediaQuery.of(context).size.width - 100,
    //     height: MediaQuery.of(context).size.height,
    //     child: CardPage(
    //       color: 0 % 2 == 0 ? Colors.red : Colors.blue,
    //       isPrimaryCard: index == _activePage,
    //       onScroll: (offset) {
    //         setState(() {
    //           _currentCardOffset = offset;
    //           print('_currentCardOffset = $_currentCardOffset');
    //         });
    //       },
    //       // current
    //     ),
    //   ),
    //   Positioned(
    //     top: 50,
    //     left: 50,
    //     width: MediaQuery.of(context).size.width - 100,
    //     height: MediaQuery.of(context).size.height,
    //     child: CardPage(
    //       color: 1 % 2 == 0 ? Colors.red : Colors.blue,
    //       isPrimaryCard: index == _activePage,
    //       onScroll: (offset) {
    //         setState(() {
    //           _currentCardOffset = offset;
    //           print('_currentCardOffset = $_currentCardOffset');
    //         });
    //       },
    //       // current
    //     ),
    //   ),
    //   Positioned(
    //     top: 50,
    //     left: MediaQuery.of(context).size.width - 50,
    //     width: MediaQuery.of(context).size.width - 100,
    //     height: MediaQuery.of(context).size.height,
    //     // right: -100,
    //     // bottom: 0,
    //     child: CardPage(
    //       color: 2 % 2 == 0 ? Colors.red : Colors.blue,
    //       isPrimaryCard: index == _activePage,
    //       onScroll: (offset) {
    //         setState(() {
    //           _currentCardOffset = offset;
    //           print('_currentCardOffset = $_currentCardOffset');
    //         });
    //       },
    //       // current
    //     ),
    //   )
    // ]);

    // controller.viewportFraction = 1;
    // TODO: ListView.custom ?
    // FixedExtentScrollPhysics
    // https://stackoverflow.com/questions/47349784/creating-image-carousel-in-flutter
    return Transform.scale(
        scale: 0.9 + (_currentCardOffset / 25) * 0.25,
        child: PageView.builder(
          physics: const PageScrollPhysics(),

          controller: controller,

          // itemExtent: 370,
          itemBuilder: (context, index) {
            return Container(
              // width: 360,
              child: CardPage(
                color: index % 2 == 0 ? Colors.red : Colors.blue,
                isPrimaryCard: index == _activePage,
                onScroll: (offset) {
                  setState(() {
                    _currentCardOffset = offset;
                    print('_currentCardOffset = $_currentCardOffset');
                  });
                },
                // current
              ),
              height: 1000,
            );
          },
          itemCount: widget.cards.length,
          scrollDirection: Axis.horizontal,
        ));

    // return PageView.builder(
    //   controller: controller,
    //   itemBuilder: (context, index) {
    //     return Container(
    //       color: Colors.green,
    //       child: Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: CardPage(
    //           color: index % 2 == 0 ? Colors.red : Colors.blue,
    //           isPrimaryCard: index == _activePage,
    //           // current
    //         ),
    //       ),
    //     );
    //   },
    //   itemCount: widget.cards.length,
    // );
  }

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }
}
