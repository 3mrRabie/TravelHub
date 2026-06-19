import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/core/utils/currency_formatter.dart';
import 'package:travel_hub/navigation/hotels/models/hotels_model.dart';
import 'package:travel_hub/navigation/hotels/presentation/widgets/custom_button.dart';
import 'package:travel_hub/navigation/hotels/presentation/widgets/custom_field.dart';

class BookScreen extends StatefulWidget {
  /// The hotel to book. May be null if the screen is opened without context.
  final Hotels? hotel;

  const BookScreen({super.key, this.hotel});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _destination = TextEditingController();
  final TextEditingController _checkIn = TextEditingController();
  final TextEditingController _checkOut = TextEditingController();
  final TextEditingController _guests = TextEditingController();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  late final DateTime _today;
  bool _isSubmitting = false;

  // ── derived ──────────────────────────────────────────────────────────────
  /// Nights is always derived from the selected dates.
  /// Returns 0 when dates are not yet chosen.
  int get _nights {
    if (_checkInDate != null && _checkOutDate != null) {
      final diff = _checkOutDate!.difference(_checkInDate!).inDays;
      return diff > 0 ? diff : 0;
    }
    return 0;
  }

  double get _pricePerNight => widget.hotel?.pricePerNight ?? 0;
  double get _totalPrice => _pricePerNight * _nights;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);

    // ── Auto-fill destination from selected hotel ─────────────────────────
    if (widget.hotel != null) {
      _destination.text = widget.hotel!.name;
    }

    // Contact fields (Full Name, Email, Phone) intentionally left empty.
    // They must only contain user-entered values.
  }

  @override
  void dispose() {
    _destination.dispose();
    _checkIn.dispose();
    _checkOut.dispose();
    _guests.dispose();
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  // ── Date picker ───────────────────────────────────────────────────────────
  Future<void> _pickDate({required bool isCheckIn}) async {
    final initial = isCheckIn
        ? (_checkInDate ?? _today)
        : (_checkOutDate ?? (_checkInDate?.add(const Duration(days: 1)) ?? _today));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _today,
      lastDate: DateTime(2030),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isCheckIn) {
        _checkInDate = picked;
        _checkIn.text = DateFormat('dd/MM/yyyy').format(picked);
        // Reset check-out if it's now invalid (same day or before check-in).
        if (_checkOutDate != null && !_checkOutDate!.isAfter(picked)) {
          _checkOutDate = null;
          _checkOut.clear();
        }
      } else {
        _checkOutDate = picked;
        _checkOut.text = DateFormat('dd/MM/yyyy').format(picked);
      }
    });
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  String? _validateDestination(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a destination'.tr();
    return null;
  }

  String? _validateCheckIn(String? v) {
    if (v == null || v.isEmpty) return 'Please select a check-in date'.tr();
    if (_checkInDate == null) return 'Invalid date'.tr();
    if (_checkInDate!.isBefore(_today)) return 'Check-in cannot be in the past'.tr();
    return null;
  }

  String? _validateCheckOut(String? v) {
    if (v == null || v.isEmpty) return 'Please select a check-out date'.tr();
    if (_checkOutDate == null) return 'Invalid date'.tr();
    if (_checkInDate != null && !_checkOutDate!.isAfter(_checkInDate!)) {
      return 'Check-out must be after check-in'.tr();
    }
    return null;
  }

  // ── Booking submission ─────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Guard: dates must be chosen and produce at least 1 night.
    if (_nights < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Number of nights must be at least 1'.tr())),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to book'.tr())),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Determine dates for Firestore — may be null if user only used stepper.
      final checkInStored = _checkInDate;
      final checkOutStored = _checkOutDate;

      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user.uid,
        // ── Hotel data ──
        'hotelId': widget.hotel?.name ?? _destination.text.trim(),
        'hotelName': widget.hotel?.name ?? _destination.text.trim(),
        'destination': _destination.text.trim(),
        'pricePerNight': _pricePerNight,
        // ── Booking details ──
        'numberOfNights': _nights,
        'totalPrice': _totalPrice,
        'checkInDate': checkInStored != null
            ? DateFormat('dd/MM/yyyy').format(checkInStored)
            : _checkIn.text.trim(),
        'checkOutDate': checkOutStored != null
            ? DateFormat('dd/MM/yyyy').format(checkOutStored)
            : _checkOut.text.trim(),
        'guestCount': int.tryParse(_guests.text.trim()) ?? 1,
        // ── Contact ──
        'fullName': _fullName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        // ── Legacy / compat fields ──
        'userEmail': user.email ?? '',
        'hotelCity': widget.hotel?.city ?? '',
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showConfirmationDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'Booking failed'.tr()}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Success dialog ─────────────────────────────────────────────────────────
  void _showConfirmationDialog() {
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
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 56.r),
              ),
              SizedBox(height: 20.h),
              Text(
                'Booking Confirmed!'.tr(),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'booking_demo_note'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600], height: 1.5),
              ),
              SizedBox(height: 8.h),
              _summaryRow(Icons.hotel, _destination.text),
              _summaryRow(Icons.login_rounded, _checkIn.text),
              _summaryRow(Icons.logout_rounded, _checkOut.text),
              _summaryRow(Icons.nights_stay_outlined, '$_nights ${'night(s)'.tr()}'),
              _summaryRow(Icons.people, '${_guests.text} ${'guest(s)'.tr()}'),
              _summaryRow(
                  Icons.attach_money,
                  CurrencyFormatter.format(_totalPrice)),
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
                    Navigator.pop(ctx);
                    _clearForm();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Done'.tr(),
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
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
    _destination.clear();
    _checkIn.clear();
    _checkOut.clear();
    _guests.clear();
    _fullName.clear();
    _email.clear();
    _phone.clear();
    _checkInDate = null;
    _checkOutDate = null;
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Book Your Trip'.tr(),
              style: TextStyle(color: Colors.white, fontSize: 20.sp),
            ),
            Text(
              'Complete your reservation'.tr(),
              style: TextStyle(color: const Color(0xffDBEAFE), fontSize: 13.sp),
            ),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            // ── Destination ──────────────────────────────────────────────
            CustomField(
              title: 'Destination'.tr(),
              width: double.infinity,
              controller: _destination,
              validator: _validateDestination,
              hint: 'Enter city or hotel name'.tr(),
            ),

            // ── Dates ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: CustomField(
                    title: 'Check-in'.tr(),
                    width: double.infinity,
                    controller: _checkIn,
                    keyboard: TextInputType.none,
                    onTap: () => _pickDate(isCheckIn: true),
                    validator: _validateCheckIn,
                    icon: Icons.calendar_today,
                    hint: 'DD/MM/YYYY',
                  ),
                ),
                Expanded(
                  child: CustomField(
                    title: 'Check-out'.tr(),
                    width: double.infinity,
                    controller: _checkOut,
                    keyboard: TextInputType.none,
                    onTap: () => _pickDate(isCheckIn: false),
                    validator: _validateCheckOut,
                    icon: Icons.calendar_today,
                    hint: 'DD/MM/YYYY',
                  ),
                ),
              ],
            ),

            // ── Price summary card (updates live) ─────────────────────────
            if (widget.hotel != null && _pricePerNight > 0)
              _PriceSummaryCard(
                hotelName: widget.hotel!.name,
                pricePerNight: _pricePerNight,
                nights: _nights,
                totalPrice: _totalPrice,
                cardColor: cardColor,
              ),

            // ── Guests ───────────────────────────────────────────────────
            CustomField(
              title: 'Guests'.tr(),
              width: double.infinity,
              controller: _guests,
              keyboard: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Please enter the number of guests'.tr()
                  : null,
              icon: Icons.people_alt_outlined,
            ),

            Divider(color: const Color(0xffF3F3F5), thickness: 2.h),

            Text(
              'Contact Information'.tr(),
              style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color, fontSize: 18.sp),
            ),
            SizedBox(height: 12.h),

            CustomField(
              title: 'Full Name'.tr(),
              width: double.infinity,
              controller: _fullName,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Please enter your full name'.tr()
                  : null,
              hint: 'Enter your full name'.tr(),
            ),

            CustomField(
              title: 'Email'.tr(),
              width: double.infinity,
              controller: _email,
              keyboard: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your email address'.tr();
                if (!v.contains('@')) return 'Please enter a valid email'.tr();
                return null;
              },
              hint: 'Enter your email'.tr(),
            ),

            CustomField(
              title: 'Phone Number'.tr(),
              width: double.infinity,
              controller: _phone,
              keyboard: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your phone number'.tr();
                if (!RegExp(r'^01[0-9]{9}$').hasMatch(v)) {
                  return 'Please enter a valid Egyptian phone number'.tr();
                }
                return null;
              },
              hint: 'Enter your phone number'.tr(),
            ),

            SizedBox(height: 8.h),

            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    buttonText: 'Complete Booking'.tr(),
                    icon: Icons.payment,
                    onPressed: _submit,
                  ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}


// ─── Price Summary Card ────────────────────────────────────────────────────────


class _PriceSummaryCard extends StatelessWidget {
  final String hotelName;
  final double pricePerNight;
  final int nights;
  final double totalPrice;
  final Color cardColor;

  const _PriceSummaryCard({
    required this.hotelName,
    required this.pricePerNight,
    required this.nights,
    required this.totalPrice,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: cardColor,
      margin: EdgeInsets.symmetric(vertical: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hotel, color: kBackgroundColor, size: 20.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    hotelName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Divider(height: 20.h),
            _row('Price per night'.tr(),
                CurrencyFormatter.format(pricePerNight)),
            _row('Nights'.tr(), nights > 0 ? '$nights' : '—'),
            if (nights > 0) ...[
              const Divider(),
              _row(
                'Total Price'.tr(),
                CurrencyFormatter.format(totalPrice),
                highlight: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 15.sp : 13.sp,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? kBackgroundColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
