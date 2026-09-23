import 'package:flutter/material.dart';

class UserProfileImage extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const UserProfileImage({super.key, required this.imageUrl, this.radius = 40});

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (imageUrl.isEmpty) {
      imageProvider = const AssetImage('assets/images/profile.png');
    } else if (imageUrl.startsWith('http')) {
      imageProvider = NetworkImage(imageUrl);
    } else {
      imageProvider = AssetImage(imageUrl);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: imageProvider,
    );
  }
}
