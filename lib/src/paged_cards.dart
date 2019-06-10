import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum CardType {
  left,
  primary,
  right,
}

class PagedCards extends StatefulWidget {
  const PagedCards({
    Key key,
    @required this.cardCount,
    @required this.builder,
    this.initialPage = 0,
  })  : assert(cardCount >= 0),
        assert(initialPage < cardCount),
        assert(builder != null),
        super(key: key);

  final int cardCount;
  final Widget Function(BuildContext context, int index) builder;
  final int initialPage;

  @override
  _PagedCardsState createState() => _PagedCardsState();
}

class _PagedCardsState extends State<PagedCards> with TickerProviderStateMixin {
  // Animation<double> _primarySnapAnimation;

  /// -1 (fully dismissed) to 1 (fully snapped)
  AnimationController _primarySnapAnimationController;

  AnimationController _currentPageIndexAnimationController;

  // Animation<double> _primaryDismissAnimation;
  // AnimationController _primaryDismissAnimationController;

  int _primaryPageIndex;

  double _panDownY;

  double _panDownX;

  @override
  initState() {
    super.initState();

    _primarySnapAnimationController = AnimationController(
      vsync: this,
      value: 0,
      lowerBound: -1,
      upperBound: 1,
    );

    _primaryPageIndex = widget.initialPage;

    _currentPageIndexAnimationController = AnimationController(
      vsync: this,
      value: widget.initialPage.toDouble(),
      lowerBound: 0,
      upperBound: double.infinity,
    );

    // _currentPageIndexAnimationController.addListener(() {
    //   final currentPage = _currentPageIndexAnimationController.value % 1;
    //   if (currentPage != _primaryPageIndex) {
    //     setState(() {
    //       _primaryPageIndex = currentPage;
    //     });
    //   }
    // });

    // Timer.periodic(Duration(milliseconds: 36), (d) {
    //   setState(() {
    //     // _centerCardProgress = (d.tick % 120 / 60).clamp(0.0, 1.0);
    //   });
    // });
  }

