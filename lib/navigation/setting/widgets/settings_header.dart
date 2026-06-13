import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/cubit/theme_cubit.dart';

/// Header for the Settings screen.
/// Reads ThemeCubit directly — no isDarkMode / onToggleTheme props needed.
class SettingsHeader extends StatefulWidget {
  const SettingsHeader({super.key});

  @override
  State<SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<SettingsHeader> {
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
      final base64Image =
          prefs.getString('profile_image_base64_${user.email}');
      if (base64Image != null) {
        savedMemoryImage = base64Decode(base64Image);
      } else {
        savedMemoryImage = null;
        localImage = null;
        savedImageUrl = user.photoURL;
      }
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext sheetContext) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text('Camera'.tr()),
                  onTap: () =>
                      Navigator.pop(sheetContext, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: Text('Gallery'.tr()),
                  onTap: () =>
                      Navigator.pop(sheetContext, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;
      final XFile? pickedFile =
          await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        localImage = File(pickedFile.path);
        savedMemoryImage = bytes;
      });

      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        await prefs.setString(
            'profile_image_base64_${user.email}', base64Image);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("profile_images")
            .child("${user.uid}.jpg");
        await storageRef.putFile(localImage!);
        final downloadURL = await storageRef.getDownloadURL();
        await user.updatePhotoURL(downloadURL);
        await user.reload();
        setState(() => savedImageUrl = downloadURL);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Profile picture has been updated successfully".tr()),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // BlocBuilder listens to ThemeCubit so the button updates the instant
    // the theme flips — even if this widget was built before the toggle.
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDark) {
        return Container(
          padding: EdgeInsetsDirectional.all(20.r),
          color: theme.appBarTheme.backgroundColor,
          child: Row(
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  CircleAvatar(
                    radius: 35.r,
                    backgroundColor: kGrey.shade300,
                    backgroundImage: savedMemoryImage != null
                        ? MemoryImage(savedMemoryImage!)
                        : localImage != null
                            ? FileImage(localImage!)
                            : savedImageUrl != null
                                ? NetworkImage(savedImageUrl!)
                                : null,
                    child: (localImage == null &&
                            savedMemoryImage == null &&
                            savedImageUrl == null)
                        ? Icon(Icons.person, size: 35.r)
                        : null,
                  ),
                  InkWell(
                    onTap: pickAndUploadImage,
                    child: Container(
                      width: 25.w,
                      height: 25.h,
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt,
                          color: kWhite, size: 18.r),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 15.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      userEmail ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.7),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              // Toggle button — calls ThemeCubit.toggleTheme() directly
              InkWell(
                onTap: () =>
                    context.read<ThemeCubit>().toggleTheme(),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 12.h,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? kGrey[800] : kGrey[200],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        size: 20.w,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        isDark
                            ? "light_mode".tr()
                            : "dark_mode".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color:
                              isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
