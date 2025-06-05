import 'package:flutter/material.dart';
import 'package:byteback2/screens/guide_detail_screen.dart';
import 'package:byteback2/models/Guide.dart';

/// A reusable card widget for displaying guide previews throughout the app
/// Used in feed, library, and search results to show guide information
class GuideCard extends StatelessWidget {
  /// Title of the guide displayed at the top of the card
  final String title;

  /// Brief description of the guide's content
  final String subtitle;

  /// Path to the guide's thumbnail image
  final String image;

  /// Difficulty level of the guide (Easy, Medium, Hard)
  /// Affects the color coding of the difficulty badge
  final String difficulty;

  /// Target device type (Laptop, Desktop)
  /// Determines which device icon to display
  final String device;

  /// Username of the guide's author
  final String createdBy;

  /// Whether the current user created this guide
  /// Affects the display of edit options
  final bool isMine;

  const GuideCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.difficulty,
    required this.device,
    required this.createdBy,
    this.isMine = false,
  });

  /// Maps device types to their corresponding icons
  IconData get _deviceIcon {
    switch (device) {
      case 'Laptop':
        return Icons.laptop_chromebook_outlined;
      case 'Desktop':
        return Icons.desktop_windows_outlined;
      default:
        return Icons.computer_outlined;
    }
  }

  /// Maps difficulty levels to their corresponding colors
  /// Used for the difficulty badge background
  Color get _difficultyColor {
    switch (difficulty) {
      case 'Easy':
        return Colors.green[300] ?? Colors.green;
      case 'Medium':
        return Colors.yellow[300] ?? Colors.yellow;
      case 'Hard':
        return Colors.red[300] ?? Colors.red;
      default:
        return Colors.grey[300] ?? Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => GuideDetailScreen(
                  guide: Guide(
                    title: title,
                    subtitle: subtitle,
                    image: image,
                    difficulty: difficulty,
                    device: device,
                    createdBy: createdBy,
                    isMine: isMine,
                  ),
                ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            height: 120, // Fixed height for consistency
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5E3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'CenturyGo',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'CenturyGo',
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 13,
            right: 7,
            child: Container(
              decoration: BoxDecoration(
                color: _difficultyColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Icon(_deviceIcon, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
