import 'package:flutter/material.dart';
import 'package:zipbuzz/widgets/home/appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearching = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Your App Title',
        isSearching: _isSearching,
        searchController: TextEditingController(),
        onSearch: (query) {
          // Handle search input
          setState(() {
            _isSearching = !_isSearching;
          });
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isSearching = false;
            });
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 10),
            child: Column(
              children: List.generate(
                  10,
                  (index) => Container(
                        height: 200,
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 20),
                        color: Colors.blue,
                      )),
            ),
          ),
        ),
      ),
    );
  }
}
