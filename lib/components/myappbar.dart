import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/pages/home_page.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isHomePage;
  final bool isAction;
  final String title;
  final Widget backPageDestination;
  final Widget destinationPage;

  const MyAppBar({
    super.key,
    required this.isHomePage,
    required this.isAction,
    required this.title,
    required this.destinationPage,
    this.backPageDestination = const HomePage(),
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.grey[100],
        // if homepage, no back button
        leading: isHomePage
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => backPageDestination,
                    ),
                  );
                },
              ),
        title: Text(
          title,
          style: GoogleFonts.nunitoSans(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.4,
              color: Colors.black,
            ),
          ),
        ),
        actions: isAction
            ? [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => destinationPage,
                        ),
                      );
                    },
                    child: Container(
                      width: 70,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 5.3, 7.8, 5.3),
                            width: 12,
                            height: 12,
                            child: const SizedBox(
                              width: 12,
                              height: 12,
                              child: Icon(
                                Icons.add,
                                color: Color(0xFF058B06),
                                size: 12,
                              ),
                            ),
                          ),
                          Text(
                            'Add',
                            style: GoogleFonts.nunitoSans(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.4,
                                color: Color(0xFF058B06),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
