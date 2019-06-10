import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:paged_cards/paged_cards.dart';

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

    Timer.periodic(Duration(milliseconds: 36), (d) {
      setState(() {
        // _centerCardProgress = (d.tick % 120 / 60).clamp(0.0, 1.0);
      });
    });
  }

  Widget _renderCard(
    BuildContext context, {
    int currentIndex,
    type: CardType,
  }) {
    final isCenteredCard = type == CardType.primary;
    final containerWidth = MediaQuery.of(context).size.width;
    final containerHeight = MediaQuery.of(context).size.height;
    // final centeredCardWidthAfterScale = containerWidth *
    //     (0.9 + 0.1 * _centerCardProgress * _centerCardProgress);

    // positions
    // double top = isCenteredCard
    //     ? 50 * (1 - _centerCardProgress) + containerHeight * _dismissProgress
    //     : 50;

    // double singleSideLeftOver =
    //     (containerWidth - centeredCardWidthAfterScale) / 2;

    // print('singleSideLeftOver = $singleSideLeftOver');

    // double left = isCenteredCard
    //     ? 0
    //     : (currentIndex < centeredIndex
    //         ? (-containerWidth +
    //             singleSideLeftOver +
    //             singleSideLeftOver *
    //                 (0.5 - _centerCardProgress * _centerCardProgress))
    //         : containerWidth -
    //             singleSideLeftOver -
    //             singleSideLeftOver *
    //                 (0.5 - _centerCardProgress * _centerCardProgress));

    var left = 0.0;

    //  (singleSideLeftOver / 4 +
    //     (currentIndex - centeredIndex) * centeredCardWidthAfterScale);

    // print(
    //   'index = $currentIndex, left = $left, containerWidth = $containerWidth',
    // );

// Opacity

    // return Positioned(
    //   top: top,
    //   left: left,
    //   width: containerWidth,
    //   height: MediaQuery.of(context).size.height,
    //   // /   onPanDown: (_) {
    //   //     print('pan down');
    //   //   },
    //   //   onPanUpdate: (x) {
    //   //     print('pan move ${-x.globalPosition.dy + 50}');

    //   //     reportOffset(-x.globalPosition.dy + 50);
    //   //   },
    //   child:

// TODO:

    final childCard = CardPage(
      color: currentIndex % 2 == 0 ? Colors.red : Colors.blue,
      isPrimaryCard: isCenteredCard,
      onScroll: (offset) {
        setState(() {
          // _currentCardOffset = offset;
          // print('_currentCardOffset = $_currentCardOffset');
        });
      },
      builder: (context) => widget.builder(context, currentIndex),
      // current
    );

    return AnimatedBuilder(
      key: Key('$currentIndex'),
      animation: _primarySnapAnimationController,
      child: childCard,
      builder: (context, child) {
        // print('rendering with value ${_primarySnapAnimationController.value}');

        final animationValue = _primarySnapAnimationController.value;

        final primaryCardSnapProgress = animationValue > 0 ? animationValue : 0;
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
              print('nextPage = $nextPage; dx = $dx');

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
                  // scale: 0.8,
                  scale: 0.9 +
                      (isCenteredCard
                          ? (0.1 * (1 - neighborCardPaddingFactor))
                          : 0),
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

                      print(
                        'horizontal drag! page = ${_currentPageIndexAnimationController.value}',
                      );
                    },
                    onHorizontalDragEnd: (_) {
                      final nextPage = _currentPageIndexAnimationController
                          .value
                          .round()
                          .clamp(0, widget.cardCount);
                      _currentPageIndexAnimationController
                          .animateTo(nextPage.toDouble(),
                              duration: Duration(milliseconds: 100))
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

                            print(
                                'safeAreaTop = $safeAreaTop, _panDownY = $_panDownY ');

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

                              print(
                                'dYInDirection = $dYInSnapDirection, totalDistanceTilSnap = $totalDistanceTilSnap',
                              );

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
                      print(
                        'END = ${details.primaryVelocity}, animationValue = $animationValue',
                      );

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
                    child: child,
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

      // Positioned(
      //   top: 50,
      //   left: -(MediaQuery.of(context).size.width - 100) + 40,
      //   width: MediaQuery.of(context).size.width - 100,
      //   height: MediaQuery.of(context).size.height,
      //   child: CardPage(
      //     color: 0 % 2 == 0 ? Colors.red : Colors.blue,
      //     isPrimaryCard: index == _activePage,
      //     onScroll: (offset) {
      //       setState(() {
      //         _currentCardOffset = offset;
      //         print('_currentCardOffset = $_currentCardOffset');
      //       });
      //     },
      //     builder: (context) => widget.builder(context, 0),
      //     // current
      //   ),
      // ),

      // Positioned(
      //   top: 50,
      //   left: MediaQuery.of(context).size.width - 50,
      //   width: MediaQuery.of(context).size.width - 100,
      //   height: MediaQuery.of(context).size.height,
      //   // right: -100,
      //   // bottom: 0,
      //   child: CardPage(
      //     color: 2 % 2 == 0 ? Colors.red : Colors.blue,
      //     isPrimaryCard: index == _activePage,
      //     onScroll: (offset) {
      //       setState(() {
      //         _currentCardOffset = offset;
      //         print('_currentCardOffset = $_currentCardOffset');
      //       });
      //     },
      //     builder: (context) => widget.builder(context, 2),
      //     // current
      //   ),
      // )
    ]);

    // controller.viewportFraction = 1;
    // TODO: ListView.custom ?
    // FixedExtentScrollPhysics
    // https://stackoverflow.com/questions/47349784/creating-image-carousel-in-flutter
    // return Transform.scale(
    //     scale: 0.9 + (_currentCardOffset / 25) * 0.25,
    //     child: PageView.builder(
    //       physics: const PageScrollPhysics(),

    //       controller: controller,

    //       // itemExtent: 370,
    //       itemBuilder: (context, index) {
    //         return Container(
    //           // width: 360,
    //           child: CardPage(
    //             color: index % 2 == 0 ? Colors.red : Colors.blue,
    //             isPrimaryCard: index == _activePage,
    //             onScroll: (offset) {
    //               setState(() {
    //                 _currentCardOffset = offset;
    //                 print('_currentCardOffset = $_currentCardOffset');
    //               });
    //             },
    //             // current
    //           ),
    //           height: 1000,
    //         );
    //       },
    //       itemCount: widget.cards.length,
    //       scrollDirection: Axis.horizontal,
    //     ));

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

    // _primaryDismissAnimationController.dispose();
    _primarySnapAnimationController.dispose();

    // controller.dispose();
  }
}
