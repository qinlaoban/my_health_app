import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HealthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          // 用户信息
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF007AFF).withOpacity(0.12),
                  child: Text(
                    hp.userName.isNotEmpty ? hp.userName[0] : '?',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Color(0xFF007AFF)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hp.userName, style: AppTypography.title2),
                      const SizedBox(height: 2),
                      Text('${hp.age}岁 · ${hp.height.toInt()}cm · ${hp.weight.toInt()}kg', style: AppTypography.subheadline),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.tertiaryText),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // 今日健康数据
          _sectionHeader('今日数据'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _statCell('步数', hp.todaySteps.toString(), '步', Icons.directions_walk, AppColors.steps),
                        const SizedBox(width: 12),
                        _statCell('心率', hp.heartRate.toInt().toString(), 'bpm', Icons.favorite, AppColors.heartRate),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _statCell('睡眠', '${hp.sleepHours.toStringAsFixed(1)}', '小时', Icons.bedtime, AppColors.sleep),
                        const SizedBox(width: 12),
                        _statCell('体重', hp.latestWeight?.toStringAsFixed(1) ?? '--', 'kg', Icons.monitor_weight, AppColors.weight),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 功能菜单
          _buildMenuGroup(context, [
            _MenuItemData('个人信息', Icons.person_outline, () => _showDialog(context, '个人信息编辑功能开发中...')),
            _MenuItemData('设置', Icons.settings, () => context.push('/settings')),
            _MenuItemData('隐私与安全', Icons.security, () => _showDialog(context, '隐私与安全功能开发中...')),
          ]),
          const SizedBox(height: 10),
          _buildMenuGroup(context, [
            _MenuItemData('数据同步', Icons.cloud_sync, () => _showDialog(context, '数据同步功能开发中...')),
            _MenuItemData('分享应用', Icons.share, () => _showDialog(context, '分享功能开发中...')),
          ]),
          const SizedBox(height: 10),
          _buildMenuGroup(context, [
            _MenuItemData('帮助与反馈', Icons.help_outline, () => _showDialog(context, '帮助与反馈')),
            _MenuItemData('关于', Icons.info_outline, () => _showAboutDialog(context)),
          ]),
          const SizedBox(height: 20),
          // 退出登录
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showLogoutDialog(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.heartRate,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.heartRate.withOpacity(0.2)),
                  ),
                ),
                child: const Text('退出登录', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value, String unit, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: AppTypography.metricValue.copyWith(fontSize: 22, height: 1)),
                  const SizedBox(width: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(unit, style: AppTypography.caption),
                  ),
                ],
              ),
              Text(label, style: AppTypography.footnote),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Text(title, style: AppTypography.title2),
    );
  }

  Widget _buildMenuGroup(BuildContext context, List<_MenuItemData> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: List.generate(items.length, (i) {
                return Column(
                  children: [
                    if (i > 0) const Divider(),
                    _menuItem(items[i].icon, items[i].title, items[i].onTap),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: const Color(0xFF007AFF)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: AppTypography.body.copyWith(fontSize: 16))),
            Icon(Icons.chevron_right, size: 20, color: AppColors.tertiaryText),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定'))],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('关于'),
        content: const Text('我的健康 v1.0.0\n一款专业的健康管理应用'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定'))],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已退出登录')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _MenuItemData(this.title, this.icon, this.onTap);
}
