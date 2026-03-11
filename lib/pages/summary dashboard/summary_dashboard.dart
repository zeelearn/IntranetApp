import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class SummaryDashboard extends StatefulWidget {
  const SummaryDashboard({super.key});

  @override
  State<SummaryDashboard> createState() => _SummaryDashboardState();
}

class _SummaryDashboardState extends State<SummaryDashboard> {
  // ── colors ───────────────────────────────────────────────────────────────
  static const Color _sidebar = Color(0xFF1E1E2E);
  static const Color _accent = Color(0xFF26C6DA);
  static const Color _accentSecondary = Color(0xFF7C83E5);
  static const Color _green = Color(0xFF4CAF90);
  static const Color _orange = Color(0xFFFF8A65);
  static const Color _red = Color(0xFFEF5350);
  static const Color _mainBg = Color(0xFFF5F7FA);
  static const Color _cardBg = Colors.white;
  static const Color _textPrimary = Color(0xFF1A1D2E);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _divider = Color(0xFFE8EDF2);

  // ── state ─────────────────────────────────────────────────────────────────
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _isSidebarVisible = true;

  // Sample events
  final List<_Event> _events = [
    _Event(
      title: 'Final project meeting',
      time: '9:00 - 10:30 AM',
      color: _green,
      icon: Icons.circle,
      start: DateTime.now(),
      end: DateTime.now(),
    ),
    _Event(
      title: 'Pizza party',
      time: '1:00 - 2:00 PM',
      color: _green,
      icon: Icons.circle,
      start: DateTime.now(),
      end: DateTime.now(),
    ),
    _Event(
      title: 'Team standup',
      time: '10:00 AM',
      color: _accent,
      icon: Icons.circle,
      start: DateTime.now().add(const Duration(days: 1)),
      end: DateTime.now().add(const Duration(days: 1)),
    ),
    _Event(
      title: "Stephanie's birthday",
      time: '12:00 PM',
      color: _accentSecondary,
      icon: Icons.circle,
      start: DateTime.now().add(const Duration(days: 3)),
      end: DateTime.now().add(const Duration(days: 3)),
    ),
    _Event(
      title: 'Clean fish tank',
      time: '7:00 PM',
      color: Colors.grey,
      icon: Icons.check_box_outline_blank,
      start: DateTime.now().add(const Duration(days: 3)),
      end: DateTime.now().add(const Duration(days: 3)),
    ),
    _Event(
      title: 'Lunch interview',
      time: '12:00 - 1:00 PM',
      color: _accent,
      icon: Icons.circle,
      start: DateTime.now().add(const Duration(days: 7)),
      end: DateTime.now().add(const Duration(days: 7)),
    ),
    _Event(
      title: 'Company Retreat',
      time: 'All Day',
      color: _orange,
      icon: Icons.flight_takeoff,
      start: DateTime.now().add(const Duration(days: 8)),
      end: DateTime.now().add(const Duration(days: 10)),
    ),
  ];

