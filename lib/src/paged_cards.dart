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
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemBuilder: (context, index) {
        return CardPage(
          color: index % 2 == 0 ? Colors.red : Colors.blue,
          isPrimaryCard: controller.hasClients &&
              // TODO: Enable workaround for a crasher on first render
              // controller.position?.minScrollExtent != null &&
              controller.page == index,
        );
      },
      itemCount: widget.cards.length,
    );
  }
}
