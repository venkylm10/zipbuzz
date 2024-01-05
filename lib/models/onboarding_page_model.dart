class OnboardingPageModel {
  String imageUrl;
  String heading;
  String subheading;
  int pageIndex;

  OnboardingPageModel({
    required this.imageUrl,
    required this.heading,
    required this.subheading,
    required this.pageIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'image_url': imageUrl,
      'heading': heading,
      'subheading': subheading,
      'page_index': pageIndex,
    };
  }

  factory OnboardingPageModel.fromMap(Map<String, dynamic> map) {
    return OnboardingPageModel(
      imageUrl: map['image_url'],
      heading: map['heading'],
      subheading: map['subheading'],
      pageIndex: map['page_index'],
    );
  }
}