  Widget _renderCard(
    BuildContext context, {
    int currentIndex,
    type: CardType,
  }) {
    final isCenteredCard = type == CardType.primary;
    final containerWidth = MediaQuery.of(context).size.width;
    final containerHeight = MediaQuery.of(context).size.height;
// MediaQuery.
// MediaQuery.of(context).size
    Widget childCard = MediaQuery.removePadding(
      context: context,
      // removeTop: true,
      removeBottom: true,
      child: Container(
        color: Colors.blue,
        height: 1000,
        child: widget.builder(context, currentIndex),
      ),
    );
    // final childCard =
    //     Container(height: 10000, child: widget.builder(context, currentIndex));

    return AnimatedBuilder(
      key: Key('$currentIndex'),
      animation: _primarySnapAnimationController,
      child: childCard,
      builder: (context, child) {
        // print('rendering with value ${_primarySnapAnimationController.value}');

        final animationValue = _primarySnapAnimationController.value;

        final primaryCardSnapProgress =
            animationValue > 0 ? animationValue : 0.0;
        final neighborCardPaddingFactor = (1 -
            primaryCardSnapProgress *
                primaryCardSnapProgress *
                primaryCardSnapProgress);
        final dismissDistance =
            animationValue < 0 ? animationValue * -containerHeight : 0.0;

        return Opacity(
          opacity: animationValue < 0 ? animationValue + 1 : 1,
          child: AnimatedBuilder(
            animation: _currentPageIndexAnimationController,
            builder: (context, _) {
              final nextPage = (_currentPageIndexAnimationController.value -
                  _primaryPageIndex);
              final dx =
                  (nextPage >= 0 ? -nextPage : (-nextPage)) * containerWidth;
              // print('nextPage = $nextPage; dx = $dx');

              return Transform.translate(
                offset: isCenteredCard
                    ? Offset(
                        dx,
                        dismissDistance,
                      )
                    : type == CardType.left
                        ? Offset(
                            -containerWidth +
                                30 * neighborCardPaddingFactor +
                                dx,
                            dismissDistance,
                          )
                        : Offset(
                            containerWidth -
                                30 * neighborCardPaddingFactor +
                                dx,
                            dismissDistance,
                          ),
                child: Transform.scale(
                  scale: 1,
                  // scale: 0.9 +
                  //     (isCenteredCard
                  //         ? (0.1 * (1 - neighborCardPaddingFactor))
                  //         : 0),
                  // origin: Offset(-1, 0),
                  child: GestureDetector(
                    dragStartBehavior: DragStartBehavior.down,
                    onVerticalDragDown: isCenteredCard
                        ? (details) {
                            //     print('pan down');
                            _panDownY = details.globalPosition.dy;
                          }
                        : null,
                    onHorizontalDragDown: isCenteredCard
                        ? (details) {
                            _panDownX = details.globalPosition.dx;
                          }
                        : null,
                    onHorizontalDragUpdate: (_) {
                      if (_primarySnapAnimationController.value > 0.1) {
                        // page might be snapped, don't allow horizontal gestures at the moment
                        return;
                      }

                      final width = MediaQuery.of(context).size.width;

                      final dx = _.globalPosition.dx - _panDownX;

                      _currentPageIndexAnimationController.value =
                          _primaryPageIndex - dx / width;

                      // print(
                      //   'horizontal drag! page = ${_currentPageIndexAnimationController.value}',
                      // );
                    },
                    onHorizontalDragEnd: (_) {
                      final nextPage = _currentPageIndexAnimationController
                          .value
                          .round()
                          .clamp(0, widget.cardCount);
                      _currentPageIndexAnimationController
                          .animateTo(nextPage.toDouble(),
                              duration: Duration(milliseconds: 100))
                          .orCancel
                          .then((_) {
                        setState(() {
                          _primaryPageIndex = nextPage;
                        });
                      });
                    },
                    onVerticalDragUpdate: isCenteredCard
                        ? (x) {
                            final safeAreaTop =
                                MediaQuery.of(context).padding.top;
                            final height = MediaQuery.of(context).size.height;
                            // final top2 = MediaQuery.of(context).viewInsets.top;

                            // print(
                            //     'safeAreaTop = $safeAreaTop, _panDownY = $_panDownY ');

                            //  + safeAreaTop

                            if (x.globalPosition.dy > _panDownY) {
                              final dYInDismissDirection =
                                  x.globalPosition.dy - _panDownY;
                              // setState(() {
                              // });

                              // _primarySnapAnimationController.value = 0;
                              _primarySnapAnimationController.value =
                                  -(dYInDismissDirection /
                                          (height - safeAreaTop))
                                      .clamp(0.0, 1.0);

                              // _centerCardProgress = 0;
                              // _dismissProgress =

                            } else {
                              final dYInSnapDirection =
                                  _panDownY - x.globalPosition.dy;
                              final totalDistanceTilSnap =
                                  _panDownY - safeAreaTop;

                              // print(
                              //   'dYInDirection = $dYInSnapDirection, totalDistanceTilSnap = $totalDistanceTilSnap',
                              // );

                              _primarySnapAnimationController.value =
                                  (dYInSnapDirection / totalDistanceTilSnap)
                                      .clamp(0.0, 1.0);
                            }

                            // final p = (_panDownY - x.globalPosition.dy).clamp(0, 0);
                            // print('pan move ${p}');

                            // print('pan mov 1e ${}');

                            //     reportOffset(-x.globalPosition.dy + 50);
                          }
                        : null,
                    onVerticalDragEnd: (details) {
                      final animationValue =
                          _primarySnapAnimationController.value;
                      // print(
                      //   'END = ${details.primaryVelocity}, animationValue = $animationValue',
                      // );

                      /* TODO: take velocity into account */
                      if (animationValue > 0.5) {
                        _primarySnapAnimationController.animateTo(
                          1,
                          duration: Duration(milliseconds: 200),
                        );
                      } else if (animationValue < -0.5) {
                        _primarySnapAnimationController
                            .animateTo(
                              -1,
                              duration: Duration(milliseconds: 200),
                            )
                            .orCancel
                            .then((_) {
                          Navigator.of(context).pop();
                        });
                      } else {
                        _primarySnapAnimationController.animateTo(
                          0,
                          duration: Duration(milliseconds: 200),
                        );
                      }

                      // if (details.primaryVelocity > 0) {
                      //   // downwards

                      // }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: isCenteredCard
                            ? containerWidth *
                                0.05 *
                                (1 - primaryCardSnapProgress)
                            : containerWidth * 0.05,
                        top: isCenteredCard
                            ? 50 * (1 - primaryCardSnapProgress)
                            : 50,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                            isCenteredCard
                                ? 10.0 * (1 - primaryCardSnapProgress)
                                : 10.0,
                          ),
                          topRight: Radius.circular(
                            isCenteredCard
                                ? 10.0 * (1 - primaryCardSnapProgress)
                                : 10.0,
                          ),
                        ),
                        child: Container(
                          child: child,
                          width: isCenteredCard
                              ? containerWidth *
                                  (0.9 + 0.1 * primaryCardSnapProgress)
                              : containerWidth * 0.9,
                        ),
                      ),
                    ),
                  ),
                  // ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // print('_currentCardOffset = $_currentCardOffset');

    // final selectedIndex = 1;

    // final containerWidth = MediaQuery.of(context).size.width;
    // final centeredCardWidthAfterScale = containerWidth *
    //     (0.9 + 0.1 * _centerCardProgress * _centerCardProgress);

    // return ListView.builder(
    //   scrollDirection: Axis.horizontal,
    //   controller: controller,
    //   physics: PageScrollPhysics(),
    //   itemBuilder: (context, index) {
    //     print('BUILDING $index');

    //     final scaleFactor = index == 1
    //         ? (0.9 + 0.1 * _centerCardProgress * _centerCardProgress)
    //         : 0.9;

    //     return Transform.translate(
    //       // offset: Offset(0, 0),
    //       offset: index == 2 ? Offset(-100, 0) : Offset(0, 0),
    //       child: Container(
    //         color: index % 2 == 0 ? Colors.yellow : Colors.lightBlue,
    //         width: containerWidth,
    //         child: Transform.scale(
    //           scale: scaleFactor,
    //           child: Container(
    //             color: index % 2 == 0 ? Colors.yellow : Colors.lightBlue,
    //             width: containerWidth, // * 0.9,
    //             // _renderCard(context, currentIndex: 0, centeredIndex: selectedIndex),
    //             height: 10,
    //             child: _renderCard(context,
    //                 currentIndex: index, centeredIndex: selectedIndex),
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    //   itemCount: 10,
    //   cacheExtent: 1,
    // );

    // return CustomScrollView(
    //   scrollDirection: Axis.horizontal,
    //   controller: controller,
    //   physics: PageScrollPhysics(),
    //   cacheExtent: 1000,
    //   slivers: <Widget>[
    //     SliverList(
    //       delegate: SliverChildBuilderDelegate(
    //         (context, index) {
    //           print('BUILDING $index');

    //           final scaleFactor = index == 1
    //               ? (0.9 + 0.1 * _centerCardProgress * _centerCardProgress)
    //               : 0.9;

    //           return Transform.translate(
    //             // offset: Offset(0, 0),
    //             offset: index == 0
    //                 ? Offset(100, 0)
    //                 : (index == 2 ? Offset(-100, 0) : Offset(0, 0)),
    //             child: Container(
    //               // color: index % 2 == 0 ? Colors.yellow : Colors.lightBlue,
    //               width: containerWidth - 0.5,
    //               child: Transform.scale(
    //                 scale: scaleFactor,
    //                 child: Container(
    //                   color:
    //                       index % 2 == 0 ? Colors.yellow : Colors.transparent,
    //                   width: containerWidth, // * 0.9,
    //                   // _renderCard(context, currentIndex: 0, centeredIndex: selectedIndex),
    //                   height: 10,
    //                   child: _renderCard(
    //                     context,
    //                     currentIndex: index,
    //                     centeredIndex: selectedIndex,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           );
    //         },
    //         childCount: 10,
    //       ),
    //     ),
    //   ],
    // );

    // return Scrollable(
    //   // dragStartBehavior: DragStartBehavior.down,
    //   axisDirection: AxisDirection.right,
    //   controller: controller,
    //   physics: PageScrollPhysics(),
    //   viewportBuilder: (BuildContext context, ViewportOffset position) {
    //     position.addListener(() {
    //       print('position changed, ${position.pixels}');
    //     });

    //     return Container(
    //       color: Colors.red,
    //       child: Text('${position.pixels}'),
    //     );
    //   },
    // );

    // SingleChildScrollView
    // ListView
    // BoxScrollView

    // return CustomScrollView(
    //   slivers: <Widget>[
    //     Container(
    //       color: Colors.red,
    //       child: Text('${1}'),
    //     )
    //   ],
    // );

    return Stack(children: [
      // PageView.builder(
      //   controller: controller,
      //   itemBuilder: (context, index) {
      //     return Container(
      //       color: Colors.transparent,
      //       // color: index % 2 == 0 ? Colors.yellow : Colors.lightBlue,
      //       // child: SizedBox.shrink(),
      //       //   child: Padding(
      //       //     padding: const EdgeInsets.all(8.0),
      //       //     child: CardPage(
      //       //       color: index % 2 == 0 ? Colors.red : Colors.blue,
      //       //       isPrimaryCard: index == _activePage,
      //       //       // current
      //       //     ),
      //       //   ),
      //     );
      //   },
      //   itemCount: 2, // widget.cards.length,
      // ),
      if (_primaryPageIndex > 0)
        _renderCard(
          context,
          currentIndex: _primaryPageIndex - 1,
          type: CardType.left,
          // centeredIndex: selectedIndex,
        ),

      if (_primaryPageIndex < widget.cardCount)
        _renderCard(
          context,
          currentIndex: _primaryPageIndex + 1,
          type: CardType.right,
          // centeredIndex: selectedIndex,
        ),

      // primary card on top
      _renderCard(
        context,
        currentIndex: _primaryPageIndex,
        type: CardType.primary,
        // centeredIndex: selectedIndex,
      ),
    ]);
  }

  @override
  void dispose() {
    super.dispose();

    // _primaryDismissAnimationController.dispose();
    _primarySnapAnimationController.dispose();
    _currentPageIndexAnimationController.dispose();

    // controller.dispose();
  }
}
