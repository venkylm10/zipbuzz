import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zipbuzz/models/user/faq_model.dart';
import 'package:zipbuzz/services/dio_services.dart';
import 'package:zipbuzz/utils/constants/colors.dart';
import 'package:zipbuzz/utils/constants/styles.dart';
import 'package:zipbuzz/utils/widgets/back_button.dart';
import 'package:zipbuzz/utils/widgets/custom_bezel.dart';
import 'package:zipbuzz/utils/widgets/custom_video_player.dart';

final _faqIndexProvider = StateProvider((ref) => -1);

class FAQsPage extends ConsumerStatefulWidget {
  static const id = "/settings/faqs";
  const FAQsPage({super.key});

  @override
  ConsumerState<FAQsPage> createState() => _FAQsPageState();
}

class _FAQsPageState extends ConsumerState<FAQsPage> {
  late TextEditingController searchController;
  @override
  void initState() {
    init();
    searchController = TextEditingController();
    super.initState();
  }

  void init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(_faqIndexProvider.notifier).state = -1;
  }

  @override
  Widget build(BuildContext context) {
    return CustomBezel(
      child: Scaffold(
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Consumer(builder: (context, ref, child) {
            final dioServices = ref.read(dioServicesProvider);
            return FutureBuilder(
                future: dioServices.getUserFaqs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Text(
                        "An error occurred. Please try again later.",
                        style: AppStyles.h4,
                      ),
                    );
                  }
                  final faqs = snapshot.data!;
                  return _buildFaqsList(faqs);
                });
          }),
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
                onTap: () {
                  launchUrlString("mailto:info@zipbuzz.me");
                },
                child: Ink(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      "Email Support",
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
      ),
    );
  }

  Widget _buildFaqsList(List<FaqModel> faqs) {
    return ListView.builder(
      itemCount: faqs.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = faqs[index];
        final question = item.question;
        final answer = item.answer;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Consumer(builder: (context, ref, child) {
            final currentQuestion = ref.watch(_faqIndexProvider);
            return ExpansionTile(
              title: Text(
                question,
                style: AppStyles.h4.copyWith(
                    fontWeight: currentQuestion == index ? FontWeight.w600 : FontWeight.normal),
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
              onExpansionChanged: (value) {
                ref
                    .read(_faqIndexProvider.notifier)
                    .update((cst) => currentQuestion == index ? -1 : index);
              },
              initiallyExpanded: false,
              children: [
                if (answer != 'zipbuzz-null')
                  ListTile(
                    title: Text(
                      answer,
                      style: AppStyles.h4,
                    ),
                  ),
                if (item.mediaUrl != 'zipbuzz-null') CustomVideoPlayer(videoUrl: item.mediaUrl),
              ],
            );
          }),
        );
      },
    );
  }
}
