import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_hub/constant.dart';
import 'package:travel_hub/features/ai_camera/service/api_service.dart';
import 'package:travel_hub/features/ai_camera/service/tts_service.dart';

class AiCamera extends StatefulWidget {

  final File selectedImage; 

  const AiCamera({Key? key, required this.selectedImage}) : super(key: key);

  @override
  State<AiCamera> createState() => _AiWikiPageState();
}

class _AiWikiPageState extends State<AiCamera> {
  File? _image;
  String? _title;
  String? _summaryEn;
  String? _summaryAr;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _image = widget.selectedImage; 
  
    _analyzeImage(_image!); 
  }

  Future<void> _analyzeImage(File imageFile) async {
    setState(() {
      _loading = true;
      _title = null;
      _summaryAr = null;
      _summaryEn = null;
    });

    try {
      final res = await ApiService.sendImage(imageFile);

      setState(() {
        _loading = false;
      });

      if (res is Map && res.containsKey('error')) {
        _showError(res['error'].toString());
        return;
      }

      Map<String, dynamic>? prediction;

      if (res is List && res.isNotEmpty) {
        prediction = res.first as Map<String, dynamic>;
      } else if (res is Map) {
        prediction = res as Map<String, dynamic>;
      }

      if (prediction == null) {
        _showError("هيكل الاستجابة غير صالح. تأكدي من أن الخادم يعمل بشكل صحيح.");
        return;
      }

      final pred = prediction!; // non-nullable local for closure capture
      setState(() {
        _title = pred['label'] ?? "Unknown";
        _summaryEn = pred['wiki_english'] ?? "";
        _summaryAr = pred['wiki_arabic'] ?? "";
      });

      if (_summaryAr!.isEmpty) {
        _showError(
            "تم التعرّف على المكان: $_title، لكن لم يتم العثور على مقال له .");
      }
    } catch (e) {
      _showError("حدث خطأ غير متوقع: ${e.toString()}");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pick(ImageSource src) async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: src, imageQuality: 80);

      if (picked == null) return;

      final selectedImage = File(picked.path);

   
      setState(() {
        _image = selectedImage;
      });
      await _analyzeImage(selectedImage);

    } catch (e) {
      _showError("فشل اختيار الصورة: ${e.toString()}");
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('Camera'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _pick(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: Text('Gallery'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _pick(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton.icon(
                  onPressed: (_summaryEn != null && _summaryEn!.isNotEmpty)
                      ? () => TtsService.speak(_summaryEn!)
                      : null,
                  icon: const Icon(Icons.play_arrow),
                  label: Text('Play Audio'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: kWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton.icon(
                  onPressed: () {
                   
                    _showError(" Soon ");
                  
                  },
                  icon: const Icon(Icons.share),
                  label: Text('Share'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBackgroundColor,
                    foregroundColor: kWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: OutlinedButton.icon(
                  onPressed: () {
             
                  },
                  icon: const Icon(Icons.save),
                  label: Text('Save'.tr()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kGrey,
                    backgroundColor: kLightGrey,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
  
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton.icon(
                  onPressed: _showPicker, 
                  icon: const Icon(Icons.camera_alt),
                  label: Text('Retake'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    foregroundColor: kWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_image == null || (_loading && _title == null && _summaryAr == null)) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

  
    return Scaffold(
      body: Stack(
        children: [
        
          Image.file(
            _image!,
            height: size.height * 0.5,
            width: size.width,
            fit: BoxFit.cover,
          ),

  
          SingleChildScrollView(
            child: Column(
              children: [
               
                SizedBox(height: size.height * 0.4),

                Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        Center(
                          child: Text(
                            _loading ? 'Analyzing...'.tr() : 'AI Analysis'.tr(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
            
                        if (_loading) 
                          const Center(child: CircularProgressIndicator(color: Colors.teal)),

                        if (!_loading && _summaryAr != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_title != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Text(
                                    _title!,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              
                          
                              if (_summaryEn != null && _summaryEn!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Text(
                                    _summaryEn!,
                                    style: const TextStyle(fontSize: 15, height: 1.6),
                          
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              
                              if (_summaryAr != null && _summaryAr!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Text(
                                    _summaryAr!,
                                    style: const TextStyle(fontSize: 16, height: 1.7),
                                
                                    textAlign: TextAlign.justify,
                                  ),
                                )
                              else
                                Text(
                                  " No Arabic description found for: $_title".tr(),
                                  style: const TextStyle(color: Colors.redAccent),
                                
                                ),

                              const SizedBox(height: 10),

                           
                              _buildActionButtons(),

                              const SizedBox(height: 20),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}