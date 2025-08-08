import 'package:byteback2/screens/update_guide_screen.dart';
import 'package:flutter/material.dart';
import 'package:byteback2/models/Guide.dart';
import 'package:byteback2/data/guide_data.dart';
import 'package:byteback2/services/image_service.dart';
import 'package:byteback2/services/guide_service.dart';
import 'package:get_it/get_it.dart';

class GuideDetailScreen extends StatefulWidget {
  final Guide guide;
  final VoidCallback? onUpdate;

  const GuideDetailScreen({super.key, required this.guide, this.onUpdate});

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  late final GuideService _guideService;
  late Guide _currentGuide;
  bool _isLiking = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _guideService = GetIt.instance<GuideService>();
    _currentGuide = widget.guide;
  }

  /// Handle like/unlike action
  Future<void> _handleLike() async {
    if (_isLiking || _currentGuide.id == null) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final success = await _guideService.toggleLikeGuide(_currentGuide.id!);

      if (success) {
        // Update the local guide object
        setState(() {
          _currentGuide = Guide(
            id: _currentGuide.id,
            title: _currentGuide.title,
            subtitle: _currentGuide.subtitle,
            image: _currentGuide.image,
            device: _currentGuide.device,
            difficulty: _currentGuide.difficulty,
            isDownloaded: _currentGuide.isDownloaded,
            isLiked: !_currentGuide.isLiked,
            isMine: _currentGuide.isMine,
            likesCount:
                _currentGuide.isLiked
                    ? _currentGuide.likesCount - 1
                    : _currentGuide.likesCount + 1,
            createdBy: _currentGuide.createdBy,
          );
        });

        // Show feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _currentGuide.isLiked ? 'Added to likes' : 'Removed from likes',
              ),
              backgroundColor: const Color(0xFF233C23),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        
        // Call onUpdate callback to refresh parent screen
        if (widget.onUpdate != null) {
          widget.onUpdate!();
        }
      } else {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update like status'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  /// Handle delete action with confirmation
  Future<void> _handleDelete() async {
    if (_isDeleting || _currentGuide.id == null) return;

    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F5E3),
          title: const Text(
            'Delete Guide',
            style: TextStyle(
              fontFamily: 'CenturyGo',
              color: Color(0xFF233C23),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${_currentGuide.title}"? This action cannot be undone.',
            style: const TextStyle(
              fontFamily: 'CenturyGo',
              color: Color(0xFF233C23),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'CenturyGo',
                  color: Color(0xFF233C23),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'CenturyGo',
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await _guideService.deleteGuide(_currentGuide.id!);

      if (success) {
        // Show success message and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Guide deleted successfully'),
              backgroundColor: Color(0xFF233C23),
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back to previous screen
          Navigator.of(context).pop();
        }
      } else {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete guide'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

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
                        child: Center(child: _buildGuideImage()),
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
                            Navigator.pushReplacementNamed(context, '/main');
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
                          if (_currentGuide.isMine) ...[
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
                                        (context) => UpdateGuideScreen(
                                          guide: _currentGuide,
                                        ),
                                  ),
                                );
                              },
                            ),
                            // Delete button
                            IconButton(
                              icon:
                                  _isDeleting
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                      ),
                              onPressed: _isDeleting ? null : _handleDelete,
                            ),
                          ],
                          // Like button
                          IconButton(
                            icon:
                                _isLiking
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Icon(
                                      _currentGuide.isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          _currentGuide.isLiked
                                              ? Colors.red
                                              : Colors.white,
                                    ),
                            onPressed: _isLiking ? null : _handleLike,
                          ),
                          // Download button
                          IconButton(
                            icon: Icon(
                              _currentGuide.isDownloaded
                                  ? Icons.download_done
                                  : Icons.download_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              GuideData.toggleDownload(_currentGuide.title);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xFFF8F5E3),
                                    title: Text(
                                      _currentGuide.isDownloaded
                                          ? 'Removed from Downloads'
                                          : 'Added to Downloads',
                                      style: const TextStyle(
                                        fontFamily: 'CenturyGo',
                                        color: Color(0xFF233C23),
                                      ),
                                    ),
                                    content: Text(
                                      _currentGuide.isDownloaded
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
                            _currentGuide.difficulty == 'Easy'
                                ? Colors.green[300]
                                : _currentGuide.difficulty == 'Medium'
                                ? Colors.yellow[300]
                                : Colors.red[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _currentGuide.difficulty,
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
                            _currentGuide.device == 'Laptop'
                                ? Icons.laptop_chromebook_outlined
                                : Icons.desktop_windows_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _currentGuide.device,
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
                      _currentGuide.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'CenturyGo',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentGuide.subtitle,
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
                          'Created by ${_currentGuide.createdBy}',
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

  /// Builds the appropriate image widget for the guide
  /// Handles both asset images and base64 data URLs
  Widget _buildGuideImage() {
    if (ImageService.isValidBase64DataUrl(_currentGuide.image)) {
      // Handle base64 data URL
      return ImageService.base64ToImage(
        _currentGuide.image,
        height: 250,
        fit: BoxFit.contain,
        placeholder: Container(
          height: 250,
          color: Colors.grey[300],
          child: const Icon(Icons.image, color: Colors.grey, size: 80),
        ),
      );
    } else if (_currentGuide.image.startsWith('http')) {
      // Handle network images
      return Image.network(
        _currentGuide.image,
        height: 250,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 250,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 80),
          );
        },
      );
    } else {
      // Handle asset images
      return Image.asset(
        _currentGuide.image,
        height: 250,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 250,
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey, size: 80),
          );
        },
      );
    }
  }
}
