/// Guide Model - Represents a hardware tutorial guide in the ByteBack application
///
/// This class defines the structure of a guide including its content, metadata,
/// and interactive states like liked and downloaded status.
class Guide {
  /// Unique identifier for the guide (Firestore document ID)
  final String? id;

  /// The title of the guide shown in listings and detail view
  final String title;

  /// A brief description of what the guide covers
  final String subtitle;

  /// Path to the guide's thumbnail image
  final String image;

  /// Difficulty level of the guide (Easy, Medium, Hard)
  /// Used for filtering and indicating complexity to users
  final String difficulty;

  /// Target device type for the guide (Laptop, Desktop)
  /// Used for categorizing and filtering guides
  final String device;

  /// Whether the guide is saved for offline access
  final bool isDownloaded;

  /// Whether the current user has liked this guide
  final bool isLiked;

  /// Total number of likes this guide has received
  final int likesCount;

  /// Username of the guide's author
  final String createdBy;

  /// Whether the current user created this guide
  final bool isMine;

  /// Creates a new Guide instance with all its required properties
  /// The isDownloaded and isLiked flags default to false for new guides
  Guide({
    this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.difficulty,
    required this.device,
    this.isDownloaded = false,
    this.isLiked = false,
    this.likesCount = 0,
    required this.createdBy,
    this.isMine = false,
  });

  /// Create a Guide from Firestore document data
  factory Guide.fromFirestore(Map<String, dynamic> data, {String? userId}) {
    final List<dynamic> likedBy = data['likedBy'] ?? [];
    final bool userLiked = userId != null && likedBy.contains(userId);
    final bool userCreated = userId != null && data['createdBy'] == userId;

    return Guide(
      id: data['id'],
      title: data['title'] ?? '',
      subtitle: data['description'] ?? '',
      image: data['imageUrl'] ?? '',
      difficulty: data['difficulty'] ?? 'Easy',
      device: data['device'] ?? 'Desktop',
      isLiked: userLiked,
      likesCount: data['likes'] ?? 0,
      createdBy: data['createdByName'] ?? 'Anonymous',
      isMine: userCreated,
    );
  }
}
