import 'package:byteback2/screens/update_guide_screen.dart';
import 'package:flutter/material.dart';
import 'package:byteback2/models/Guide.dart';
import 'package:byteback2/data/guide_data.dart';

class GuideDetailScreen extends StatelessWidget {
  final Guide guide;

  const GuideDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top image and overlayed buttons
              SizedBox(
                height: 340,
                child: Stack(
                  children: [
                    Positioned(
                      top: 90,
                      left: 73,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Image.asset(
                            guide.image,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    // Back button
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                      ),
                    ),
                    // Action buttons (like and download)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          if (guide.isMine) ...[
                            // Edit button
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            UpdateGuideScreen(guide: guide),
                                  ),
                                );
                              },
                            ),
                            // Delete button
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Show confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: const Color(0xFFF8F5E3),
                                      title: const Text(
                                        'Delete Guide',
                                        style: TextStyle(
                                          fontFamily: 'CenturyGo',
                                          color: Color(0xFF233C23),
                                        ),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this guide?',
                                        style: TextStyle(
                                          fontFamily: 'CenturyGo',
                                          color: Color(0xFF233C23),
                                        ),
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
                                            // Delete the guide
                                            GuideData.removeGuide(guide.title);
                                            Navigator.of(
                                              context,
                                            ).pop(); // Close dialog
                                            Navigator.of(
                                              context,
                                            ).pop(); // Go back to previous screen
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontFamily: 'CenturyGo',
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                          // Like button
                          IconButton(
                            icon: Icon(
                              guide.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: guide.isLiked ? Colors.red : Colors.white,
                            ),
                            onPressed: () {
                              GuideData.toggleLike(guide.title);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xFFF8F5E3),
                                    title: Text(
                                      guide.isLiked
                                          ? 'Removed from Likes'
                                          : 'Added to Likes',
                                      style: const TextStyle(
                                        fontFamily: 'CenturyGo',
                                        color: Color(0xFF233C23),
                                      ),
                                    ),
                                    content: Text(
                                      guide.isLiked
                                          ? 'The guide has been removed from your likes.'
                                          : 'The guide has been added to your likes.',
                                      style: const TextStyle(
                                        fontFamily: 'CenturyGo',
                                        color: Color(0xFF233C23),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'OK',
                                          style: TextStyle(
                                            fontFamily: 'CenturyGo',
                                            color: Color(0xFF233C23),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          // Download button
                          IconButton(
                            icon: Icon(
                              guide.isDownloaded
                                  ? Icons.download_done
                                  : Icons.download_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              GuideData.toggleDownload(guide.title);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xFFF8F5E3),
                                    title: Text(
                                      guide.isDownloaded
                                          ? 'Guide Removed'
                                          : 'Guide Downloaded',
                                      style: const TextStyle(
                                        fontFamily: 'CenturyGo',
                                        color: Color(0xFF233C23),
                                      ),
                                    ),
                                    content: Text(
                                      guide.isDownloaded
                                          ? 'The guide has been removed from your downloads.'
                                          : 'The guide has been added to your downloads.',
                                      style: const TextStyle(
                                        fontFamily: 'CenturyGo',
                                        color: Color(0xFF233C23),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'OK',
                                          style: TextStyle(
                                            fontFamily: 'CenturyGo',
                                            color: Color(0xFF233C23),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Difficulty and device badges
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 24, right: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            guide.difficulty == 'Easy'
                                ? Colors.green[300]
                                : guide.difficulty == 'Medium'
                                ? Colors.yellow[300]
                                : Colors.red[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        guide.difficulty,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'CenturyGo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            guide.device == 'Laptop'
                                ? Icons.laptop_chromebook_outlined
                                : Icons.desktop_windows_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            guide.device,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'CenturyGo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Title, subtitle, and created by
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'CenturyGo',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      guide.subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'CenturyGo',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Created by section
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Created by ${guide.createdBy}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'CenturyGo',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
