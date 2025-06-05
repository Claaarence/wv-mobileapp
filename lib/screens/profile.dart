import 'package:flutter/material.dart';
import 'navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/partnerInfo/auth_service.dart';
import '../helper/exithelper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;
  String avatarUrl = "N/A";
  final String baseUrl = "https://myspon.worldvision.org.ph/public/uploads/";

  // Controllers for the edit form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _salutationController = TextEditingController();
  final _birthdayController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await AuthService().fetchProfile();
      if (data != null) {
        setState(() {
          profileData = data;

          // Initialize form controllers with current profile data
          _nameController.text = profileData!["partnership_name"] ?? "";
          _emailController.text = profileData!["email"] ?? "";
          _addressController.text = profileData!["address"] ?? "";
          _salutationController.text = profileData!["salutation"] ?? "";
          _birthdayController.text = profileData!["birthdate"] ?? "";
        });
        debugPrint("Profile data loaded.");
      } else {
        debugPrint("No profile data fetched from API.");
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? storedAvatarUrl = prefs.getString('avatar_url');

      if (storedAvatarUrl != null && storedAvatarUrl.isNotEmpty) {
        setState(() {
          avatarUrl = baseUrl + storedAvatarUrl;
        });
        debugPrint("Loaded Avatar URL from SharedPreferences: $avatarUrl");
      } else {
        debugPrint("No Avatar URL found in SharedPreferences.");
      }
    } catch (e) {
      debugPrint("Error loading profile or avatar: $e");
    }
  }

Future<void> _pickAndUploadImage(ImageSource source) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);

  if (pickedFile != null) {
    final imageFile = File(pickedFile.path);
    final success = await AuthService().uploadAvatar(imageFile);

    _showSuccessOrErrorDialog(context, success);

    // Reload profile/avatar if needed here
  }
}

void _showSuccessOrErrorDialog(BuildContext context, bool success) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: success ? Colors.green[300] : Colors.red[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  success ? "Avatar updated successfully!" : "Failed to update avatar.",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  // Auto dismiss after 2 seconds
  Future.delayed(const Duration(seconds: 2), () {
    Navigator.of(context).pop();
  });
}
void _showImageSourceActionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    },
  );
}


void _showEditModal() {
  void _showSuccessPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Success",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Text(
                "Your Changes has been Saved!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close the success popup after 2 seconds
    });
  }

showGeneralDialog(
  context: context,
  barrierDismissible: true,
  barrierLabel: "Edit Profile",
  transitionDuration: const Duration(milliseconds: 300),
  pageBuilder: (context, anim1, anim2) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 110, 110, 110).withOpacity(0.7),
                blurRadius: 12,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFeb7f35),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Change your Profile Information",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // FORM CONTENT
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildTextField(
                        "", _nameController,
                        validatorMsg: "Name is required",
                        textColor: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      const SizedBox(height: 10),

                      const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildTextField(
                        "", _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validatorMsg: "Email is required",
                        textColor: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      const SizedBox(height: 10),

                      const Text("Address", style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildTextField(
                        "", _addressController,
                        validatorMsg: "Address is required",
                        textColor: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      const SizedBox(height: 10),

                      const Text("Salutation", style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildTextField(
                        "", _salutationController,
                        validatorMsg: "Salutation is required",
                        textColor: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      const SizedBox(height: 10),

                      const Text("Birthday", style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildTextField(
                        "", _birthdayController,
                        hintText: "YYYY-MM-DD",
                        validatorMsg: "Birthday is required",
                        textColor: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      const SizedBox(height: 25),
                        // BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFeb7f35),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final updatedData = {
                                      "partnership_name": _nameController.text.trim(),
                                      "email": _emailController.text.trim(),
                                      "address": _addressController.text.trim(),
                                      "salutation": _salutationController.text.trim(),
                                      "birthdate": _birthdayController.text.trim(),
                                    };

                                    final response = await AuthService().updateProfile(updatedData);

                                    if (response == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Failed to update profile. Please try again.")),
                                      );
                                      return;
                                    }

                                    if (response.containsKey('error')) {
                                      final errors = response['error'] as Map<String, dynamic>;
                                      String errorMessages = "";
                                      errors.forEach((field, messages) {
                                        errorMessages += messages.join(", ") + "\n";
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(errorMessages.trim())),
                                      );
                                    } else {
                                      setState(() {
                                        profileData!["partnership_name"] = updatedData["partnership_name"];
                                        profileData!["email"] = updatedData["email"];
                                        profileData!["address"] = updatedData["address"];
                                        profileData!["salutation"] = updatedData["salutation"];
                                        profileData!["birthdate"] = updatedData["birthdate"];
                                      });

                                      Navigator.of(context).pop();  // Close the edit modal
                                      _showSuccessPopup();          // Show success modal popup
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFeb7f35),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
  transitionBuilder: (context, anim1, anim2, child) {
    return FadeTransition(
      opacity: anim1,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        child: child,
      ),
    );
  },
);
  }

Widget _buildTextField(
  String label,
  TextEditingController controller, {
  TextInputType keyboardType = TextInputType.text,
  String? hintText,
  String? validatorMsg,
  Color textColor = const Color(0xFFeb7f35),
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          // ✅ Label inside the text field
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(color: textColor),
          hintStyle: TextStyle(color: textColor.withOpacity(0.7)),
          filled: true,
          fillColor: const Color.fromARGB(255, 255, 255, 255),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color.fromARGB(255, 0, 0, 0),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color.fromARGB(255, 0, 0, 0),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorMsg ?? "This field is required";
          }
          return null;
        },
      ),
    ),
  );
}





  @override
  Widget build(BuildContext context) {
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      return await showExitConfirmationDialog(context);
    });
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFeb7f35),
      drawer: const AppDrawer(selectedItem: 'Profile'),
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "Your Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          profileData == null
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                            child: avatarUrl.isEmpty
                                ? const Icon(Icons.person, size: 60, color: Colors.white)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                               _showImageSourceActionSheet(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFeb7f35),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
                                  ],
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.edit, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, -3),
                              ),
                            ],
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(16, 25, 16, bottomPadding + 30),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight + bottomPadding,
                                  ),
                                  child: IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Card(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Header with background
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFeb7f35),
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                                ),
                                                child: const Text(
                                                  "Basic Information",
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(20.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    _buildProfileInfo("👤 Name", profileData!["partnership_name"]),
                                                    _buildProfileInfo("🎩 Salutation", profileData!["salutation"]),
                                                    _buildProfileInfo("🎂 Birthdate", profileData!["birthdate"]),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Card(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFeb7f35),
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                                ),
                                                child: const Text(
                                                  "Contact Information",
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(20.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    _buildProfileInfo("🏠 Address", profileData!["address"]),
                                                    const Divider(thickness: 1, color: Color(0xFFeb7f35)),
                                                    _buildProfileInfo("📧 Email", profileData!["email"]),
                                                    const Divider(thickness: 1, color: Color(0xFFeb7f35)),
                                                    _buildProfileInfo("📅 Sponsorship Start", profileData!["start_of_sponsorship"]),
                                                    const Divider(thickness: 1, color: Color(0xFFeb7f35)),
                                                    _buildProfileInfo("📞 Phone", profileData!["phone_number"][0]["phone_number"]),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        const SizedBox(height: 20),
                                        Center(
                                          child: ElevatedButton.icon(
                                            onPressed: _showEditModal,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFeb7f35),
                                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            icon: const Icon(Icons.edit, color: Colors.white),
                                            label: const Text(
                                              "Edit Profile",
                                              style: TextStyle(fontSize: 18, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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

  Widget _buildProfileInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
