import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/widgets/common/back_button.dart';

class FAQsPage extends StatefulWidget {
  static const id = "/settings/faqs";
  const FAQsPage({super.key});

  @override
  State<FAQsPage> createState() => _FAQsPageState();
}

class _FAQsPageState extends State<FAQsPage> {
  late TextEditingController searchController;
  int currentQuestion = 2;
  final faqs = [
    {"question": "What is an event?", "answer": "Explaining an event."},
    {
      "question": "How do I create an event?",
      "answer": "Steps to create an event."
    },
    {
      "question": "Is there a fee for using the app?",
      "answer":
          "The app is typically free to download and use for basic features like event discovery. However, there may be fees associated with ticket purchases or premium features. Check the app's pricing or subscription details for more information."
    },
    {
      "question": "How can I find events near me?",
      "answer": "Explaining how to find events."
    },
    {
      "question": "Can I buy tickets or register for events through the app?",
      "answer": "Explaining about the event registerations and payments."
    },
  ];
  @override
  void initState() {
    searchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(),
        title: Text(
          "FAQ",
          style: AppStyles.h2.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 36,
              width: 36,
              padding: const EdgeInsets.symmetric(vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: SvgPicture.asset(Assets.icons.telephone),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                cursorColor: AppColors.primaryColor,
                style: AppStyles.h5,
                decoration: InputDecoration(
                  hintText: "Ask a question...",
                  hintStyle: AppStyles.h5.copyWith(
                    color: AppColors.lightGreyColor,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
                    child: SvgPicture.asset(
                      Assets.icons.searchBarIcon,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.borderGrey),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.borderGrey),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: AppColors.lightGreyColor),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.borderGrey),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.borderGrey),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              ListView.builder(
                itemCount: faqs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final question = faqs[index]['question']!;
                  final answer = faqs[index]['answer']!;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ExpansionTile(
                      title: Text(
                        question,
                        style: AppStyles.h4.copyWith(
                            fontWeight: currentQuestion == index
                                ? FontWeight.w600
                                : FontWeight.normal),
                      ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onExpansionChanged: (value) {
                        if (value) {
                          setState(() {
                            currentQuestion = index;
                          });
                        } else {
                          setState(() {
                            currentQuestion = -1;
                          });
                        }
                      },
                      initiallyExpanded: index == 2 ? true : false,
                      children: [
                        ListTile(
                          title: Text(
                            answer,
                            style: AppStyles.h4,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12).copyWith(top: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Didn’t find your question? ",
              style: AppStyles.h5.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              child: Ink(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    "Contact Support",
                    style: AppStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
