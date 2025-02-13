import 'package:flutter/material.dart';
import 'package:task_management_app/extensions.dart';
import '../../colors.dart';
import 'weekly_tab_controller.dart';

class WeeklyTabBar extends StatefulWidget implements PreferredSizeWidget {
  static const widgetHeight = 90.0;
  static const animationDuration = Duration(milliseconds: 300);
  static const animationCurve = Curves.easeInOut;

  final WeeklyTabController controller;
  final TabController tabController;
  final List<int> weekdays;
  final int weekCount;
  final Widget Function(BuildContext context, DateTime date) tabBuilder;
  final ScrollPhysics? scrollPhysics;
  final Function(DateTime date)? onTabScrolled;
  final Function(DateTime date)? onTabChanged;

  const WeeklyTabBar({
    required this.controller,
    required this.tabController,
    required this.weekdays,
    required this.weekCount,
    required this.tabBuilder,
    this.scrollPhysics,
    this.onTabScrolled,
    this.onTabChanged,
    super.key,
  });

  @override
  State<WeeklyTabBar> createState() => _WeeklyTabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(widgetHeight);
}

class _WeeklyTabBarState extends State<WeeklyTabBar> with TickerProviderStateMixin {
  late DateTime centerPosition;
  late int centerIndex;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    centerPosition = widget.controller.position.weekStart(widget.weekdays);
    centerIndex = widget.weekCount;
    pageController = PageController(initialPage: centerIndex);
    widget.controller.addListener(_updatePosition);
    widget.controller.animateTo(widget.controller.position);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updatePosition);
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: WeeklyTabBar.widgetHeight,
      child: PageView.builder(
        controller: pageController,
        itemCount: widget.weekCount * 2,
        itemBuilder: (context, index) => _buildTabBar(_weekToDate(index)),
        onPageChanged: (index) => widget.onTabScrolled?.call(_weekToDate(index)),
      ),
    );
  }

  Widget _buildTabBar(DateTime date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.weekdays.length,
            (index) => _buildCalendarItem(date, index),
      ),
    );
  }

  Widget _buildCalendarItem(DateTime weekStart, int index) {
    final itemDate = _indexToDate(weekStart, index);
    final isSelected = itemDate.isSameDay(widget.controller.position);
    final isToday = itemDate.isSameDay(DateTime.now());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color getDateBackgroundColor() {
      if (isSelected) {
        return isDarkMode
            ? AppColors.primaryBlue1.withOpacity(0.8)  // Slightly transparent in dark mode
            : AppColors.primaryBlue1;                   // Original color in light mode
      }
      return AppColors.transparent;
    }

    return Expanded(
      child: _CalendarItemView(
        onTap: () {
          setState(() {
            widget.controller.setPosition(itemDate);
            widget.onTabChanged?.call(itemDate);
          });
        },
        dateBackgroundColor: getDateBackgroundColor(),
        date: itemDate.day.toString().padLeft(2, '0'),
        dateStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : isDarkMode ? Colors.grey[300] : AppColors.black,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        day: isToday ? 'Today' : _getDayName(itemDate.weekday),
        dayStyle: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isDarkMode
              ? (isSelected || isToday) ? Colors.white : Colors.grey[400]
              : (isSelected || isToday) ? AppColors.black : Colors.grey[600],
        ),
        isToday: isToday,
        isDarkMode: isDarkMode,
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'M';
      case DateTime.tuesday:
        return 'T';
      case DateTime.wednesday:
        return 'W';
      case DateTime.thursday:
        return 'T';
      case DateTime.friday:
        return 'F';
      case DateTime.saturday:
        return 'S';
      case DateTime.sunday:
        return 'S';
      default:
        return '';
    }
  }

  void _updatePosition() {
    final week = _dateToWeek(widget.controller.position);
    if (pageController.hasClients) {
      pageController.animateToPage(
        week,
        duration: WeeklyTabBar.animationDuration,
        curve: WeeklyTabBar.animationCurve,
      );
    }
  }

  DateTime _indexToDate(DateTime position, int index) {
    return position.add(Duration(days: widget.weekdays[index] - widget.weekdays[0]));
  }

  DateTime _weekToDate(int week) {
    return DateUtils.addDaysToDate(
      centerPosition,
      (week - centerIndex) * DateTime.daysPerWeek,
    );
  }

  int _dateToWeek(DateTime date) {
    return centerIndex + date.differenceInWeeks(centerPosition);
  }
}

class _CalendarItemView extends StatelessWidget {
  final Function() onTap;
  final Color dateBackgroundColor;
  final String date;
  final TextStyle dateStyle;
  final String day;
  final TextStyle dayStyle;
  final bool isToday;
  final bool isDarkMode;

  const _CalendarItemView({
    required this.onTap,
    required this.dateBackgroundColor,
    required this.date,
    required this.dateStyle,
    required this.day,
    required this.dayStyle,
    required this.isToday,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(day, style: dayStyle),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: dateBackgroundColor,
              shape: BoxShape.circle,
              border: isToday ? Border.all(
                color: isDarkMode ? Colors.purple[200]! : AppColors.primaryBlue1,
                width: 2,
              ) : null,
            ),
            padding: const EdgeInsets.all(10),
            child: Text(date, style: dateStyle),
          ),
        ),
      ],
    );
  }
}