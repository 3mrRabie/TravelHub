import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/navigation/hotels/presentation/widgets/custom_button.dart';
import 'package:travel_hub/navigation/hotels/presentation/widgets/custom_field.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController destination = TextEditingController();
  final TextEditingController checkIn = TextEditingController();
  final TextEditingController checkOut = TextEditingController();
  final TextEditingController guests = TextEditingController();
  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();

  late DateTime todayDate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    todayDate = DateTime(today.year, today.month, today.day);
  }

  @override
  void dispose() {
    destination.dispose();
    checkIn.dispose();
    checkOut.dispose();
    guests.dispose();
    fullName.dispose();
    email.dispose();
    phoneNumber.dispose();
    super.dispose();
  }

  Future<void> selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _onBookingComplete() {
    if (!formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.all(28.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated check-mark circle
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 56.r),
              ),
              SizedBox(height: 20.h),
              Text(
                "Booking Confirmed!".tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                "booking_demo_note".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 8.h),
              // Summary row
              _summaryRow(Icons.hotel, destination.text),
              _summaryRow(Icons.login_rounded, checkIn.text),
              _summaryRow(Icons.logout_rounded, checkOut.text),
              _summaryRow(Icons.people, '${guests.text} guest(s)'.tr()),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBackgroundColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // close dialog
                    _clearForm();
                    Navigator.pop(context); // back to hotel details
                  },
                  child: Text(
                    "Done".tr(),
                    style: TextStyle(
                        color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 18.r, color: kBackgroundColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    destination.clear();
    checkIn.clear();
    checkOut.clear();
    guests.clear();
    fullName.clear();
    email.clear();
    phoneNumber.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Book Your Trip".tr(),
              style: TextStyle(color: Colors.white, fontSize: 24.sp),
            ),
            Text(
              "Complete your reservation".tr(),
              style: TextStyle(
                  color: const Color(0xffDBEAFE), fontSize: 16.sp),
            ),
          ],
        ),
      ),
      // Use theme background so dark mode works correctly
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              CustomField(
                title: "Destination".tr(),
                width: double.infinity,
                controller: destination,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please enter city or hotel name".tr()
                    : null,
                hint: "Enter city or hotel name".tr(),
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomField(
                      title: "Check-in".tr(),
                      width: double.infinity,
                      controller: checkIn,
                      keyboard: TextInputType.datetime,
                      onTap: () => selectDate(context, checkIn),
                      validator: _validateDate,
                      icon: Icons.calendar_today,
                      hint: "DD/MM/YYYY",
                    ),
                  ),
                  Expanded(
                    child: CustomField(
                      title: "Check-out".tr(),
                      width: double.infinity,
                      controller: checkOut,
                      keyboard: TextInputType.datetime,
                      onTap: () => selectDate(context, checkOut),
                      validator: _validateDate,
                      icon: Icons.calendar_today,
                      hint: "DD/MM/YYYY",
                    ),
                  ),
                ],
              ),
              CustomField(
                title: "Guests".tr(),
                width: double.infinity,
                controller: guests,
                keyboard: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please enter the number of guests".tr()
                    : null,
                icon: Icons.people_alt_outlined,
              ),
              Divider(
                  color: const Color(0xffF3F3F5), thickness: 2.h),
              Text(
                "Contact Information".tr(),
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 18.sp),
              ),
              SizedBox(height: 12.h),
              CustomField(
                title: "Full Name".tr(),
                width: double.infinity,
                controller: fullName,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please enter your full name".tr()
                    : null,
                hint: "Enter your full name".tr(),
              ),
              CustomField(
                title: "Email".tr(),
                width: double.infinity,
                controller: email,
                keyboard: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email".tr();
                  } else if (!value.contains("@")) {
                    return "Please enter a valid email".tr();
                  }
                  return null;
                },
                hint: "Enter your email".tr(),
              ),
              CustomField(
                title: "Phone Number".tr(),
                width: double.infinity,
                controller: phoneNumber,
                keyboard: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your phone number".tr();
                  } else if (!RegExp(r'^01[0-9]{9}$').hasMatch(value)) {
                    return 'Please enter a valid Egyptian phone number'.tr();
                  }
                  return null;
                },
                hint: "Enter your phone number".tr(),
              ),
              SizedBox(height: 8.h),
              CustomButton(
                buttonText: "Complete Booking".tr(),
                icon: Icons.payment,
                onPressed: _onBookingComplete,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a check in date".tr();
    }
    try {
      final d = DateFormat('dd/MM/yyyy').parseStrict(value);
      if (d.isBefore(todayDate)) {
        return "Check in date can't be before today".tr();
      }
    } catch (_) {
      return "The date format is incorrect".tr();
    }
    return null;
  }
}
