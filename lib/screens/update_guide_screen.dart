import 'package:flutter/material.dart';
import 'package:byteback2/models/Guide.dart';
import 'package:byteback2/data/guide_data.dart';

class UpdateGuideScreen extends StatefulWidget {
  final Guide guide;

  const UpdateGuideScreen({super.key, required this.guide});

  @override
  State<UpdateGuideScreen> createState() => _UpdateGuideScreenState();
}

class _UpdateGuideScreenState extends State<UpdateGuideScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _selectedDevice;
  late String _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing guide data
    _titleController = TextEditingController(text: widget.guide.title);
    _descController = TextEditingController(text: widget.guide.subtitle);
    _selectedDevice = widget.guide.device;
    _selectedDifficulty = widget.guide.difficulty;
  }

  // Show confirmation dialog
  void _showUpdateConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F5E3),
          title: const Text(
            'Update Guide',
            style: TextStyle(fontFamily: 'CenturyGo', color: Color(0xFF233C23)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please confirm the updated guide details:',
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
              onPressed: () {
                // Update the guide
                GuideData.updateGuide(
                  widget.guide.title,
                  newTitle: _titleController.text,
                  newSubtitle: _descController.text,
                  device: _selectedDevice,
                  difficulty: _selectedDifficulty,
                );

                Navigator.of(context).pop(); // Close dialog
                Navigator.pop(context); // Return to previous screen

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Guide updated successfully'),
                    backgroundColor: Color(0xFF233C23),
                  ),
                );
              },
              child: const Text(
                'Confirm',
                style: TextStyle(fontFamily: 'CenturyGo', color: Colors.green),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Image:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'CenturyGo',
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // TODO: Add image picker logic
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB6B09C),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Add Photo(s)',
                              style: TextStyle(
                                fontFamily: 'CenturyGo',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  ],
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
                    _showUpdateConfirmation();
                  },
                  child: const Text(
                    'Update Guide',
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
