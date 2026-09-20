import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cloudinary_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _usernameController =
      TextEditingController();

  String _username = '';
  String _email = '';
  String _dateJoined = '';
  String _profileImageUrl = '';

  bool _loading = true;
  bool _editingUsername = false;
  bool _savingUsername = false;
  bool _uploadingImage = false;

  static const Color green = Color(0xFF65D523);

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

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    try {
      final document = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      final data = document.data() ?? {};

      String joinedDate = 'Not available';

      final timestamp = data['dateJoined'];

      if (timestamp is Timestamp) {
        final date = timestamp.toDate();

        joinedDate =
            '${_monthName(date.month)} '
            '${date.day.toString().padLeft(2, '0')}, '
            '${date.year}';
      }

      if (!mounted) return;

      setState(() {
        _username =
            (data['username'] ?? '').toString();

        _email =
            (data['email'] ?? user.email ?? '').toString();

        _profileImageUrl =
            (data['profileImageUrl'] ?? '').toString();

        _dateJoined = joinedDate;

        _loading = false;
      });
    } catch (e) {
      debugPrint('LOAD ACCOUNT ERROR: $e');

      if (!mounted) return;

      setState(() {
        _email = user.email ?? '';
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

  // --------------------------------------------------
  // USERNAME EDITING
  // --------------------------------------------------

  void _startEditingUsername() {
    _usernameController.text = _username;

    setState(() {
      _editingUsername = true;
    });
  }

  /*void _cancelEditingUsername() {
    _usernameController.text = _username;

    setState(() {
      _editingUsername = false;
    });
  }
*/
  Future<void> _saveUsername() async {
    final newUsername =
        _usernameController.text.trim();

    if (newUsername.isEmpty) {
      return;
    }

    if (newUsername == _username) {
      setState(() {
        _editingUsername = false;
      });
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _savingUsername = true;
    });

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'username': newUsername,
      });

      if (!mounted) return;

      setState(() {
        _username = newUsername;
        _editingUsername = false;
        _savingUsername = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Username updated successfully!',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'USERNAME UPDATE ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _savingUsername = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update username: $e',
          ),
        ),
      );
    }
  }

  // --------------------------------------------------
  // PROFILE IMAGE
  // --------------------------------------------------

  Future<void> _changeProfileImage() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      final picker = ImagePicker();

      final XFile? pickedImage =
          await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _uploadingImage = true;
      });

      final imageFile =
          File(pickedImage.path);

      debugPrint(
        'Selected image: ${imageFile.path}',
      );

      final imageUrl =
          await CloudinaryService.uploadProfileImage(
        imageFile,
      );

      debugPrint(
        'Cloudinary URL: $imageUrl',
      );

      if (imageUrl == null ||
          imageUrl.isEmpty) {
        throw Exception(
          'Cloudinary did not return an image URL.',
        );
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'profileImageUrl': imageUrl,
      });

      if (!mounted) return;

      setState(() {
        _profileImageUrl = imageUrl;
        _uploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile picture updated successfully!',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'PROFILE IMAGE ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _uploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image update failed: $e',
          ),
        ),
      );
    }
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 19,
                      right: 19,
                      top: 10,
                      bottom: 25,
                    ),
                    child: Column(
                      children: [

                        // --------------------------------
                        // HEADER
                        // --------------------------------

                        SizedBox(
                          height: 52,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [

                              Align(
                                alignment:
                                    Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints:
                                      const BoxConstraints(
                                    minWidth: 35,
                                    minHeight: 35,
                                  ),
                                  icon: const Icon(
                                    Icons
                                        .arrow_back_ios_new,
                                    size: 21,
                                    color: Colors.black,
                                  ),
                                ),
                              ),

                              Text(
                                'Account',
                                style:
                                    GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // --------------------------------
                        // PROFILE IMAGE
                        // --------------------------------

                        Stack(
                          clipBehavior: Clip.none,
                          children: [

                            Container(
                              width: 94,
                              height: 94,
                              decoration:
                                  BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFFF4F4F4,
                                ),
                                border:
                                    Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child:
                                    _profileImageUrl
                                            .isNotEmpty
                                        ? Image.network(
                                            _profileImageUrl,
                                            width: 94,
                                            height: 94,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return const Icon(
                                                Icons.person,
                                                size: 55,
                                                color:
                                                    green,
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 55,
                                            color:
                                                green,
                                          ),
                              ),
                            ),

                            // Pencil button
                            Positioned(
                              right: -5,
                              bottom: -3,
                              child: Container(
                                width: 27,
                                height: 27,
                                decoration:
                                    BoxDecoration(
                                  color: Colors.white,
                                  shape:
                                      BoxShape.circle,
                                  border:
                                      Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                child: _uploadingImage
                                    ? const Padding(
                                        padding:
                                            EdgeInsets
                                                .all(
                                          6,
                                        ),
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                        ),
                                      )
                                    : IconButton(
                                        onPressed:
                                            _changeProfileImage,
                                        padding:
                                            EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 14,
                                          color:
                                              Colors.black,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // --------------------------------
                        // PROFILE TITLE
                        // --------------------------------

                        Align(
                          alignment:
                              Alignment.centerLeft,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(
                              left: 0,
                            ),
                            child: Text(
                              'Profile',
                              style:
                                  GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // --------------------------------
                        // PROFILE CARD
                        // --------------------------------

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.fromLTRB(
                            15,
                            14,
                            15,
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                              17,
                            ),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              // USERNAME LABEL
                              Text(
                                'Username',
                                style:
                                    GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(height: 5),

                              // USERNAME FIELD
                              SizedBox(
                                height: 28,
                                child: Row(
                                  children: [

                                    Expanded(
                                      child:
                                          _editingUsername
                                              ? Container(
                                                  decoration:
                                                      BoxDecoration(
                                                    color:
                                                        green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      6,
                                                    ),
                                                  ),
                                                  child:
                                                      TextField(
                                                    controller:
                                                        _usernameController,
                                                    autofocus:
                                                        true,
                                                    maxLength:
                                                        20,
                                                    textAlign:
                                                        TextAlign.center,
                                                    style:
                                                        GoogleFonts.nunito(
                                                      fontSize:
                                                          10,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          Colors.black,
                                                    ),
                                                    decoration:
                                                        const InputDecoration(
                                                      counterText:
                                                          '',
                                                      border:
                                                          InputBorder.none,
                                                      isDense:
                                                          true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical:
                                                            7,
                                                        horizontal:
                                                            5,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  alignment:
                                                      Alignment.center,
                                                  decoration:
                                                      BoxDecoration(
                                                    color:
                                                        green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      6,
                                                    ),
                                                  ),
                                                  child:
                                                      Text(
                                                    _username.isEmpty
                                                        ? 'No username'
                                                        : _username,
                                                    maxLines:
                                                        1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.nunito(
                                                      fontSize:
                                                          10,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          Colors.black,
                                                    ),
                                                  ),
                                                ),
                                    ),

                                    const SizedBox(
                                      width: 6,
                                    ),

                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            Colors.white,
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          5,
                                        ),
                                        border:
                                            Border.all(
                                          color:
                                              Colors.black,
                                          width: 1,
                                        ),
                                      ),
                                      child:
                                          _editingUsername
                                              ? _savingUsername
                                                  ? const Padding(
                                                      padding:
                                                          EdgeInsets.all(
                                                        7,
                                                      ),
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth:
                                                            1.5,
                                                      ),
                                                    )
                                                  : IconButton(
                                                      onPressed:
                                                          _saveUsername,
                                                      padding:
                                                          EdgeInsets.zero,
                                                      icon:
                                                          const Icon(
                                                        Icons.check,
                                                        size:
                                                            16,
                                                      ),
                                                    )
                                              : IconButton(
                                                  onPressed:
                                                      _startEditingUsername,
                                                  padding:
                                                      EdgeInsets.zero,
                                                  icon:
                                                      const Icon(
                                                    Icons.edit,
                                                    size:
                                                        15,
                                                  ),
                                                ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 7),

                              // EMAIL LABEL
                              Text(
                                'Email',
                                style:
                                    GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // EMAIL FIELD
                              Container(
                                width: double.infinity,
                                height: 25,
                                alignment:
                                    Alignment.center,
                                decoration:
                                    BoxDecoration(
                                  color: green,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    6,
                                  ),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    _email,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    textAlign:
                                        TextAlign.center,
                                    style:
                                        GoogleFonts.nunito(
                                      fontSize: 9,
                                      fontWeight:
                                          FontWeight.w800,
                                      color:
                                          Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 13),

                        // --------------------------------
                        // DIVIDER
                        // --------------------------------

                        const Divider(
                          color: Colors.black,
                          thickness: 1,
                          height: 1,
                        ),

                        const SizedBox(height: 8),

                        // --------------------------------
                        // ACCOUNT INFORMATION TITLE
                        // --------------------------------

                        Align(
                          alignment:
                              Alignment.centerLeft,
                          child: Text(
                            'Account Information',
                            style:
                                GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // --------------------------------
                        // ACCOUNT INFORMATION CARD
                        // --------------------------------

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.fromLTRB(
                            12,
                            13,
                            12,
                            13,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                              13,
                            ),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [

                              _infoRow(
                                'Username',
                                _username.isEmpty
                                    ? 'No username'
                                    : _username,
                              ),

                              const SizedBox(height: 10),

                              _infoRow(
                                'Email',
                                _email,
                              ),

                              const SizedBox(height: 10),

                              _infoRow(
                                'Date Joined',
                                _dateJoined,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [

        SizedBox(
          width: 82,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}