import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/navigation/maps/presentation/views/full_map_screen.dart';
import 'package:travel_hub/navigation/maps/presentation/widgets/map_controller.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
   late final TextEditingController searchController ;
  final FullMapController mapController = FullMapController();
@override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (val) async {
          final query = val.trim();
          final result = await mapController.searchLocation(query);

          if (result != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    FullMapScreen(targetLocation: result, targetName: query),
              ),
            );
          }
        },
        decoration: InputDecoration(
          hintText: "Search destinations, hotels...".tr(),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          isDense: true,
        ),
      
    );
  }
}
