import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
 

   const AboutScreen({super.key,});

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
    return Scaffold(
     backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('About App'),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          """
🏨 Hotel Booking & AI Travel Assistant App

This app allows users to:
- Browse hotels around the world.
- Book and manage reservations easily.
- Use AI-powered tools to recognize historical landmarks just by taking a photo.
- View detailed descriptions, reviews, and photos for each location.

💡 Powered by Firebase
All user data (email, profile image, etc.) are securely stored using Firebase Authentication, Firestore, and Storage.

🌍 AI Model Integration
The built-in AI model identifies monuments, ancient sites, and cultural places from images — providing educational insights and fun facts instantly!

🔧 Tech Stack
- Flutter (Frontend)
- Firebase (Backend)
- Cloud Storage for Images
- Firestore Database

📱 App Version: 1.0.0  
👨‍💻 Developed by:

 Abdelrahman Elsedemy
 
Abdallah Aboelola

Abdelrahman Ashraf

Wafaa Yousry

Wafaa Sakr


Thank you for using our app! 
Enjoy exploring the world with the power of AI and smart booking!
          """,
          style: TextStyle(
            fontSize: 18,
            color: theme.textTheme.bodyMedium?.color,
            height: 1.8,
          ),
        ),
      ),
    );
  }
}
