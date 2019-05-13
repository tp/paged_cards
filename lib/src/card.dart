import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardPage extends StatelessWidget {
  const CardPage({
    Key key,
    @required this.color,
    @required this.isPrimaryCard,
  }) : super(key: key);

  final Color color;

  final bool isPrimaryCard;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: isPrimaryCard ? null : NeverScrollableScrollPhysics(),
      child: Container(
        height: 1000,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 5,
            right: 5,
            bottom: 20,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 100,
              height: 100,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