  // ── helpers ───────────────────────────────────────────────────────────────
  List<_Event> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      final d = DateTime(day.year, day.month, day.day);
      final s = DateTime(event.start.year, event.start.month, event.start.day);
      final e = DateTime(event.end.year, event.end.month, event.end.day);
      return (d.isAtSameMomentAs(s) || d.isAfter(s)) && (d.isAtSameMomentAs(e) || d.isBefore(e));
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── layout breakpoints ────────────────────────────────────────────────────
  bool _isDesktop(double w) => w > 1100;
  bool _isTablet(double w) => w >= 600 && w <= 1100;
  bool _isMobile(double w) => w < 600;

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _mainBg,
      appBar: _isMobile(w) ? _buildMobileAppBar() : null,
      drawer:
          _isMobile(w) ? Drawer(child: _buildSidebar(compact: false)) : null,
      body: _isMobile(w)
          ? _buildMobileBody()
          : Row(
              children: [
                if (_isDesktop(w) && _isSidebarVisible)
                  SizedBox(width: 280, child: _buildSidebar(compact: false))
                else if (_isTablet(w) && _isSidebarVisible)
                  SizedBox(width: 240, child: _buildSidebar(compact: true)),
                Expanded(child: _buildMainContent(w)),
              ],
            ),
    );
  }

  // ── AppBar (mobile) ───────────────────────────────────────────────────────
  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: _sidebar,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text('Summary Dashboard',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      actions: [
        /*   IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
        ) */
      ],
    );
  }

  // ── mobile body ───────────────────────────────────────────────────────────
  Widget _buildMobileBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKPIRow(isMobile: true),
          const SizedBox(height: 16),
          _buildMiniCalendarCard(),
          const SizedBox(height: 16),
          _buildUpcomingEventsCard(),
          const SizedBox(height: 16),
          _buildChartCard(),
          const SizedBox(height: 16),
          _buildAttendanceCard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── sidebar ───────────────────────────────────────────────────────────────
  Widget _buildSidebar({required bool compact}) {
    final now = DateTime.now();
    return Container(
      color: _sidebar,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dashboard',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: compact ? 14 : 16)),
                  /*   IconButton(
                    icon: Icon(Icons.add_circle_outline,
                        color: _accent, size: compact ? 18 : 22),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ), */
                ],
              ),
            ),

            // Mini Calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: _buildSidebarMiniCalendar(compact: compact),
            ),

            // Weather row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _buildWeatherRow(now),
            ),

            const Divider(color: Color(0xFF2E2E42), thickness: 1, height: 1),

            // Events
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  _buildSidebarDaySection(
                    label: 'TODAY  ${DateFormat('M/d/yy').format(now)}',
                    events: _getEventsForDay(now),
                    compact: compact,
                  ),
                  _buildSidebarDaySection(
                    label:
                        'TOMORROW  ${DateFormat('M/d/yy').format(now.add(const Duration(days: 1)))}',
                    events: _getEventsForDay(now.add(const Duration(days: 1))),
                    compact: compact,
                  ),
                  _buildSidebarDaySection(
                    label:
                        '${DateFormat('EEEE').format(now.add(const Duration(days: 2))).toUpperCase()}  ${DateFormat('M/d/yy').format(now.add(const Duration(days: 2)))}',
                    events: _getEventsForDay(now.add(const Duration(days: 2))),
                    compact: compact,
                  ),
                  _buildSidebarDaySection(
                    label:
                        '${DateFormat('EEEE').format(now.add(const Duration(days: 3))).toUpperCase()}  ${DateFormat('M/d/yy').format(now.add(const Duration(days: 3)))}',
                    events: _getEventsForDay(now.add(const Duration(days: 3))),
                    compact: compact,
                  ),
                ],
              ),
            ),

            // Bottom nav
            /*  const Divider(color: Color(0xFF2E2E42), thickness: 1, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: _accent, size: 16),
                  const SizedBox(width: 6),
                  Text('My Calendars',
                      style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(Icons.expand_more,
                      color: Colors.white54, size: 16),
                ],
              ),
            ), */
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarMiniCalendar({required bool compact}) {
    return Theme(
      data: ThemeData.dark(),
      child: TableCalendar<_Event>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) =>
            _selectedDay != null && _isSameDay(day, _selectedDay!),
        eventLoader: _getEventsForDay,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        onPageChanged: (focused) => setState(() => _focusedDay = focused),
        headerStyle: HeaderStyle(
          titleCentered: false,
          formatButtonVisible: false,
          titleTextStyle: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: compact ? 13 : 15,
          ),
          leftChevronIcon:
              const Icon(Icons.chevron_left, color: Colors.white60, size: 16),
          rightChevronIcon:
              const Icon(Icons.chevron_right, color: Colors.white60, size: 16),
          leftChevronPadding: EdgeInsets.zero,
          rightChevronPadding: EdgeInsets.zero,
          headerPadding: const EdgeInsets.symmetric(vertical: 4),
          titleTextFormatter: (date, locale) =>
              '${DateFormat('MMMM', locale).format(date)}  ${date.year}',
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.inter(
              color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w500),
          weekendStyle: GoogleFonts.inter(
              color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w500),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          defaultTextStyle:
              GoogleFonts.inter(color: Colors.white70, fontSize: 11),
          weekendTextStyle:
              GoogleFonts.inter(color: Colors.white54, fontSize: 11),
          outsideTextStyle:
              GoogleFonts.inter(color: Colors.white24, fontSize: 11),
          todayDecoration:
              const BoxDecoration(color: _accent, shape: BoxShape.circle),
          todayTextStyle: GoogleFonts.inter(
              color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700),
          selectedDecoration: const BoxDecoration(
              color: _accentSecondary, shape: BoxShape.circle),
          selectedTextStyle: GoogleFonts.inter(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
          markerDecoration:
              const BoxDecoration(color: _accent, shape: BoxShape.circle),
          markerSize: 4,
          markersMaxCount: 3,
          cellMargin: const EdgeInsets.all(2),
        ),
      ),
    );
  }

  Widget _buildWeatherRow(DateTime now) {
    return Row(
      children: [
        Text(
          'TODAY  ${DateFormat('M/d/yy').format(now)}',
          style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5),
        ),
        const Spacer(),
        Text('36°/33°',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 10)),
        const SizedBox(width: 4),
        const Icon(Icons.cloud_outlined, color: Colors.white38, size: 14),
      ],
    );
  }

  Widget _buildSidebarDaySection({
    required String label,
    required List<_Event> events,
    required bool compact,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
          const SizedBox(height: 4),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text('No events',
                  style:
                      GoogleFonts.inter(color: Colors.white30, fontSize: 11)),
            )
          else
            ...events.map((e) => _buildSidebarEventTile(e, compact)),
        ],
      ),
    );
  }

  Widget _buildSidebarEventTile(_Event event, bool compact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(event.icon, color: event.color, size: 8),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.time.isNotEmpty)
                  Text(event.time,
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: compact ? 9 : 10)),
                Text(event.title,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: compact ? 10 : 11,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── main content ──────────────────────────────────────────────────────────
  Widget _buildMainContent(double w) {
    final bool desktop = _isDesktop(w);
    return Column(
      children: [
        // Top bar
        _buildTopBar(desktop: desktop),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(desktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI cards
                _buildKPIRow(isMobile: false),
                SizedBox(height: desktop ? 24 : 16),
                // Calendar + side cards
                desktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildFullCalendar()),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 280,
                            child: Column(
                              children: [
                                _buildAttendanceCard(),
                                const SizedBox(height: 16),
                                _buildChartCard(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildFullCalendar(),
                          const SizedBox(height: 16),
                          _buildChartCard(),
                          const SizedBox(height: 16),
                          _buildAttendanceCard(),
                        ],
                      ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar({required bool desktop}) {
    return Container(
      color: _cardBg,
      padding:
          EdgeInsets.symmetric(horizontal: desktop ? 24 : 16, vertical: 10),
      child: Row(
        children: [
          // Toggle sidebar
          InkWell(
            onTap: () => setState(() => _isSidebarVisible = !_isSidebarVisible),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                _isSidebarVisible ? Icons.menu_open : Icons.menu,
                color: _textSecondary,
                size: 20,
              ),
            ),
          ),
          // Nav arrows
          const SizedBox(width: 8),
          _topBarNavBtn(Icons.chevron_left, () {
            setState(() => _focusedDay =
                DateTime(_focusedDay.year, _focusedDay.month - 1));
          }),
          _topBarNavBtn(Icons.chevron_right, () {
            setState(() => _focusedDay =
                DateTime(_focusedDay.year, _focusedDay.month + 1));
          }),
          const SizedBox(width: 8),
          // Today button
          OutlinedButton(
            onPressed: () => setState(() => _focusedDay = DateTime.now()),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: _divider),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: Text('Today',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _textPrimary,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 16),
          Text(DateFormat('MMMM yyyy').format(_focusedDay),
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: desktop ? 18 : 14,
                  color: _textPrimary)),
          const Spacer(),
          // Format switcher (desktop only)
          if (desktop) _buildFormatSwitcher(),
          const SizedBox(width: 12),
          // Search
          if (desktop)
            SizedBox(
              width: 180,
              height: 34,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle:
                      GoogleFonts.inter(fontSize: 12, color: _textSecondary),
                  prefixIcon:
                      const Icon(Icons.search, size: 16, color: _textSecondary),
                  filled: true,
                  fillColor: _mainBg,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _divider),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: _textSecondary),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration:
                      const BoxDecoration(color: _red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          // Profile
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_accent, _accentSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text('VP',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBarNavBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 20, color: _textSecondary),
      ),
    );
  }

  Widget _buildFormatSwitcher() {
    final formats = ['Day', 'Week', 'Month', 'Year'];
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: _divider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: formats.map((f) {
          final isSelected = f == 'Month';
          return GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _accent : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(f,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.black : _textSecondary)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── KPI Cards ─────────────────────────────────────────────────────────────
  Widget _buildKPIRow({required bool isMobile}) {
    final cards = [
      const _KPICard('Total Employees', '248', Icons.people_alt_rounded,
          _accent, '+12 this month', true),
      const _KPICard('Present Today', '201', Icons.check_circle_rounded, _green,
          '81% attendance', true),
      const _KPICard('On Leave', '14', FontAwesomeIcons.umbrellaBeach, _orange,
          '5.6% of team', false),
      const _KPICard('Open Tasks', '37', Icons.task_alt_rounded,
          _accentSecondary, '8 due today', true),
    ];

    return isMobile
        ? GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: cards.length,
            itemBuilder: (_, i) => _buildKPICardWidget(cards[i]),
          )
        : LayoutBuilder(
            builder: (ctx, constraints) {
              return Row(
                children: cards
                    .map((c) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: c != cards.last ? 16 : 0),
                            child: _buildKPICardWidget(c),
                          ),
                        ))
                    .toList(),
              );
            },
          );
  }

  Widget _buildKPICardWidget(_KPICard card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: card.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(card.icon, color: card.color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: card.isPositive
                      ? _green.withValues(alpha: 0.1)
                      : _red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      card.isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 12,
                      color: card.isPositive ? _green : _red,
                    ),
                    const SizedBox(width: 3),
                    Text(card.badge,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: card.isPositive ? _green : _red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(card.value,
              style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary)),
          const SizedBox(height: 2),
          Text(card.title,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Full Calendar ─────────────────────────────────────────────────────────
  Widget _buildFullCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: TableCalendar<_Event>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) =>
              _selectedDay != null && _isSameDay(day, _selectedDay!),
          eventLoader: _getEventsForDay,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            });
          },
          onPageChanged: (focused) => setState(() => _focusedDay = focused),
          headerVisible: false,
          daysOfWeekHeight: 36,
          rowHeight: 80,
          daysOfWeekStyle: DaysOfWeekStyle(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _divider))),
            weekdayStyle: GoogleFonts.inter(
                color: _textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5),
            weekendStyle: GoogleFonts.inter(
                color: _textSecondary.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (ctx, day, focusedDay) =>
                _buildCalCell(day, isOutside: false),
            outsideBuilder: (ctx, day, focusedDay) =>
                _buildCalCell(day, isOutside: true),
            todayBuilder: (ctx, day, focusedDay) =>
                _buildCalCell(day, isToday: true),
            selectedBuilder: (ctx, day, focusedDay) =>
                _buildCalCell(day, isSelected: true),
          ),
        ),
      ),
    );
  }

  Widget _buildCalCell(DateTime day,
      {bool isOutside = false, bool isToday = false, bool isSelected = false}) {
    final events = _getEventsForDay(day);
    final bool isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? _accent.withValues(alpha: 0.08)
            : isToday
                ? _accent.withValues(alpha: 0.05)
                : Colors.transparent,
        border: const Border(
          right: BorderSide(color: _divider, width: 0.5),
          bottom: BorderSide(color: _divider, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day number
          Padding(
            padding: const EdgeInsets.all(4),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isToday
                      ? _accent
                      : isSelected
                          ? _accentSecondary
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isToday || isSelected
                        ? Colors.white
                        : isOutside
                            ? _textSecondary.withValues(alpha: 0.3)
                            : isWeekend
                                ? _textSecondary
                                : _textPrimary,
                  ),
                ),
              ),
            ),
          ),
          // Events
            ...events.take(2).map((e) {
              final d = DateTime(day.year, day.month, day.day);
              final s = DateTime(e.start.year, e.start.month, e.start.day);
              final eDate = DateTime(e.end.year, e.end.month, e.end.day);
              final isStart = d.isAtSameMomentAs(s);
              final isEnd = d.isAtSameMomentAs(eDate);
              final isSingleData = isStart && isEnd;

              return Padding(
                padding: EdgeInsets.only(
                  top: 2,
                  left: (isSingleData || isStart) ? 4 : 0,
                  right: (isSingleData || isEnd) ? 4 : 0,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: e.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.horizontal(
                      left: (isSingleData || isStart) ? const Radius.circular(3) : Radius.zero,
                      right: (isSingleData || isEnd) ? const Radius.circular(3) : Radius.zero,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isSingleData || isStart) ...[
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                              color: e.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 3),
                      ] else
                        const SizedBox(width: 7), // align text
                      Expanded(
                        child: Text(
                          (isSingleData || isStart) ? e.title : '',
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              color: _textPrimary,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (events.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 1, left: 6),
                child: Text('+${events.length - 2} more',
                    style: GoogleFonts.inter(
                        fontSize: 8,
                        color: _accentSecondary,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
    );
  }

  // ── Mini calendar card (mobile) ───────────────────────────────────────────
  Widget _buildMiniCalendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: TableCalendar<_Event>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) =>
            _selectedDay != null && _isSameDay(day, _selectedDay!),
        eventLoader: _getEventsForDay,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        onPageChanged: (focused) => setState(() => _focusedDay = focused),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w700, fontSize: 15, color: _textPrimary),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration:
              const BoxDecoration(color: _accent, shape: BoxShape.circle),
          todayTextStyle: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.bold),
          selectedDecoration: const BoxDecoration(
              color: _accentSecondary, shape: BoxShape.circle),
          selectedTextStyle: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.bold),
          markerDecoration:
              const BoxDecoration(color: _accent, shape: BoxShape.circle),
          markerSize: 4,
        ),
      ),
    );
  }

  // ── Upcoming events card (mobile) ─────────────────────────────────────────
  Widget _buildUpcomingEventsCard() {
    final allEvents = <DateTime, List<_Event>>{};
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final d = now.add(Duration(days: i));
      final events = _getEventsForDay(d);
      if (events.isNotEmpty) allEvents[d] = events;
    }
    return _buildCard(
      title: 'Upcoming Events',
      icon: Icons.event_rounded,
      child: Column(
        children: allEvents.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  _isSameDay(entry.key, now)
                      ? 'Today'
                      : _isSameDay(entry.key, now.add(const Duration(days: 1)))
                          ? 'Tomorrow'
                          : DateFormat('EEEE, MMM d').format(entry.key),
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _textSecondary,
                      letterSpacing: 0.5),
                ),
              ),
              ...entry.value.map((e) => _buildEventRow(e)),
              const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventRow(_Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
                color: event.color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary)),
                if (event.time.isNotEmpty)
                  Text(event.time,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: _textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Chart card ────────────────────────────────────────────────────────────
  Widget _buildChartCard() {
    return _buildCard(
      title: 'Monthly Attendance',
      icon: Icons.bar_chart_rounded,
      child: SizedBox(
        height: 150,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            maxY: 100,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 25,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                      style: GoogleFonts.inter(
                          fontSize: 9, color: _textSecondary)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    const months = ['J', 'F', 'M', 'A', 'M', 'J'];
                    if (v.toInt() >= 0 && v.toInt() < months.length) {
                      return Text(months[v.toInt()],
                          style: GoogleFonts.inter(
                              fontSize: 9, color: _textSecondary));
                    }
                    return const SizedBox();
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (v) =>
                  const FlLine(color: _divider, strokeWidth: 1),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              _bar(0, 88, _accent),
              _bar(1, 92, _accent),
              _bar(2, 79, _orange),
              _bar(3, 95, _green),
              _bar(4, 85, _accent),
              _bar(5, 81, _accent),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  // ── Attendance card ───────────────────────────────────────────────────────
  Widget _buildAttendanceCard() {
    return _buildCard(
      title: 'Team Status',
      icon: Icons.group_rounded,
      child: Column(
        children: [
          _buildStatusRow('Present', 201, 248, _green),
          const SizedBox(height: 10),
          _buildStatusRow('On Leave', 14, 248, _orange),
          const SizedBox(height: 10),
          _buildStatusRow('Remote', 33, 248, _accentSecondary),
          const SizedBox(height: 16),
          // Pie-like row
          Row(
            children: [
              _buildStatChip('201', 'Present', _green),
              const SizedBox(width: 8),
              _buildStatChip('14', 'Leave', _orange),
              const SizedBox(width: 8),
              _buildStatChip('33', 'Remote', _accentSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int value, int total, Color color) {
    final pct = value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _textPrimary,
                    fontWeight: FontWeight.w500)),
            Text('$value / $total',
                style: GoogleFonts.inter(fontSize: 11, color: _textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800, fontSize: 18, color: color)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── Card wrapper ──────────────────────────────────────────────────────────
  Widget _buildCard(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _accent),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _textPrimary)),
              const Spacer(),
              const Icon(Icons.more_horiz, size: 16, color: _textSecondary),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _divider),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────
class _Event {
  final String title;
  final String time;
  final Color color;
  final IconData icon;
  final DateTime start;
  final DateTime end;

  const _Event({
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
    required this.start,
    required this.end,
  });

  bool get isMultiDay {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !s.isAtSameMomentAs(e);
  }
}

class _KPICard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String badge;
  final bool isPositive;
  const _KPICard(this.title, this.value, this.icon, this.color, this.badge,
      this.isPositive);
}
