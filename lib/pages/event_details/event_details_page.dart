import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:zipbuzz/constants/colors.dart';
import 'package:zipbuzz/constants/styles.dart';
import 'package:zipbuzz/main.dart';
import 'package:zipbuzz/models/event_model.dart';
import 'package:zipbuzz/widgets/common/attendee_numbers.dart';
import 'package:zipbuzz/widgets/common/event_chip.dart';
import 'package:zipbuzz/widgets/event_details_page/event_buttons.dart';
import 'package:zipbuzz/widgets/event_details_page/event_details.dart';
import 'package:zipbuzz/widgets/event_details_page/event_hosts.dart';

class EventDetailsPage extends StatefulWidget {
  final EventModel event;
  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  Color dominantColor = Colors.white;
  Color eventColor = Colors.white;
  final _controller = QuillController(
    document: Document(),
    selection: const TextSelection.collapsed(offset: 0),
  );
  final aboutScrollController = ScrollController();
  String dummyText = '';

  Future<void> getDominantColor() async {
    final image = AssetImage(widget.event.bannerPath);
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      image,
    );
    dominantColor = generator.dominantColor!.color;
    setState(() {});
  }

  Future<void> getEventColor() async {
    final image = AssetImage(widget.event.iconPath);
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      image,
    );
    eventColor = generator.dominantColor!.color;
    setState(() {});
  }

  Future<void> loadQuillContentFromAsset(QuillController controller) async {
    try {
      final jsonString = await rootBundle.loadString('assets/about.json');
      final data = json.decode(jsonString);
      final delta = Delta.fromJson(data);
      final document = Document.fromDelta(delta);
      controller.document = document;
    } catch (e) {
      print('Error loading Quill content: $e');
    }
  }

  @override
  void initState() {
    getDominantColor();
    getEventColor();
    loadQuillContentFromAsset(_controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dominantColor,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leadingWidth: 0,
        leading: const SizedBox(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => navigatorKey.currentState!.pop(),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: dominantColor,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => navigatorKey.currentState!.pop(),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppColors.lightGreyColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              widget.event.bannerPath,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.event.title,
                      style: AppStyles.titleStyle,
                      softWrap: true,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        EventChip(
                          eventColor: eventColor,
                          category: widget.event.category,
                          iconPath: widget.event.iconPath,
                        ),
                        const SizedBox(width: 10),
                        AttendeeNumbers(
                          attendees: widget.event.attendees,
                          total: widget.event.maxAttendees,
                          backgroundColor: AppColors.greyColor.withOpacity(0.1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: AppColors.greyColor.withOpacity(0.2),
                      thickness: 0,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Event details",
                      style: AppStyles.h5
                          .copyWith(color: AppColors.lightGreyColor),
                    ),
                    const SizedBox(height: 16),
                    EventDetails(event: widget.event),
                    const SizedBox(height: 16),
                    Divider(
                      color: AppColors.greyColor.withOpacity(0.2),
                      thickness: 0,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Hosts",
                      style: AppStyles.h5
                          .copyWith(color: AppColors.lightGreyColor),
                    ),
                    const SizedBox(height: 16),
                    EventHosts(hosts: widget.event.hosts),
                    const SizedBox(height: 16),
                    Divider(
                      color: AppColors.greyColor.withOpacity(0.2),
                      thickness: 0,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "About",
                      style: AppStyles.h5
                          .copyWith(color: AppColors.lightGreyColor),
                    ),
                    _buildQuillEditor(),
                    const SizedBox(height: 16),
                    Divider(
                      color: AppColors.greyColor.withOpacity(0.2),
                      thickness: 0,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Sneak peaks",
                      style: AppStyles.h5
                          .copyWith(color: AppColors.lightGreyColor),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: StaggeredGrid.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: List.generate(
                          7,
                          (index) => StaggeredGridTile.count(
                            crossAxisCellCount: index % 6 == 0 ? 2 : 1,
                            mainAxisCellCount: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/about/Image-$index.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: EventButtons(event: widget.event),
    );
  }

  QuillProvider _buildQuillEditor() {
    return QuillProvider(
      configurations: QuillConfigurations(
        controller: _controller,
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale('en'),
        ),
      ),
      child: QuillEditor(
        configurations: QuillEditorConfigurations(
          readOnly: true,
          scrollable: true,
          autoFocus: false,
          expands: false,
          showCursor: false,
          padding: EdgeInsets.zero,
          scrollPhysics: const BouncingScrollPhysics(),
          customStyles: DefaultStyles(
            h1: DefaultTextBlockStyle(
              AppStyles.titleStyle,
              const VerticalSpacing(16, 0),
              const VerticalSpacing(0, 0),
              null,
            ),
            h2: DefaultTextBlockStyle(
              AppStyles.h3,
              const VerticalSpacing(16, 0),
              const VerticalSpacing(0, 0),
              null,
            ),
            h3: DefaultTextBlockStyle(
              AppStyles.h4,
              const VerticalSpacing(16, 0),
              const VerticalSpacing(0, 0),
              null,
            ),
            bold: AppStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
            paragraph: DefaultTextBlockStyle(
              AppStyles.h4,
              const VerticalSpacing(16, 0),
              const VerticalSpacing(0, 0),
              null,
            ),
            lists: DefaultListBlockStyle(
              AppStyles.h4,
              const VerticalSpacing(16, 0),
              const VerticalSpacing(0, 0),
              null,
              null,
            ),
            italic: AppStyles.h4.copyWith(
              fontStyle: FontStyle.italic,
            ),
            underline: AppStyles.h4.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
          textSelectionThemeData: TextSelectionThemeData(
            selectionHandleColor: AppColors.textColor,
            selectionColor: AppColors.textColor.withOpacity(0.1),
          ),
        ),
        scrollController: aboutScrollController,
        focusNode: FocusNode(),
      ),
    );
  }
}
