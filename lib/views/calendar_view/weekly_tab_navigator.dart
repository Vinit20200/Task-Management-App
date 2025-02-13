import 'package:flutter/material.dart';

import 'weekly_tab_bar.dart';
import 'weekly_tab_controller.dart';
import 'weekly_tab_view.dart';

class WeeklyTabNavigator extends StatefulWidget {
  final WeeklyTabController controller;
  final Widget Function(BuildContext context, DateTime date) tabBuilder;
  final Widget Function(BuildContext context, DateTime date) pageBuilder;
  final ScrollPhysics? scrollPhysics;
  final Function(DateTime date)? onTabScrolled;
  final Function(DateTime date)? onTabChanged;
  final Function(DateTime date)? onPageChanged;

  const WeeklyTabNavigator({
    required this.controller,
    required this.tabBuilder,
    required this.pageBuilder,
    this.scrollPhysics,
    this.onTabScrolled,
    this.onTabChanged,
    this.onPageChanged,
    super.key,
  });

  @override
  State<WeeklyTabNavigator> createState() => _WeeklyTabNavigatorState();

  static DateTime calcSafeDate(DateTime date) {
    int day = date.weekday;
    if (day < 1) {
      return date.add(Duration(days: 1 - day));
    } else if (day > 7) {
      return date.add(Duration(days: 1 - day + 7));
    }
    return date;
  }
}

class _WeeklyTabNavigatorState extends State<WeeklyTabNavigator> with SingleTickerProviderStateMixin {
  late WeeklyTabController tabBarController;
  late WeeklyTabController tabViewController;
  late TabController tabController;

  static const List<int> weekdays = [1, 2, 3, 4, 5, 6, 7];

  int get weekCount {
    final now = DateTime.now();
    final startDate = DateTime(now.year - 2, 1, 1);
    final endDate = DateTime(now.year + 2, 12, 31);
    final totalDays = endDate.difference(startDate).inDays;
    return (totalDays / 7).ceil();
  }

  @override
  void initState() {
    super.initState();

    final pos = widget.controller.position;

    tabController = TabController(length: weekdays.length, vsync: this);
    tabBarController = WeeklyTabController(position: pos);
    tabViewController = WeeklyTabController(position: pos);

    widget.controller.addListener(_updatePosition);
    widget.controller.animateTo(pos);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updatePosition);
    tabController.dispose();
    tabBarController.dispose();
    tabViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WeeklyTabBar(
          controller: tabBarController,
          tabController: tabController,
          weekdays: weekdays,
          weekCount: weekCount,
          tabBuilder: widget.tabBuilder,
          onTabScrolled: widget.onTabScrolled,
          onTabChanged: (value) {
            widget.controller.setPosition(value);
            widget.onTabChanged?.call(value);
            tabViewController.animateTo(value);
          },
        ),
        Expanded(
          child: WeeklyTabView(
            controller: tabViewController,
            tabController: tabController,
            weekdays: weekdays,
            weekCount: weekCount,
            pageBuilder: (context, date) => widget.pageBuilder(context, date),
            scrollPhysics: widget.scrollPhysics,
            onPageChanged: (value) {
              tabBarController.animateTo(value);
              widget.controller.setPosition(value);
              widget.onPageChanged?.call(value);
            },
          ),
        ),
      ],
    );
  }

  void _updatePosition() {
    final position = WeeklyTabNavigator.calcSafeDate(
      widget.controller.position,
    );
    widget.controller.setPosition(position);
    tabBarController.animateTo(position);
    tabViewController.animateTo(position);
  }
}
