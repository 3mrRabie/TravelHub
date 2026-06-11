import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/navigation/home/presentation/widgets/action_button.dart';
import 'package:travel_hub/navigation/home/presentation/widgets/attractions_section.dart';
import 'package:travel_hub/navigation/home/presentation/widgets/search_field.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int)? onTabSelected;
  const HomeScreen({super.key, this.onTabSelected});

   @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? userEmail;
  File? localImage;
  String? savedImageUrl;
  Uint8List? savedMemoryImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      userName = prefs.getString('userName') ?? 'User Name';
      userEmail = prefs.getString('userEmail') ?? 'user@email.com';
    });
    if (user != null && user.email != null) {
      final base64Image = prefs.getString('profile_image_base64_${user.email}');
      if (base64Image != null) {
        savedMemoryImage = base64Decode(base64Image);
      } else {
        savedMemoryImage = null;
        localImage = null;
        savedImageUrl = user.photoURL;
      }
    }
  }

  Future<void> _handleCameraTap(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('Camera'.tr()),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: Text('Gallery'.tr()),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final selectedImage = File(pickedFile.path);

        GoRouter.of(context).push(AppRouter.kCameraView, extra: selectedImage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 15),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar:  AppBar(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25.r,
                  backgroundColor: kGrey.shade300,
                  backgroundImage: savedMemoryImage != null
                      ? MemoryImage(savedMemoryImage!)
                      : localImage != null
                      ? FileImage(localImage!)
                      : savedImageUrl != null
                      ? NetworkImage(savedImageUrl!)
                      : null,
                  child:
                      (localImage == null &&
                          savedMemoryImage == null &&
                          savedImageUrl == null)
                      ? Icon(Icons.person, size: 35.r)
                      : null,
                ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Text(
          "Welcome ,",
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,    
            color: kOrange, 
          ),
        ),
        Text(
          userName ?? "",
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize:18.sp,    
            color: kBackgroundColor,
          ),
        ),
            ],
          ),
        )
              ],
            ),
          ),
        
          body: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25.h),
                SearchField(),
                SizedBox(height: 20.h),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonWidth = (constraints.maxWidth - 16.w) / 2;
                    return Wrap(
                      spacing: 16.w,
                      runSpacing: 16.h,
                      children: [
                        ActionButton(
                          color: kBackgroundColor,
                          icon: Icons.hotel,
                          label: "Hotels".tr(),
                          onTap: () {
                            if (widget.onTabSelected != null) {
                              widget.onTabSelected!(1);
                            }
                          },
                          width: buttonWidth,
                        ),
                        ActionButton(
                          color: kOrange,
                          icon: Icons.place,
                          label: "Places to Visit".tr(),
                          onTap: () {
                            if (widget.onTabSelected != null) {
                              widget.onTabSelected!(2);
                            }
                          },
                          width: buttonWidth,
                        ),
                        ActionButton(
                          color: kGreen,
                          icon: Icons.map,
                          label: "Map".tr(),
                          onTap: () {
                            if (widget.onTabSelected != null) {
                              widget.onTabSelected!(3);
                            }
                          },
                          width: buttonWidth,
                        ),
                        ActionButton(
                          color: kPurple,
                          icon: Icons.camera_alt,
                          label: "AI Camera".tr(),
                          onTap: () => _handleCameraTap(context),
                          width: buttonWidth,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24.h),
                const AttractionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
