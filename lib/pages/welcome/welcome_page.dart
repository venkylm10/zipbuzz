import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/pages/sign-in/sign_in_page.dart';

class WelcomePage extends ConsumerStatefulWidget {
  static const id = '/welcome';
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  var currentPage = 0;
  late PageController pageController;
  final welcomeImages = [
    Assets.welcomeImage.welcome1,
    Assets.welcomeImage.welcome2,
    Assets.welcomeImage.welcome3,
  ];
  final pageHeadings = [
    'An event of every kind for everyone',
    'Near or far, don’t miss out any adventure',
    'New connections & adventures',
  ];

  final pageDiscriptions = [
    'Explore hundreds of events for you and your friends to attend near by. This goes into line number 3.',
    'Driver sink salmagundi run jib shot cutlass down. Yer or brethren crack piracy league brace.',
    "Deck measured spirits dead gaff jones' pin coxswain round sloop. Brace scurvy ballast lugsail arrgh on tell shrouds plate."
  ];

  void pageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void skip() async {
    await pageController.animateToPage(welcomeImages.length - 1,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    showSignInForm();
  }

  void next() async {
    if (currentPage < welcomeImages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      showSignInForm();
    }
  }

  Future<dynamic> showSignInForm() {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      builder: (context) {
        return const SignInSheet();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: welcomeImages.length,
              scrollDirection: Axis.horizontal,
              onPageChanged: (value) => pageChanged(value),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    SizedBox(
                      height: double.infinity,
                      child: Image.asset(
                        welcomeImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: size.width,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pageHeadings[currentPage],
                              style: AppStyles.h1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              pageDiscriptions[currentPage],
                              style: AppStyles.h3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          Container(
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: skip,
                  child: Text(
                    'Skip',
                    style: AppStyles.h3.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                    welcomeImages.length,
                    (index) => Container(
                      height: 6,
                      width: 6,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: index == currentPage ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: next,
                  child: Text(
                    currentPage == welcomeImages.length - 1 ? 'Finish' : 'Next',
                    style: AppStyles.h3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
