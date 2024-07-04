import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zipbuzz/models/events/event_model.dart';
import 'package:zipbuzz/utils/constants/assets.dart';
import 'package:zipbuzz/utils/constants/styles.dart';

class EventUrls extends StatelessWidget {
  const EventUrls({
    super.key,
    required this.hyperlinks,
  });
  final List<HyperLinks> hyperlinks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Builder(
        builder: (context) {
          return Wrap(
            children: List.generate(
              hyperlinks.length,
              (index) {
                var hyperLink = hyperlinks[index];
                var e = hyperLink.url;
                final last = index == hyperlinks.length - 1;
                var url = "";
                if (e.startsWith("http://") || e.startsWith("https://")) {
                  url = e;
                } else {
                  url = "http://$e";
                }
                return InkWell(
                  onTap: () {
                    launchUrlString(url);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        Assets.icons.linkClip,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          Colors.blue,
                          BlendMode.srcIn,
                        ),
                      ),
                      Text(
                        "${hyperLink.urlName} ",
                        style: AppStyles.h4.copyWith(
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                      ),
                      if (!last) const Text(" | "),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}