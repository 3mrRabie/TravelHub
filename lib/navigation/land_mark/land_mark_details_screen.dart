import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_hub/core/custom_app_bar.dart';
import 'package:travel_hub/core/utils/app_router.dart';
import 'package:travel_hub/navigation/land_mark/data/carousel_slider_cubit/carousel_slider_cubit.dart';
import 'package:travel_hub/navigation/land_mark/models/land_mark_model.dart';
import 'package:travel_hub/navigation/land_mark/widgets/ai_photo_card.dart';

class LandMarkDetailsScreen extends StatelessWidget {
  final LandMark landMark;
  LandMarkDetailsScreen(this.landMark, {super.key});
  final CarouselSliderController controller = CarouselSliderController();
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final textColor = theme.textTheme.bodyMedium?.color;
        final List<String> images = [
          landMark.mainImage,
          ...landMark.galleryImages,
        ];
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: landMark.name,
            bottomWidget: Text(
              "Discover amazing destinations".tr(),
              style: TextStyle(
                color: textColor?.withOpacity(0.7),
                fontSize: 16.sp,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(16.r),
            child: ListView(
              children: [
                BlocBuilder<CarouselSliderCubit, int>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        CarouselSlider(
                          carouselController: controller,
                          options: CarouselOptions(
                            height: 200.h,
                            viewportFraction: 1,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                            onPageChanged: (index, reason) {
                              context.read<CarouselSliderCubit>().changePage(
                                index,
                              );
                            },
                          ),
                          items: images.map((imagePath) {
                            return Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24.r),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: imagePath,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: images.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () {
                                controller.animateToPage(entry.key);
                              },
                              child: Container(
                                width: state == entry.key ? 12.h : 8.h,
                                height: 10.h,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: state == entry.key
                                      ? theme.colorScheme.primary
                                      : theme.disabledColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        landMark.name,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.9,
                          ),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        landMark.location,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.7,
                          ),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  color: theme.cardColor,
                  elevation: 6.r,
                  shadowColor: isDark ? Colors.white24 : Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About".tr(),
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          landMark.detailedInfo,
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 16.sp,
                          ),
                        ),

                        AiPhotoCard(
                          onPressed: () => _handleCameraTap(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
