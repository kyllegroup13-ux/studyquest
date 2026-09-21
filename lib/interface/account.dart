import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/account_service.dart';

// Change this import to the actual location of your CloudinaryService.

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // ============================================================
  // FIREBASE
  // ============================================================

  final AccountService _accountService = AccountService();

  final TextEditingController _usernameController = TextEditingController();

  String _username = '';
  String _email = '';
  String _dateJoined = '';
  String _profileImageUrl = '';

  bool _loading = true;
  bool _editingUsername = false;
  bool _savingUsername = false;
  bool _uploadingImage = false;

  static const Color green = Color(0xFF65D523);
  // static const Color grey = Color(0xFF999999);

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD USER DATA
  // ============================================================

  Future<void> _loadUserData() async {
    try {
      final data = await _accountService.getUserData();

      if (data == null) {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
        return;
      }

      final DateTime? date = data['dateJoined'];

      if (!mounted) return;

      setState(() {
        _username = data['username'];
        _email = data['email'];
        _profileImageUrl = data['profileImageUrl'];

        if (date != null) {
          _dateJoined =
              '${_monthName(date.month)} '
              '${date.day.toString().padLeft(2, '0')}, '
              '${date.year}';
        } else {
          _dateJoined = 'Not available';
        }

        _loading = false;
      });
    } catch (e) {
      debugPrint('LOAD ACCOUNT ERROR: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  // ============================================================
  // USERNAME EDITING
  // ============================================================

  void _startEditingUsername() {
    _usernameController.text = _username;

    setState(() {
      _editingUsername = true;
    });
  }

  Future<void> _saveUsername() async {
    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      return;
    }

    if (newUsername == _username) {
      setState(() {
        _editingUsername = false;
      });

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _savingUsername = true;
    });

    try {
      await _accountService.updateUsername(newUsername);

      if (!mounted) return;

      setState(() {
        _username = newUsername;
        _editingUsername = false;
        _savingUsername = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _savingUsername = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update username: $e')));
    }
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Future<void> _changeProfileImage() async {
    try {
      final picker = ImagePicker();

      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        _uploadingImage = true;
      });

      final imageFile = File(pickedImage.path);

      final imageUrl = await _accountService.updateProfileImage(imageFile);

      if (!mounted) return;

      setState(() {
        _profileImageUrl = imageUrl;
        _uploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _uploadingImage = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image update failed: $e')));
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(overscroll: false),

                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 27,
                    vertical: 20,
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ================================
                      // BACK BUTTON
                      // ================================

                      IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,

                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 27,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // ================================
                      // ACCOUNT TITLE
                      // ================================
                      Center(
                        child: Text(
                          'Account',
                          style: GoogleFonts.nunito(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ================================
                      // PROFILE IMAGE
                      // ================================
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,

                          children: [
                            Container(
                              width: 145,
                              height: 145,
                              padding: const EdgeInsets.all(15),

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.5,
                                ),
                              ),

                              child: ClipOval(child: _buildProfileImage()),
                            ),

                            // IMAGE EDIT BUTTON
                            Positioned(
                              right: 5,
                              bottom: 3,

                              child: GestureDetector(
                                onTap: _uploadingImage
                                    ? null
                                    : _changeProfileImage,

                                child: Container(
                                  width: 43,
                                  height: 43,

                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,

                                    border: Border.all(
                                      color: const Color(0xFFD0D0D0),
                                      width: 2,
                                    ),

                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x25000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),

                                  child: _uploadingImage
                                      ? const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: green,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.edit_outlined,
                                          size: 22,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================================
                      // PROFILE
                      // ================================
                      Center(
                        child: Text(
                          'Profile',
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ================================
                      // EDITABLE INFORMATION
                      // ================================
                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 23,
                          vertical: 28,
                        ),

                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2.5),

                          borderRadius: BorderRadius.circular(25),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // ==========================
                            // USERNAME
                            // ==========================

                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Username',
                                    style: GoogleFonts.nunito(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),

                                _buildUsernameField(),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // ==========================
                            // EMAIL
                            // ==========================
                            Text(
                              'Email',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Container(
                              width: double.infinity,
                              height: 42,

                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),

                              alignment: Alignment.center,

                              decoration: BoxDecoration(
                                color: green,
                                borderRadius: BorderRadius.circular(8),
                              ),

                              child: Text(
                                _email.isEmpty ? 'No email' : _email,

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================================
                      // ACCOUNT INFORMATION
                      // ================================
                      const Divider(color: Color(0xFF777777), thickness: 1),

                      const SizedBox(height: 5),

                      Text(
                        'Account Information',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 25,
                        ),

                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2.5),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Column(
                          children: [
                            AccountInfoRow(
                              label: 'Username',
                              value: _username.isEmpty
                                  ? 'Not available'
                                  : _username,
                            ),

                            const SizedBox(height: 20),

                            AccountInfoRow(
                              label: 'Email',
                              value: _email.isEmpty ? 'Not available' : _email,
                            ),

                            const SizedBox(height: 20),

                            AccountInfoRow(
                              label: 'Date Joined',
                              value: _dateJoined.isEmpty
                                  ? 'Not available'
                                  : _dateJoined,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ============================================================
  // PROFILE IMAGE WIDGET
  // ============================================================

  Widget _buildProfileImage() {
    if (_profileImageUrl.isNotEmpty) {
      return Image.network(
        _profileImageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,

        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: green),
          );
        },

        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/profile.png', fit: BoxFit.contain);
        },
      );
    }

    return Image.asset('assets/images/profile.png', fit: BoxFit.contain);
  }

  // ============================================================
  // USERNAME FIELD
  // ============================================================

  Widget _buildUsernameField() {
    return Container(
      height: 42,
      width: 155,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),

        border: Border.all(color: const Color(0xFFD0D0D0)),
      ),

      clipBehavior: Clip.antiAlias,

      child: Row(
        children: [
          // USERNAME / TEXT FIELD

          Expanded(
            child: Container(
              height: double.infinity,
              color: green,
              alignment: Alignment.center,

              child: _editingUsername
                  ? TextField(
                      controller: _usernameController,

                      autofocus: true,

                      textAlign: TextAlign.center,

                      textInputAction: TextInputAction.done,

                      onSubmitted: (_) {
                        _saveUsername();
                      },

                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),

                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 11,
                        ),
                      ),
                    )
                  : Text(
                      _username.isEmpty ? 'Username' : _username,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),

          // EDIT / SAVE BUTTON
          InkWell(
            onTap: _savingUsername
                ? null
                : _editingUsername
                ? _saveUsername
                : _startEditingUsername,

            child: SizedBox(
              width: 42,
              height: 42,

              child: _savingUsername
                  ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: green,
                      ),
                    )
                  : Icon(
                      _editingUsername
                          ? Icons.check_rounded
                          : Icons.edit_outlined,

                      size: 21,

                      color: Colors.black,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ACCOUNT INFORMATION ROW
// ================================================================

class AccountInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const AccountInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,

          child: Text(
            label,

            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }
}
