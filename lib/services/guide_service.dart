import 'package:byteback2/models/Guide.dart';
import 'package:byteback2/services/firebase_service.dart';
import 'package:get_it/get_it.dart';

/// Service class that adapts Firestore guide data to the local Guide model
/// This class bridges the gap between Firestore data structure and the existing Guide model
class GuideService {
  final FirebaseService _firebaseService = GetIt.instance<FirebaseService>();

  /// Converts Firestore guide data to Guide model
  Guide _mapFirestoreToGuide(Map<String, dynamic> firestoreData) {
    final currentUser = _firebaseService.getCurrentUser();
    final currentUserId = currentUser?.uid;

    // Check if current user has liked this guide
    final List<dynamic> likedBy = firestoreData['likedBy'] ?? [];
    final bool isLiked =
        currentUserId != null && likedBy.contains(currentUserId);

    return Guide(
      id: firestoreData['id'], // Include the Firestore document ID
      title: firestoreData['title'] ?? '',
      subtitle:
          firestoreData['description'] ??
          '', // Firestore uses 'description', Guide uses 'subtitle'
      image:
          firestoreData['imageUrl'] ??
          'images/guide.jpeg', // Default image if none provided
      difficulty: _capitalizeDifficulty(firestoreData['difficulty'] ?? 'easy'),
      device: _capitalizeDevice(firestoreData['device'] ?? 'desktop'),
      isDownloaded: false, // Not implemented in Firestore yet
      isLiked: isLiked,
      likesCount: firestoreData['likes'] ?? 0,
      createdBy: firestoreData['createdByName'] ?? 'Unknown',
      isMine:
          currentUserId != null && firestoreData['createdBy'] == currentUserId,
    );
  }

  /// Capitalizes the first letter of difficulty for consistency with the Guide model
  String _capitalizeDifficulty(String difficulty) {
    if (difficulty.isEmpty) return 'Easy';
    return difficulty[0].toUpperCase() + difficulty.substring(1).toLowerCase();
  }

  /// Capitalizes the first letter of device for consistency with the Guide model
  String _capitalizeDevice(String device) {
    if (device.isEmpty) return 'Desktop';
    return device[0].toUpperCase() + device.substring(1).toLowerCase();
  }

  /// Gets all guide cards from Firestore and converts them to Guide models
  Future<List<Guide>> getAllGuides() async {
    try {
      final firestoreGuides = await _firebaseService.getAllGuideCards();
      return firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();
    } catch (e) {
      print('Error getting all guides: $e');
      return [];
    }
  }

  /// Gets filtered guide cards from Firestore
  Future<List<Guide>> getFilteredGuides({
    String? device,
    String? difficulty,
    String? createdBy,
    int? limit,
  }) async {
    try {
      final firestoreGuides = await _firebaseService.getFilteredGuideCards(
        device: device?.toLowerCase(),
        difficulty: difficulty?.toLowerCase(),
        createdBy: createdBy,
        limit: limit,
      );
      return firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();
    } catch (e) {
      print('Error getting filtered guides: $e');
      return [];
    }
  }

  /// Gets guide cards created by the current user
  Future<List<Guide>> getCurrentUserGuides() async {
    try {
      final firestoreGuides = await _firebaseService.getCurrentUserGuideCards();
      return firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();
    } catch (e) {
      print('Error getting user guides: $e');
      return [];
    }
  }

  /// Gets liked guides for the current user
  Future<List<Guide>> getLikedGuides() async {
    try {
      final firestoreGuides = await _firebaseService.getUserLikedGuides();
      return firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();
    } catch (e) {
      print('Error getting liked guides: $e');
      return [];
    }
  }

