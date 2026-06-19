class DemoStory {
  const DemoStory({
    required this.id,
    required this.label,
    required this.avatarUrl,
    this.isOwnStory = false,
  });

  final String id;
  final String label;
  final String avatarUrl;
  final bool isOwnStory;
}

class DemoFeedPost {
  DemoFeedPost({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption,
    required this.timeLabel,
    this.likeCount = 1,
    this.liked = false,
    this.saved = false,
  });

  final String id;
  final String userName;
  final String avatarUrl;
  final String imageUrl;
  final String caption;
  final String timeLabel;
  int likeCount;
  bool liked;
  bool saved;

  DemoFeedPost copyWith({
    int? likeCount,
    bool? liked,
    bool? saved,
  }) {
    return DemoFeedPost(
      id: id,
      userName: userName,
      avatarUrl: avatarUrl,
      imageUrl: imageUrl,
      caption: caption,
      timeLabel: timeLabel,
      likeCount: likeCount ?? this.likeCount,
      liked: liked ?? this.liked,
      saved: saved ?? this.saved,
    );
  }
}

abstract final class FeedDemoData {
  static const stories = [
    DemoStory(
      id: 'own',
      label: 'Your story',
      avatarUrl: 'https://randomuser.me/api/portraits/men/75.jpg',
      isOwnStory: true,
    ),
    DemoStory(
      id: 'alex',
      label: 'Alex',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    DemoStory(
      id: 'emma',
      label: 'Emma',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    DemoStory(
      id: 'leo',
      label: 'Leo',
      avatarUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
    ),
    DemoStory(
      id: 'mia',
      label: 'Mia',
      avatarUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
    ),
    DemoStory(
      id: 'noah',
      label: 'Noah',
      avatarUrl: 'https://randomuser.me/api/portraits/men/46.jpg',
    ),
  ];

  static List<DemoFeedPost> initialPosts() {
    return [
      DemoFeedPost(
        id: 'demo_1',
        userName: 'Alex Morgan',
        avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        imageUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800&q=80',
        caption: 'look at that beauty',
        timeLabel: '7m ago',
        likeCount: 1,
      ),
      DemoFeedPost(
        id: 'demo_2',
        userName: 'Emma Reed',
        avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&q=80',
        caption: 'morning training done',
        timeLabel: '45m ago',
        likeCount: 3,
      ),
      DemoFeedPost(
        id: 'demo_3',
        userName: 'Leo Chen',
        avatarUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
        imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=80',
        caption: 'small progress every day',
        timeLabel: '2h ago',
        likeCount: 5,
      ),
      DemoFeedPost(
        id: 'demo_4',
        userName: 'Mia Brooks',
        avatarUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
        imageUrl: 'https://images.unsplash.com/photo-1476480862128-209b5b09368a?w=800&q=80',
        caption: 'post-workout walk',
        timeLabel: '3h ago',
        likeCount: 2,
      ),
    ];
  }

  static List<DemoFeedPost> refreshPosts(List<DemoFeedPost> current) {
    final fresh = DemoFeedPost(
      id: 'demo_refresh_${DateTime.now().millisecondsSinceEpoch}',
      userName: 'Noah Ellis',
      avatarUrl: 'https://randomuser.me/api/portraits/men/46.jpg',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
      caption: 'new day, new reps',
      timeLabel: 'now',
      likeCount: 0,
    );
    return [fresh, ...current];
  }
}
