import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearching;
  final TextEditingController searchController;
  final Function(String) onSearch;

  const CustomAppBar({
    required this.title,
    required this.isSearching,
    required this.searchController,
    required this.onSearch,
    super.key,
  });
  @override
  Size get preferredSize => Size.fromHeight(
        isSearching
            ? AppBar().preferredSize.height + 60
            : AppBar().preferredSize.height,
      );

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
      height: widget.preferredSize.height + MediaQuery.of(context).padding.top,
      decoration: const BoxDecoration(
          color: Color(0xFF4A43EC),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      child: Stack(
        children: [
          AppBar(
            backgroundColor: const Color(0xFF4A43EC),
            elevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30))),
            leading: const Icon(
              Icons.pin_drop_rounded,
              size: 30,
              color: Colors.white,
            ),
            titleSpacing: -8,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "San Jose, USA",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  "94088",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                )
              ],
            ),
            actions: [
              if (!widget.isSearching)
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (!widget.isSearching) {
                      // Only call onSearch when not in searching state
                      widget.onSearch('');
                      FocusScope.of(context).requestFocus(searchFocusNode);
                    }
                  },
                ),
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Handle notification button press
                },
              ),
              const SizedBox(width: 10)
            ],
          ),
          if (widget.isSearching)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.transparent,
                child: TextField(
                  controller: widget.searchController,
                  focusNode: searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Colors.white),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: widget.onSearch,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