  /// Toggle like status for a guide
  Future<bool> toggleLikeGuide(String guideId) async {
    try {
      final result = await _firebaseService.toggleLikeGuideCard(guideId);
      return result == null; // null means success
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  /// Delete a guide (only if user owns it)
  Future<bool> deleteGuide(String guideId) async {
    try {
      final result = await _firebaseService.deleteGuideCard(guideId);
      return result == null; // null means success
    } catch (e) {
      print('Error deleting guide: $e');
      return false;
    }
  }

  /// Gets downloaded guides for the current user
  /// Note: This is a placeholder implementation since downloaded guides aren't implemented in Firestore yet
  Future<List<Guide>> getDownloadedGuides() async {
    try {
      // For now, return an empty list since downloaded guides aren't implemented in Firestore
      // This can be extended when you implement offline/downloaded guides functionality
      return [];
    } catch (e) {
      print('Error getting downloaded guides: $e');
      return [];
    }
  }

  /// Toggles like status of a guide
  /// Note: This is a placeholder implementation
  Future<void> toggleLike(String guideId) async {
    try {
      // For now, just call the toggleLikeGuideCard method from FirebaseService
      // This increments the likes count but doesn't track user-specific likes
      await _firebaseService.toggleLikeGuideCard(guideId);
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  /// Searches guides by title or description
  Future<List<Guide>> searchGuides(String searchTerm) async {
    try {
      final firestoreGuides = await _firebaseService.searchGuideCards(
        searchTerm,
      );
      return firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();
    } catch (e) {
      print('Error searching guides: $e');
      return [];
    }
  }

  // ==================== ADVANCED SEARCH & FILTER FUNCTIONS ====================

  /// Select with filter criteria (other than identifier)
  /// Filters guides by a single field with a specific value
  Future<List<Guide>> getGuidesByDifficulty(String difficulty) async {
    try {
      final firestoreGuides = await _firebaseService.getFilteredGuideCards(
        difficulty: difficulty.toLowerCase(),
      );
      return firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();
    } catch (e) {
      print('Error getting guides by difficulty: $e');
      return [];
    }
  }

  /// Select with filter criteria (other than identifier)
  /// Filters guides by device type
  Future<List<Guide>> getGuidesByDevice(String device) async {
    try {
      final firestoreGuides = await _firebaseService.getFilteredGuideCards(
        device: device.toLowerCase(),
      );
      return firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();
    } catch (e) {
      print('Error getting guides by device: $e');
      return [];
    }
  }

  /// Select with filter criteria (other than identifier)
  /// Filters guides by creator
  Future<List<Guide>> getGuidesByCreator(String creatorId) async {
    try {
      final firestoreGuides = await _firebaseService.getFilteredGuideCards(
        createdBy: creatorId,
      );
      return firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();
    } catch (e) {
      print('Error getting guides by creator: $e');
      return [];
    }
  }

  /// Select with multiple filter criteria (same field)
  /// Gets guides that match any of the specified difficulties
  Future<List<Guide>> getGuidesByMultipleDifficulties(
    List<String> difficulties,
  ) async {
    try {
      List<Guide> allResults = [];

      // Query each difficulty separately and combine results
      for (String difficulty in difficulties) {
        final firestoreGuides = await _firebaseService.getFilteredGuideCards(
          difficulty: difficulty.toLowerCase(),
        );
        final guides =
            firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();
        allResults.addAll(guides);
      }

      // Remove duplicates by using a Set with guide IDs
      final Map<String, Guide> uniqueGuides = {};
      for (Guide guide in allResults) {
        if (guide.id != null) {
          uniqueGuides[guide.id!] = guide;
        }
      }

      return uniqueGuides.values.toList();
    } catch (e) {
      print('Error getting guides by multiple difficulties: $e');
      return [];
    }
  }

  /// Select with multiple filter criteria (same field)
  /// Gets guides that match any of the specified devices
  Future<List<Guide>> getGuidesByMultipleDevices(List<String> devices) async {
    try {
      List<Guide> allResults = [];

      // Query each device separately and combine results
      for (String device in devices) {
        final firestoreGuides = await _firebaseService.getFilteredGuideCards(
          device: device.toLowerCase(),
        );
        final guides =
            firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();
        allResults.addAll(guides);
      }

      // Remove duplicates by using a Set with guide IDs
      final Map<String, Guide> uniqueGuides = {};
      for (Guide guide in allResults) {
        if (guide.id != null) {
          uniqueGuides[guide.id!] = guide;
        }
      }

      return uniqueGuides.values.toList();
    } catch (e) {
      print('Error getting guides by multiple devices: $e');
      return [];
    }
  }

  /// Select with multiple filter criteria (different fields)
  /// Advanced filtering with multiple criteria across different fields
  Future<List<Guide>> getGuidesWithAdvancedFilters({
    String? device,
    String? difficulty,
    String? createdBy,
    List<String>? devices,
    List<String>? difficulties,
    int? minLikes,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int? limit,
  }) async {
    try {
      // If using multiple values for same field, handle separately
      if (devices != null && devices.isNotEmpty) {
        return await getGuidesByMultipleDevices(devices);
      }

      if (difficulties != null && difficulties.isNotEmpty) {
        return await getGuidesByMultipleDifficulties(difficulties);
      }

      // For single criteria, use the existing filtered method
      final firestoreGuides = await _firebaseService.getFilteredGuideCards(
        device: device?.toLowerCase(),
        difficulty: difficulty?.toLowerCase(),
        createdBy: createdBy,
        limit: limit,
      );

      List<Guide> guides =
          firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();

      // Apply additional client-side filters that aren't supported by Firestore
      if (minLikes != null) {
        guides =
            guides.where((guide) {
              // Note: This requires the likes field in the Firestore data
              final likes =
                  firestoreGuides.firstWhere(
                    (data) => data['id'] == guide.id,
                    orElse: () => {},
                  )['likes'] ??
                  0;
              return likes >= minLikes;
            }).toList();
      }

      // Date filtering would require additional Firestore queries with timestamp fields
      // This is a placeholder for when createdAt timestamps are properly indexed

      return guides;
    } catch (e) {
      print('Error getting guides with advanced filters: $e');
      return [];
    }
  }

  /// Select with sort order
  /// Gets guides sorted by creation date (newest first)
  Future<List<Guide>> getGuidesSortedByNewest({int? limit}) async {
    try {
      // Use the existing getAllGuideCards which already sorts by createdAt desc
      final firestoreGuides = await _firebaseService.getAllGuideCards();
      List<Guide> guides =
          firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();

      if (limit != null && limit > 0) {
        guides = guides.take(limit).toList();
      }

      return guides;
    } catch (e) {
      print('Error getting guides sorted by newest: $e');
      return [];
    }
  }

  /// Select with sort order
  /// Gets guides sorted by popularity (likes count)
  Future<List<Guide>> getGuidesSortedByPopularity({int? limit}) async {
    try {
      final firestoreGuides = await _firebaseService.getAllGuideCards();
      List<Map<String, dynamic>> guidesWithData = firestoreGuides;

      // Sort by likes count in descending order
      guidesWithData.sort((a, b) {
        final likesA = a['likes'] ?? 0;
        final likesB = b['likes'] ?? 0;
        return likesB.compareTo(likesA);
      });

      if (limit != null && limit > 0) {
        guidesWithData = guidesWithData.take(limit).toList();
      }

      return guidesWithData.map((data) => _mapFirestoreToGuide(data)).toList();
    } catch (e) {
      print('Error getting guides sorted by popularity: $e');
      return [];
    }
  }

  /// Select with sort order
  /// Gets guides sorted alphabetically by title
  Future<List<Guide>> getGuidesSortedByTitle({
    bool ascending = true,
    int? limit,
  }) async {
    try {
      final firestoreGuides = await _firebaseService.getAllGuideCards();
      List<Guide> guides =
          firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();

      // Sort by title
      guides.sort((a, b) {
        if (ascending) {
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        } else {
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        }
      });

      if (limit != null && limit > 0) {
        guides = guides.take(limit).toList();
      }

      return guides;
    } catch (e) {
      print('Error getting guides sorted by title: $e');
      return [];
    }
  }

  /// Select with aggregation
  /// Gets count of guides by difficulty level
  Future<Map<String, int>> getGuideCountByDifficulty() async {
    try {
      final firestoreGuides = await _firebaseService.getAllGuideCards();
      Map<String, int> counts = {'Easy': 0, 'Medium': 0, 'Hard': 0};

      for (var guide in firestoreGuides) {
        String difficulty = _capitalizeDifficulty(
          guide['difficulty'] ?? 'easy',
        );
        counts[difficulty] = (counts[difficulty] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Error getting guide count by difficulty: $e');
      return {};
    }
  }

  /// Select with aggregation
  /// Gets count of guides by device type
  Future<Map<String, int>> getGuideCountByDevice() async {
    try {
      final firestoreGuides = await _firebaseService.getAllGuideCards();
      Map<String, int> counts = {'Desktop': 0, 'Laptop': 0};

      for (var guide in firestoreGuides) {
        String device = _capitalizeDevice(guide['device'] ?? 'desktop');
        counts[device] = (counts[device] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Error getting guide count by device: $e');
      return {};
    }
  }

  /// Select with aggregation
  /// Gets total count of all guides
  Future<int> getTotalGuideCount() async {
    try {
      final firestoreGuides = await _firebaseService.getAllGuideCards();
      return firestoreGuides.length;
    } catch (e) {
      print('Error getting total guide count: $e');
      return 0;
    }
  }

  /// Select with aggregation
  /// Gets average likes per guide
  Future<double> getAverageLikesPerGuide() async {
    try {
      final firestoreGuides = await _firebaseService.getAllGuideCards();
      if (firestoreGuides.isEmpty) return 0.0;

      int totalLikes = 0;
      for (var guide in firestoreGuides) {
        totalLikes += (guide['likes'] ?? 0) as int;
      }

      return totalLikes / firestoreGuides.length;
    } catch (e) {
      print('Error getting average likes per guide: $e');
      return 0.0;
    }
  }

  /// Select with aggregation
  /// Gets statistics about guides created by the current user
  Future<Map<String, dynamic>> getCurrentUserGuideStats() async {
    try {
      final userGuides = await getCurrentUserGuides();
      final allGuides = await _firebaseService.getAllGuideCards();

      // Calculate user-specific stats
      Map<String, int> difficultyCount = {'Easy': 0, 'Medium': 0, 'Hard': 0};
      Map<String, int> deviceCount = {'Desktop': 0, 'Laptop': 0};
      int totalLikes = 0;

      for (var guide in userGuides) {
        difficultyCount[guide.difficulty] =
            (difficultyCount[guide.difficulty] ?? 0) + 1;
        deviceCount[guide.device] = (deviceCount[guide.device] ?? 0) + 1;

        // Find corresponding Firestore data to get likes
        final firestoreData = allGuides.firstWhere(
          (data) => data['id'] == guide.id,
          orElse: () => {},
        );
        totalLikes += (firestoreData['likes'] ?? 0) as int;
      }

      return {
        'totalGuides': userGuides.length,
        'totalLikes': totalLikes,
        'averageLikes':
            userGuides.isNotEmpty ? totalLikes / userGuides.length : 0.0,
        'difficultyBreakdown': difficultyCount,
        'deviceBreakdown': deviceCount,
      };
    } catch (e) {
      print('Error getting user guide stats: $e');
      return {};
    }
  }

  // ==================== ENHANCED CRUD OPERATIONS ====================

  // ==================== ENHANCED CRUD OPERATIONS ====================

  /// CREATE: Creates a new guide with comprehensive validation
  Future<String?> createGuide({
    required String title,
    required String description,
    required String imageUrl, // Can be base64 data URL or regular URL
    required String device,
    required String difficulty,
  }) async {
    try {
      // Validate input data
      if (title.trim().isEmpty) {
        return 'Title cannot be empty';
      }
      if (description.trim().isEmpty) {
        return 'Description cannot be empty';
      }
      if (!['desktop', 'laptop'].contains(device.toLowerCase())) {
        return 'Device must be either Desktop or Laptop';
      }
      if (!['easy', 'medium', 'hard'].contains(difficulty.toLowerCase())) {
        return 'Difficulty must be Easy, Medium, or Hard';
      }

      // Use provided imageUrl (can be base64 or regular URL)
      String finalImageUrl = imageUrl.trim();
      if (finalImageUrl.isEmpty) {
        finalImageUrl = 'https://via.placeholder.com/300x200';
      }

      return await _firebaseService.createGuideCard(
        title: title.trim(),
        description: description.trim(),
        imageUrl: finalImageUrl,
        device: device.toLowerCase(),
        difficulty: difficulty.toLowerCase(),
      );
    } catch (e) {
      print('Error creating guide: $e');
      return 'Error creating guide: $e';
    }
  }

  /// CREATE: Bulk create multiple guides
  Future<List<String?>> createMultipleGuides(
    List<Map<String, String>> guidesData,
  ) async {
    List<String?> results = [];

    for (var guideData in guidesData) {
      final result = await createGuide(
        title: guideData['title'] ?? '',
        description: guideData['description'] ?? '',
        imageUrl: guideData['imageUrl'] ?? '',
        device: guideData['device'] ?? 'desktop',
        difficulty: guideData['difficulty'] ?? 'easy',
      );
      results.add(result);
    }

    return results;
  }

  /// READ: Get a single guide by ID with error handling
  Future<Guide?> getGuideById(String guideId) async {
    try {
      final firestoreData = await _firebaseService.getGuideCard(guideId);
      if (firestoreData != null) {
        return _mapFirestoreToGuide(firestoreData);
      }
      return null;
    } catch (e) {
      print('Error getting guide by ID: $e');
      return null;
    }
  }

  /// READ: Get guides with pagination support
  Future<List<Guide>> getGuidesPaginated({
    int limit = 10,
    int offset = 0,
    String? device,
    String? difficulty,
  }) async {
    try {
      final firestoreGuides = await _firebaseService.getFilteredGuideCards(
        device: device?.toLowerCase(),
        difficulty: difficulty?.toLowerCase(),
        limit: limit,
      );

      // Apply offset manually since Firestore doesn't support offset directly
      List<Guide> guides =
          firestoreGuides.map((data) => _mapFirestoreToGuide(data)).toList();

      if (offset > 0 && offset < guides.length) {
        guides = guides.sublist(offset);
      }

      return guides;
    } catch (e) {
      print('Error getting paginated guides: $e');
      return [];
    }
  }

  /// READ: Advanced search with text matching
  Future<List<Guide>> searchGuidesAdvanced({
    String? titleContains,
    String? descriptionContains,
    String? createdByContains,
    bool caseSensitive = false,
  }) async {
    try {
      final allGuides = await _firebaseService.getAllGuideCards();
      List<Guide> results = [];

      for (var guideData in allGuides) {
        bool matches = true;

        if (titleContains != null && titleContains.isNotEmpty) {
          String title = guideData['title'] ?? '';
          String search =
              caseSensitive ? titleContains : titleContains.toLowerCase();
          String target = caseSensitive ? title : title.toLowerCase();
          if (!target.contains(search)) matches = false;
        }

        if (descriptionContains != null && descriptionContains.isNotEmpty) {
          String description = guideData['description'] ?? '';
          String search =
              caseSensitive
                  ? descriptionContains
                  : descriptionContains.toLowerCase();
          String target =
              caseSensitive ? description : description.toLowerCase();
          if (!target.contains(search)) matches = false;
        }

        if (createdByContains != null && createdByContains.isNotEmpty) {
          String createdBy = guideData['createdByName'] ?? '';
          String search =
              caseSensitive
                  ? createdByContains
                  : createdByContains.toLowerCase();
          String target = caseSensitive ? createdBy : createdBy.toLowerCase();
          if (!target.contains(search)) matches = false;
        }

        if (matches) {
          results.add(_mapFirestoreToGuide(guideData));
        }
      }

      return results;
    } catch (e) {
      print('Error in advanced search: $e');
      return [];
    }
  }

  /// UPDATE: Updates a guide with comprehensive validation
  Future<String?> updateGuide({
    required String guideId,
    String? title,
    String? description,
    String? imageUrl,
    String? device,
    String? difficulty,
  }) async {
    try {
      // Validate input data if provided
      if (title != null && title.trim().isEmpty) {
        return 'Title cannot be empty';
      }
      if (description != null && description.trim().isEmpty) {
        return 'Description cannot be empty';
      }
      if (device != null &&
          !['desktop', 'laptop'].contains(device.toLowerCase())) {
        return 'Device must be either Desktop or Laptop';
      }
      if (difficulty != null &&
          !['easy', 'medium', 'hard'].contains(difficulty.toLowerCase())) {
        return 'Difficulty must be Easy, Medium, or Hard';
      }

      return await _firebaseService.updateGuideCard(
        guideId: guideId,
        title: title?.trim(),
        description: description?.trim(),
        imageUrl: imageUrl?.trim(),
        device: device?.toLowerCase(),
        difficulty: difficulty?.toLowerCase(),
      );
    } catch (e) {
      print('Error updating guide: $e');
      return 'Error updating guide: $e';
    }
  }

  /// UPDATE: Bulk update multiple guides
  Future<List<String?>> updateMultipleGuides(
    List<Map<String, String?>> updatesData,
  ) async {
    List<String?> results = [];

    for (var updateData in updatesData) {
      final result = await updateGuide(
        guideId: updateData['id'] ?? '',
        title: updateData['title'],
        description: updateData['description'],
        imageUrl: updateData['imageUrl'],
        device: updateData['device'],
        difficulty: updateData['difficulty'],
      );
      results.add(result);
    }

    return results;
  }

  /// UPDATE: Increment likes for a guide
  Future<String?> incrementGuideLikes(String guideId) async {
    try {
      return await _firebaseService.toggleLikeGuideCard(guideId);
    } catch (e) {
      print('Error incrementing likes: $e');
      return 'Error incrementing likes: $e';
    }
  }

  /// DELETE: Bulk delete multiple guides
  Future<List<bool>> deleteMultipleGuides(List<String> guideIds) async {
    List<bool> results = [];

    for (String guideId in guideIds) {
      final result = await deleteGuide(guideId);
      results.add(result);
    }

    return results;
  }

  /// DELETE: Delete all guides by current user (with confirmation)
  Future<String?> deleteAllUserGuides({required bool confirmed}) async {
    try {
      if (!confirmed) {
        return 'Operation requires confirmation';
      }

      final userGuides = await getCurrentUserGuides();
      final guideIds =
          userGuides
              .where((guide) => guide.id != null)
              .map((guide) => guide.id!)
              .toList();

      if (guideIds.isEmpty) {
        return 'No guides to delete';
      }

      final results = await deleteMultipleGuides(guideIds);
      final failures = results.where((result) => !result).toList();

      if (failures.isNotEmpty) {
        return 'Some guides could not be deleted';
      }

      return null; // Success
    } catch (e) {
      print('Error deleting all user guides: $e');
      return 'Error deleting all user guides: $e';
    }
  }

  // ==================== COMPLEX QUERY COMBINATIONS ====================

  /// Complex query: Get trending guides (high likes, recent creation)
  Future<List<Guide>> getTrendingGuides({int limit = 10}) async {
    try {
      final allGuides = await _firebaseService.getAllGuideCards();

      // Calculate trend score based on likes and recency
      List<Map<String, dynamic>> guidesWithScore =
          allGuides.map((guide) {
            final likes = guide['likes'] ?? 0;
            final createdAt = guide['createdAt'];

            // Simple trending score: likes + recency bonus
            double score = likes.toDouble();
            if (createdAt != null) {
              // Add recency bonus (newer guides get higher score)
              final now = DateTime.now();
              final created = (createdAt as dynamic).toDate() as DateTime;
              final daysSinceCreation = now.difference(created).inDays;
              final recencyBonus =
                  daysSinceCreation < 7
                      ? 10
                      : daysSinceCreation < 30
                      ? 5
                      : 0;
              score += recencyBonus;
            }

            return {...guide, 'trendScore': score};
          }).toList();

      // Sort by trend score
      guidesWithScore.sort(
        (a, b) =>
            (b['trendScore'] as double).compareTo(a['trendScore'] as double),
      );

      // Take top results and convert to Guide objects
      final topGuides = guidesWithScore.take(limit).toList();
      return topGuides.map((data) => _mapFirestoreToGuide(data)).toList();
    } catch (e) {
      print('Error getting trending guides: $e');
      return [];
    }
  }

  /// Complex query: Get guides recommendations based on user's creation history
  Future<List<Guide>> getRecommendedGuides({int limit = 10}) async {
    try {
      final userGuides = await getCurrentUserGuides();
      if (userGuides.isEmpty) {
        // If user has no guides, return popular guides
        return await getGuidesSortedByPopularity(limit: limit);
      }

      // Analyze user's preferences
      Map<String, int> devicePreference = {};
      Map<String, int> difficultyPreference = {};

      for (var guide in userGuides) {
        devicePreference[guide.device] =
            (devicePreference[guide.device] ?? 0) + 1;
        difficultyPreference[guide.difficulty] =
            (difficultyPreference[guide.difficulty] ?? 0) + 1;
      }

      // Get preferred device and difficulty
      String preferredDevice =
          devicePreference.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
      String preferredDifficulty =
          difficultyPreference.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;

      // Get guides matching preferences, excluding user's own guides
      final allGuides = await getGuidesWithAdvancedFilters(
        device: preferredDevice,
        difficulty: preferredDifficulty,
        limit: limit * 2, // Get more to filter out user's guides
      );

      // Filter out user's own guides
      final currentUserId = _firebaseService.getCurrentUser()?.uid;
      final recommendations =
          allGuides
              .where((guide) => !guide.isMine && currentUserId != null)
              .take(limit)
              .toList();

      return recommendations;
    } catch (e) {
      print('Error getting recommended guides: $e');
      return [];
    }
  }
}
