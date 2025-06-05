import 'package:byteback2/models/Guide.dart';

/// Data management class for Guide objects
/// Provides a static interface for managing guides in the application
/// Acts as a temporary in-memory database for the app
class GuideData {
  /// Static list of guides serving as the data store
  /// In a production app, this would be replaced with a proper database
  static final List<Guide> guides = [
    Guide(
      title: 'Easiest way to clean your dusty computer!',
      subtitle:
          'If you want to clean your computer u need get a duster duster muster . . .',
      image: 'images/guide.jpeg',
      isLiked: true,
      isDownloaded: false,
      difficulty: 'Easy',
      device: 'Laptop',
      createdBy: 'Alex Chen',
      isMine: false,
    ),
    Guide(
      title: 'Why is my GPU so slow?!',
      subtitle:
          'This guide will give you ways for you to boost your GPU back to life if it feels like its slowing down . . .',
      image: 'images/guide.jpeg',
      isLiked: true,
      isDownloaded: false,
      difficulty: 'Hard',
      device: 'Desktop',
      createdBy: 'Sarah Johnson',
      isMine: false,
    ),
    Guide(
      title: "How to connect your lights' PCIB to motherboard!",
      subtitle:
          'Do you ever want to make your computer smack lacky colourfully . . .',
      image: 'images/guide.jpeg',
      isLiked: true,
      isDownloaded: false,
      difficulty: 'Medium',
      device: 'Desktop',
      createdBy: 'Michael Rodriguez',
      isMine: false,
    ),
    Guide(
      title: 'How to upgrade your CPU!',
      subtitle:
          'Check your motherboard model and CPU compatibility on the manufacturer\'s website,\nbuy a compatible new CPU (and thermal paste if needed),\nback up your data, shut down and unplug your PC, and ground yourself to avoid static,\nopen the case, remove the cooler and old CPU carefully,\nclean off old thermal paste with isopropyl alcohol,\ninstall the new CPU by aligning the gold triangle and locking it in,\napply thermal paste or use pre-applied paste,\nreinstall',
      image: 'images/guide.jpeg',
      isLiked: false,
      isDownloaded: true,
      difficulty: 'Hard',
      device: 'Desktop',
      createdBy: 'Emma Thompson',
      isMine: false,
    ),
    Guide(
      title: 'How to upgrade your CPU! 2',
      subtitle: 'Real Text',
      image: 'images/guide.jpeg',
      isLiked: false,
      isDownloaded: true,
      difficulty: 'Medium',
      device: 'Laptop',
      createdBy: 'David Kim',
      isMine: true, // This one is marked as the user's own guide
    ),
  ];

  /// Adds a new guide to the collection
  static void addGuide(Guide guide) {
    guides.add(guide);
  }

  /// Removes a guide by its title
  /// This should be updated to use a unique ID in production
  static void removeGuide(String title) {
    guides.removeWhere((guide) => guide.title == title);
  }

  /// Updates an existing guide's properties
  /// All parameters except title are optional
  static void updateGuide(
    String title, {
    String? newTitle,
    String? newSubtitle,
    String? newImage,
    bool? isLiked,
    bool? isDownloaded,
    String? difficulty,
    String? device,
    String? createdBy,
  }) {
    final index = guides.indexWhere((guide) => guide.title == title);
    if (index != -1) {
      final guide = guides[index];
      guides[index] = Guide(
        title: newTitle ?? guide.title,
        subtitle: newSubtitle ?? guide.subtitle,
        image: newImage ?? guide.image,
        isLiked: isLiked ?? guide.isLiked,
        isDownloaded: isDownloaded ?? guide.isDownloaded,
        difficulty: difficulty ?? guide.difficulty,
        device: device ?? guide.device,
        createdBy: createdBy ?? guide.createdBy,
        isMine: guide.isMine,
      );
    }
  }

  /// Filters guides based on multiple criteria
  /// Returns a new list of guides matching all provided filters
  static List<Guide> filterGuides({
    String? device,
    List<String>? difficulties,
    bool? isLiked,
    bool? isDownloaded,
  }) {
    return guides.where((guide) {
      bool matchesDevice = device == null || guide.device == device;
      bool matchesDifficulty =
          difficulties == null ||
          difficulties.isEmpty ||
          difficulties.contains(guide.difficulty);
      bool matchesLiked = isLiked == null || guide.isLiked == isLiked;
      bool matchesDownloaded =
          isDownloaded == null || guide.isDownloaded == isDownloaded;

      return matchesDevice &&
          matchesDifficulty &&
          matchesLiked &&
          matchesDownloaded;
    }).toList();
  }

  /// Returns all guides marked as liked by the user
  static List<Guide> getLikedGuides() {
    return guides.where((guide) => guide.isLiked).toList();
  }

  /// Returns all guides marked as downloaded by the user
  static List<Guide> getDownloadedGuides() {
    return guides.where((guide) => guide.isDownloaded).toList();
  }

  /// Toggles the like status of a guide
  static void toggleLike(String title) {
    final index = guides.indexWhere((guide) => guide.title == title);
    if (index != -1) {
      final guide = guides[index];
      guides[index] = Guide(
        title: guide.title,
        subtitle: guide.subtitle,
        image: guide.image,
        isLiked: !guide.isLiked,
        isDownloaded: guide.isDownloaded,
        difficulty: guide.difficulty,
        device: guide.device,
        createdBy: guide.createdBy,
        isMine: guide.isMine,
      );
    }
  }

  /// Toggles the download status of a guide
  static void toggleDownload(String title) {
    final index = guides.indexWhere((guide) => guide.title == title);
    if (index != -1) {
      final guide = guides[index];
      guides[index] = Guide(
        title: guide.title,
        subtitle: guide.subtitle,
        image: guide.image,
        isLiked: guide.isLiked,
        isDownloaded: !guide.isDownloaded,
        difficulty: guide.difficulty,
        device: guide.device,
        createdBy: guide.createdBy,
        isMine: guide.isMine,
      );
    }
  }
}
