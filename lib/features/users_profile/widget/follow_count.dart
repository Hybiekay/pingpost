import 'package:flutter/material.dart';
import 'package:twiiter_clone/theme/pallete.dart';

class FollowCount extends StatelessWidget {
  final int count;
  final String text;
  const FollowCount({
    Key? key,
    required this.count,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {double fontSize = 18;
    return Row(
      children: [
        Text(
          "$count",
          style: const TextStyle(
              fontSize: 18,
              color: Pallete.whiteColor,
              fontWeight: FontWeight.bold),
        ),Text(
          text,
          style: const TextStyle(
              fontSize: 18,
              color: Pallete.greyColor,
              ),
        )
      ],
    );
  }
}
