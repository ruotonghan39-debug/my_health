import '../../domain/feed_post.dart';
import '../../domain/post_types.dart';

const List<String> homeGreetings = [
  '今天也很棒 ✨',
  '继续保持！',
  '再坚持一天！',
  '元气满满 🌱',
  '轻燃一下～',
];

/// Offline / no-Supabase demo feed.
final List<FeedPost> mockFeedPosts = [
  FeedPost(
    id: '1',
    userId: 'mock-1',
    userName: '阿柚',
    createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    type: PostType.diet,
    content: '今日午餐：鸡胸肉 + 玉米 🌽',
    calories: 480,
    tags: ['#饮食打卡', '#减脂餐'],
    imageUrls: [],
  ),
  FeedPost(
    id: '2',
    userId: 'mock-2',
    userName: '小林',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    type: PostType.exercise,
    content: '跑步 5km，吹吹风超舒服～',
    calories: 320,
    tags: ['#跑步'],
    imageUrls: [],
  ),
  FeedPost(
    id: '3',
    userId: 'mock-3',
    userName: '元气少女',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    type: PostType.weight,
    content: '本周 -1.2kg ✨ 继续稳住！',
    weightDelta: -1.2,
    tags: ['#体重'],
    imageUrls: [],
  ),
  FeedPost(
    id: '4',
    userId: 'mock-4',
    userName: 'Mio',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    type: PostType.diet,
    content: '早餐燕麦碗 + 蓝莓，甜甜的开始～',
    calories: 360,
    tags: ['#早餐'],
    imageUrls: [],
  ),
];

final List<double> mockWeightLast7Days = [53.2, 52.9, 52.8, 52.6, 52.5, 52.3, 52.1];

final List<double> mockWeightLast30Days = List<double>.generate(
  30,
  (i) => 54.0 - (i * 0.07) + (i % 3) * 0.05,
);

class MockDailyStats {
  const MockDailyStats({
    required this.intakeKcal,
    required this.intakeGoal,
    required this.burnKcal,
    required this.burnGoal,
    required this.weightKg,
    required this.deltaFromYesterday,
    required this.streakDays,
  });

  final int intakeKcal;
  final int intakeGoal;
  final int burnKcal;
  final int burnGoal;
  final double weightKg;
  final double deltaFromYesterday;
  final int streakDays;
}

const MockDailyStats kTodayStats = MockDailyStats(
  intakeKcal: 1280,
  intakeGoal: 1600,
  burnKcal: 328,
  burnGoal: 600,
  weightKg: 52.1,
  deltaFromYesterday: -0.3,
  streakDays: 5,
);

const Map<String, double> kMacroFractions = {
  '碳水': 0.45,
  '蛋白': 0.30,
  '脂肪': 0.25,
};
