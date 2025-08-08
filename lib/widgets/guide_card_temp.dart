import 'package:flutter/material.dart';
import 'package:byteback2/screens/guide_detail_screen.dart';
import 'package:byteback2/models/Guide.dart';
import 'package:byteback2/services/image_service.dart';

/// A reusable card widget for displaying guide previews throughout the app
/// Used in feed, library, and search results to show guide information
class GuideCard extends StatelessWidget {
  /// Complete Guide object containing all the guide data
  final Guide guide;

  const GuideCard({super.key, required this.guide});

  /// Maps device types to their corresponding icons
  IconData get _deviceIcon {
    switch (guide.device) {
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
    switch (guide.difficulty) {
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

  /// Builds the appropriate image widget based on the image source
  /// Handles both asset images and base64 data URLs
  Widget _buildImage() {
    if (ImageService.isValidBase64DataUrl(guide.image)) {
      // Handle base64 data URL
      return ImageService.base64ToImage(
        guide.image,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: Container(
          width: 80,
          height: 80,
          color: Colors.grey[300],
          child: const Icon(Icons.image, color: Colors.grey, size: 40),
        ),
      );
    } else if (guide.image.startsWith('http')) {
      // Handle network images
      return Image.network(
        guide.image,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else {
      // Handle asset images
      return Image.asset(
        guide.image,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuideDetailScreen(guide: guide),
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
                        guide.title,
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
                        guide.subtitle,
                        style: const TextStyle(
                          fontFamily: 'CenturyGo',
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Like count and author info
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: Colors.red[300],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${guide.likesCount}',
                            style: const TextStyle(
                              fontFamily: 'CenturyGo',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'by ${guide.createdBy}',
                              style: const TextStyle(
                                fontFamily: 'CenturyGo',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImage(),
                ),
              ],
            ),
          ),
          // Difficulty badge
          Positioned(
            top: 13,
            right: 7,
            child: Container(
              decoration: BoxDecoration(
                color: _difficultyColor,
                shape: BoxShape.circle,
                boxShadow: const [
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
