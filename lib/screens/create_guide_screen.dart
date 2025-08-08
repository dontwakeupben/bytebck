import 'package:flutter/material.dart';
import 'package:byteback2/services/firebase_service.dart';
import 'package:byteback2/services/image_service.dart';

class CreateGuideScreen extends StatefulWidget {
  const CreateGuideScreen({super.key});

  @override
  State<CreateGuideScreen> createState() => _CreateGuideScreenState();
}

class _CreateGuideScreenState extends State<CreateGuideScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedDevice = 'Desktop';
  String _selectedDifficulty = 'Easy';
  bool _isUploading = false;
  String? _selectedImageBase64; // Store the selected image as base64

  // Method to select an image
  Future<void> _selectImage() async {
    try {
      final base64Image = await ImageService.pickGuideImage(context);
      if (base64Image != null) {
        setState(() {
          _selectedImageBase64 = base64Image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show confirmation dialog
  void _showUploadConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F5E3),
          title: const Text(
            'Upload Guide',
            style: TextStyle(fontFamily: 'CenturyGo', color: Color(0xFF233C23)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please confirm the guide details:',
                style: TextStyle(
                  fontFamily: 'CenturyGo',
                  color: Color(0xFF233C23),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Title: ${_titleController.text}',
                style: const TextStyle(
                  fontFamily: 'CenturyGo',
                  color: Color(0xFF233C23),
                ),
              ),
              Text(
                'Description: ${_descController.text}',
                style: const TextStyle(
                  fontFamily: 'CenturyGo',
                  color: Color(0xFF233C23),
                ),
              ),
              Text(
                'Device: $_selectedDevice',
                style: const TextStyle(
                  fontFamily: 'CenturyGo',
                  color: Color(0xFF233C23),
                ),
              ),
              Text(
                'Difficulty: $_selectedDifficulty',
                style: const TextStyle(
                  fontFamily: 'CenturyGo',
                  color: Color(0xFF233C23),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'CenturyGo',
                  color: Color(0xFF233C23),
                ),
              ),
            ),
            TextButton(
              onPressed:
                  _isUploading
                      ? null
                      : () async {
                        setState(() {
                          _isUploading = true;
                        });

                        try {
                          // Create the guide card using FirebaseService
                          final result = await _firebaseService.createGuideCard(
                            title: _titleController.text.trim(),
                            description: _descController.text.trim(),
                            imageUrl:
                                _selectedImageBase64 ??
                                'https://via.placeholder.com/300x200', // Use selected image or placeholder
                            device: _selectedDevice.toLowerCase(),
                            difficulty: _selectedDifficulty.toLowerCase(),
                          );

                          setState(() {
                            _isUploading = false;
                          });

                          if (result == null) {
                            // Success
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.pop(context); // Return to previous screen

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Guide uploaded successfully!'),
                                backgroundColor: Color(0xFF233C23),
                              ),
                            );
                          } else {
                            // Error occurred
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to upload guide: $result',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() {
                            _isUploading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
              child:
                  _isUploading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      )
                      : const Text(
                        'Confirm',
                        style: TextStyle(
                          fontFamily: 'CenturyGo',
                          color: Colors.green,
                        ),
                      ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF233C23),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Image.asset('images/logo.png', height: 40),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5E3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Title : ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'CenturyGo',
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB6B09C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: _titleController,
                                style: const TextStyle(fontFamily: 'CenturyGo'),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'How to fit a M.2 SSD',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Image:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'CenturyGo',
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Image preview and upload section
                      if (_selectedImageBase64 != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ImageService.base64ToImage(
                                  _selectedImageBase64,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton.icon(
                                    onPressed: _selectImage,
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color(0xFF233C23),
                                    ),
                                    label: const Text(
                                      'Change Image',
                                      style: TextStyle(
                                        fontFamily: 'CenturyGo',
                                        color: Color(0xFF233C23),
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedImageBase64 = null;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Remove Image',
                                      style: TextStyle(
                                        fontFamily: 'CenturyGo',
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _selectImage,
                          child: Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB6B09C),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF233C23),
                                style: BorderStyle.solid,
                                width: 2,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: Color(0xFF233C23),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to add image',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGo',
                                    fontSize: 16,
                                    color: Color(0xFF233C23),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      const Text(
                        'Description:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'CenturyGo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB6B09C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _descController,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(fontFamily: 'CenturyGo'),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'Blah blah blah...',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text(
                            'Device:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'CenturyGo',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFB6B09C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedDevice,
                                  isExpanded: true,
                                  items:
                                      ['Desktop', 'Laptop']
                                          .map(
                                            (device) => DropdownMenuItem(
                                              value: device,
                                              child: Text(
                                                device,
                                                style: TextStyle(
                                                  fontFamily: 'CenturyGo',
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDevice = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Difficulty:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'CenturyGo',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFB6B09C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedDifficulty,
                                  isExpanded: true,
                                  items:
                                      ['Easy', 'Medium', 'Hard']
                                          .map(
                                            (diff) => DropdownMenuItem(
                                              value: diff,
                                              child: Text(
                                                diff,
                                                style: TextStyle(
                                                  fontFamily: 'CenturyGo',
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDifficulty = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Extra space for the floating button
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8F5E3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    side: const BorderSide(color: Color(0xFFB6B09C)),
                  ),
                  onPressed: () {
                    if (_titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Title cannot be empty')),
                      );
                      return;
                    }
                    if (_descController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Description cannot be empty'),
                        ),
                      );
                      return;
                    }

                    // Check if user is signed in
                    if (_firebaseService.getCurrentUser() == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please sign in to create a guide'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    _showUploadConfirmation();
                  },
                  child: const Text(
                    'Upload Guide',
                    style: TextStyle(
                      color: Color(0xFF233C23),
                      fontFamily: 'CenturyGo',
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
