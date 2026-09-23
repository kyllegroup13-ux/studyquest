import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_profile_image.dart';

class CurrentUserProfileImage extends StatelessWidget {
  final double radius;

  const CurrentUserProfileImage({super.key, this.radius = 40});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return UserProfileImage(imageUrl: '', radius: radius);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircleAvatar(
            radius: radius,
            child: const CircularProgressIndicator(),
          );
        }

        final data = snapshot.data?.data();

        final String imageUrl = data?['profileImageUrl']?.toString() ?? '';

        return UserProfileImage(imageUrl: imageUrl, radius: radius);
      },
    );
  }
}
