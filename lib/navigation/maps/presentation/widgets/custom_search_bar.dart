import 'package:flutter/material.dart';
import 'package:travel_hub/constant.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 15,
      right: 15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kBlack.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (val) => onSearch(val.trim()),
          decoration: InputDecoration(
            hintText: "Search location...",
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon:  Icon(Icons.search,size: 20),
              onPressed: () => onSearch(controller.text.trim()),
            ),
          ),
        ),
      ),
    );
  }
}
