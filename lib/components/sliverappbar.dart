import 'package:flutter/material.dart';

class MySliverAppBar extends StatelessWidget {
  final bool homepage;
  final Widget title;
  const MySliverAppBar(
      {super.key, required this.homepage, required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      collapsedHeight: 120,
      floating: false,
      pinned: true,
      // if at homepage, don't show leading
      leading: homepage ? null : const Icon(Icons.arrow_back),
      title: title,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add),
        ),
      ],
      backgroundColor: Colors.grey[300],
    );
  }
}
