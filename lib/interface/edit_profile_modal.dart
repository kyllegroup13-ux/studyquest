import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileModal extends StatefulWidget {
  final String currentProfileImage;

  const EditProfileModal({super.key, required this.currentProfileImage});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late String selectedImage;

  // Avatar images
  final List<String> avatarImages = [
    'assets/images/avatars/avatar_1.png',
    'assets/images/avatars/avatar_2.png',
    'assets/images/avatars/avatar_3.png',
    'assets/images/avatars/avatar_4.png',
    'assets/images/avatars/avatar_5.png',
    'assets/images/avatars/avatar_6.png',
    'assets/images/avatars/avatar_7.png',
    'assets/images/avatars/avatar_8.png',
  ];

  @override
  void initState() {
    super.initState();
    selectedImage = widget.currentProfileImage;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,

      // Rounded modal
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),

      insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(32, 25, 32, 30),

        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =================================================
              // TITLE + CLOSE
              // =================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.nunito(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close_rounded, size: 32),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================
              // CURRENT PROFILE IMAGE
              // =================================================
              Center(
                child: Container(
                  width: 135,
                  height: 135,
                  padding: const EdgeInsets.all(13),

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    border: Border.all(
                      color: const Color(0xFF999999),
                      width: 3,
                    ),
                  ),

                  child: ClipOval(
                    child: Image.asset(selectedImage, fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // CHOOSE IMAGE
              // =================================================
              _sectionTitle('Choose image'),

              const SizedBox(height: 20),

              // =================================================
              // AVATARS
              // =================================================
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                itemCount: avatarImages.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                ),

                itemBuilder: (context, index) {
                  final avatar = avatarImages[index];

                  return _avatarButton(avatar);
                },
              ),

              const SizedBox(height: 30),

              // =================================================
              // UPLOAD IMAGE TITLE
              // =================================================
              _sectionTitle('Upload image'),

              const SizedBox(height: 18),

              // =================================================
              // UPLOAD IMAGE BUTTON
              // =================================================
              GestureDetector(
                onTap: () {
                  // ImagePicker will go here
                },

                child: Container(
                  width: double.infinity,
                  height: 85,

                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    color: const Color(0xFFA8E97B),

                    borderRadius: BorderRadius.circular(13),

                    border: Border.all(
                      color: const Color(0xFF4EA520),
                      width: 2,
                    ),
                  ),

                  child: Text(
                    'Upload Image',
                    style: GoogleFonts.nunito(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // SAVE
              // =================================================
              Center(
                child: SizedBox(
                  width: 145,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      // Return selected avatar
                      Navigator.pop(context, selectedImage);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3EF),

                      foregroundColor: Colors.black,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    child: Text(
                      'Save',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SECTION TITLE
  // =============================================================

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF777777),
          ),
        ),

        const SizedBox(width: 15),

        const Expanded(child: Divider(thickness: 1, color: Color(0xFFAAAAAA))),
      ],
    );
  }

  // =============================================================
  // AVATAR
  // =============================================================

  Widget _avatarButton(String image) {
    final bool isSelected = selectedImage == image;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImage = image;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),

        padding: const EdgeInsets.all(2),

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          border: isSelected
              ? Border.all(color: const Color(0xFF65D523), width: 3)
              : null,
        ),

        child: ClipOval(
          child: Image.asset(image, width: 65, height: 65, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
