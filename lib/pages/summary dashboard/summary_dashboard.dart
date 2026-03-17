import 'package:Intranet/api/ServiceHandler.dart';
import 'package:Intranet/api/request/pjp/get_pjp_report_request.dart';
import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/iface/onResponse.dart';
import 'package:Intranet/pages/pjp/cvf/cvf_questions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// This is a placeholder for the request model. Ideally, this should be in its own file
// e.g., 'lib/api/request/pjp/get_pjp_report_request.dart'
/* class PJPReportRequest {
  final int Employee_id;
  final int Business_id;
  final String From_Date;
  final String To_Date;

  PJPReportRequest({
    required this.Employee_id,
    required this.Business_id,
    required this.From_Date,
    required this.To_Date,
  });

  String getJson() {
    return jsonEncode({
      'Employee_id': Employee_id,
      'Business_id': Business_id,
      'From_Date': From_Date,
      'To_Date': To_Date,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'Employee_id': Employee_id,
      'Business_id': Business_id,
      'From_Date': From_Date,
      'To_Date': To_Date,
    };
  }
} */

class SummaryDashboard extends StatefulWidget {
  const SummaryDashboard({super.key});

  @override
  State<SummaryDashboard> createState() => _SummaryDashboardState();
}

class _SummaryDashboardState extends State<SummaryDashboard>
    implements onResponse {
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
  final DateTime _lastDay =
      DateTime.utc(DateTime.now().year, DateTime.now().month + 4, 0);

  bool _isSidebarVisible = true;

  // API Data state
  bool _isLoading = true;
  List<PJPInfo> _pjpData = [];
  final List<_Event> _events = [];

  // KPI state
  int _totalEmployees = 0;
  int _totalVisits = 0;
  int _pendingApprovals = 0; // This might need another API
  int _approvedPJP = 0;

  // User color mapping
  final Map<String, Color> _userColors = {};
  final Map<String, int> _userEventCount = {};
  int _colorIndex = 0;
  final List<Color> _colorPalette = [
    _accent,
    _accentSecondary,
    _green,
    _orange,
    _red,
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.brown,
    Colors.teal,
  ];

  Color _getColorForUser(String userName) {
    if (!_userColors.containsKey(userName)) {
      _userColors[userName] = _colorPalette[_colorIndex];
      _colorIndex = (_colorIndex + 1) % _colorPalette.length;
    }
    return _userColors[userName]!;
  }

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      var hiveBox = await Utility.openBox();
      int employeeId =
          int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
      String employeeCode =
          hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE) as String;
      // int businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      PJPReportRequest request = PJPReportRequest(
        employeeCode: employeeCode,
        // Business_id: businessId,
        fromDate: DateFormat('yyyy-MM-dd').format(firstDayOfMonth),
        toDate: DateFormat('yyyy-MM-dd').format(lastDayOfMonth),
      );

      IntranetServiceHandler.loadPjpReport(request, this);
    } catch (e) {
      onError(e.toString());
    }
  }

  @override
  void onStart() {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  @override
  void onSuccess(value) {
    print('Response from api is - ${value.toJson()}');
    if (value is PjpListResponse) {
      if (mounted) {
        setState(() {
          _pjpData = value.responseData;
          _processPjpData();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void onError(value) {
    print('Error loading dashboard data: $value');
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Utility.showMessages(context, 'Failed to load dashboard data: $value');
    }
  }

  void _processPjpData() {
    int totalVisits = 0;
    int pendingApprovals = 0;
    int approvedPjps = 0;
    List<_Event> newEvents = [];
    final today = DateTime.now();

    Set<String> teamMembers = {};

    _userColors.clear();
    _userEventCount.clear();
    _colorIndex = 0;

    for (var pjpInfo in _pjpData) {
      final userName = pjpInfo.displayName;
      final baseColor = _getColorForUser(userName);
      final eventCount = _userEventCount.putIfAbsent(userName, () => 0);

      // Create a slightly different shade for each event
      final eventColor =
          Color.lerp(baseColor, Colors.black, eventCount * 0.05)!;
      _userEventCount[userName] = eventCount + 1;

      newEvents.add(_Event(
        title: '${pjpInfo.displayName}',
        time: pjpInfo.Status,
        color: eventColor,
        icon: Icons.location_on,
        start: Utility.convertDate(pjpInfo.fromDate),
        end: Utility.convertDate(pjpInfo.toDate),
        pjpInfo: pjpInfo,
      ));
      teamMembers.add(pjpInfo.displayName);

      if (pjpInfo.getDetailedPJP != null) {
        totalVisits += pjpInfo.getDetailedPJP!.length;
      }

      if (pjpInfo.ApprovalStatus.trim().toLowerCase() == 'pending') {
        pendingApprovals++;
      }
      if (pjpInfo.ApprovalStatus.trim().toLowerCase() == 'approved') {
        approvedPjps++;
      }
    }

    // Update state variables
    _totalVisits = totalVisits;
    _pendingApprovals = pendingApprovals;
    _approvedPJP = approvedPjps;
    _totalEmployees = teamMembers.isNotEmpty
        ? teamMembers.length
        : 1; // Avoid division by zero
    _events.clear();
    _events.addAll(newEvents);
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  List<_Event> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      final d = DateTime(day.year, day.month, day.day);
      final s = DateTime(event.start.year, event.start.month, event.start.day);
      final e = DateTime(event.end.year, event.end.month, event.end.day);
      return (d.isAtSameMomentAs(s) || d.isAfter(s)) &&
          (d.isAtSameMomentAs(e) || d.isBefore(e));
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

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: _mainBg,
      appBar: _isMobile(w) ? _buildMobileAppBar() : null,
      // drawer:
      //     _isMobile(w) ? Drawer(child: _buildSidebar(compact: false)) : null,
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
      title: Text('PJP Dashboard',
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
          // const SizedBox(height: 6),
          _buildMiniCalendarCard(),
          const SizedBox(height: 16),
          _buildUpcomingEventsCard(),
          // const SizedBox(height: 16),
          // _buildChartCard(),
          // const SizedBox(height: 16),
          // _buildAttendanceCard(),
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
            /*    Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _buildWeatherRow(now),
            ), */

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
        lastDay: _lastDay,
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
          final events = _getEventsForDay(selected);
          if (events.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    _DayEventsScreen(day: selected, events: events),
              ),
            );
          }
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
                /* if (event.time.isNotEmpty)
                  Text(event.time,
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: compact ? 9 : 10)), */
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
            padding: EdgeInsets.all(/* desktop ? 24 : */ 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI cards
                _buildKPIRow(isMobile: false),
                SizedBox(height: /* desktop ? 24 : */ 16),
                // Calendar + side cards
                _buildFullCalendar(),
                /*  desktop
                    ? _buildFullCalendar() /* Row( 
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
                      ) */
                    : Column(
                        children: [
                          _buildFullCalendar(),
                          /*  const SizedBox(height: 16),
                          _buildChartCard(),
                          const SizedBox(height: 16),
                          _buildAttendanceCard(), */
                        ],
                      ), */
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
          _topBarNavBtn(Icons.arrow_back, () {
            Navigator.of(context).pop();
          }),
          const SizedBox(width: 8),
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
            if (_lastDay.month == _focusedDay.month &&
                _lastDay.year == _focusedDay.year) {
              return;
            }
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
          /*  if (desktop) _buildFormatSwitcher(),
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
          ), */
          // Profile
          /*  Container(
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
          ), */
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
    String presentBadge = '';
    // Note: 'On Leave' data is not available from this API. Using a placeholder.
    String onLeaveBadge = _pjpData.isNotEmpty
        ? '${((_pendingApprovals / _pjpData.length) * 100).toStringAsFixed(1)}% of PJPs'
        : '0% of team';
    String approvedBadge = _pjpData.isNotEmpty
        ? '${((_approvedPJP / _pjpData.length) * 100).toStringAsFixed(1)}% of PJPs'
        : '0% of PJPs';

    final cards = [
      _KPICard('Employees', _totalEmployees.toString(),
          Icons.people_alt_rounded, _accent, '', true),
      _KPICard('Visits', _totalVisits.toString(), Icons.check_circle_rounded,
          _green, presentBadge, true),
      _KPICard('Pending Approvals', _pendingApprovals.toString(),
          FontAwesomeIcons.umbrellaBeach, _orange, onLeaveBadge, false),
      _KPICard('Approved PJPs', _approvedPJP.toString(), Icons.task_alt_rounded,
          _accentSecondary, approvedBadge, true),
    ];

    return isMobile
        ? GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 4 / 3.3,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(card.icon, color: card.color, size: 18),
              ),
              if (card.badge.isNotEmpty)
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: (card.isPositive ? _green : _red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          card.isPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 12,
                          color: card.isPositive ? _green : _red,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            card.badge,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: card.isPositive ? _green : _red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  card.value,
                  style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                card.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
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
          lastDay: _lastDay,
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
            final events = _getEventsForDay(selected);
            if (events.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      _DayEventsScreen(day: selected, events: events),
                ),
              );
            }
          },
          onPageChanged: (focused) => setState(() => _focusedDay = focused),
          headerVisible: false,
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(),
          ),
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
          Expanded(
            child: Padding(
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
          ),
          // Events
          ...events.take(3).map((e) {
            final d = DateTime(day.year, day.month, day.day);
            final s = DateTime(e.start.year, e.start.month, e.start.day);
            final eDate = DateTime(e.end.year, e.end.month, e.end.day);
            final isStart = d.isAtSameMomentAs(s);
            final isEnd = d.isAtSameMomentAs(eDate);
            final isSingleDay = isStart && isEnd;

            return Padding(
              padding: EdgeInsets.only(
                top: 2,
                left: isStart ? 4 : 0,
                right: isEnd ? 4 : 0,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: e.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.horizontal(
                    left: isStart ? const Radius.circular(3) : Radius.zero,
                    right: isEnd ? const Radius.circular(3) : Radius.zero,
                  ),
                ),
                child: Row(
                  children: [
                    if (isStart) ...[
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
                        isStart ? e.title : '',
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
          if (events.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 1, left: 6),
              child: Text('+${events.length - 3} more',
                  style: GoogleFonts.inter(
                      fontSize: 8,
                      color: _accentSecondary,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileCalCell(DateTime day,
      {List<_Event> events = const [],
      bool isToday = false,
      bool isSelected = false,
      bool isOutside = false}) {
    if (isOutside) {
      return Center(
        child: Text(
          '${day.day}',
          style: GoogleFonts.inter(color: _textSecondary.withOpacity(0.5)),
        ),
      );
    }
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? _accentSecondary
              : (isToday ? _accent : Colors.transparent),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Text(
              '${day.day}',
              style: GoogleFonts.inter(
                  color: isSelected || isToday ? Colors.white : _textPrimary),
            ),
            if (events.isNotEmpty)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: _red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1)),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${events.length}',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: TableCalendar<_Event>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: _lastDay,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) =>
            _selectedDay != null && _isSameDay(day, _selectedDay!),
        eventLoader: _getEventsForDay,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        onDaySelected: (selected, focused) async {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
          final events = _getEventsForDay(selected);
          if (events.isNotEmpty && mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    _DayEventsScreen(day: selected, events: events),
              ),
            );
          }
        },
        onPageChanged: (focused) => setState(() => _focusedDay = focused),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w700, fontSize: 15, color: _textPrimary),
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildMobileCalCell(day, events: _getEventsForDay(day));
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildMobileCalCell(day,
                events: _getEventsForDay(day), isToday: true);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildMobileCalCell(day,
                events: _getEventsForDay(day), isSelected: true);
          },
          outsideBuilder: (context, day, focusedDay) {
            return _buildMobileCalCell(day, isOutside: true);
          },
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
                /*   if (event.time.isNotEmpty)
                  Text(event.time,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: _textSecondary)), */
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
          _buildStatusRow(
              'Total Visits', _totalVisits, _totalEmployees, _green),
          const SizedBox(height: 10),
          _buildStatusRow(
              'Pending Approvals', _pendingApprovals, _totalEmployees, _orange),
          const SizedBox(height: 10),
          // 'Remote' data is not available from this API. Using a placeholder.
          _buildStatusRow('Remote', 0, _totalEmployees, _accentSecondary),
          const SizedBox(height: 16),
          // Pie-like row
          Row(
            children: [
              _buildStatChip(_totalVisits.toString(), 'Visits', _green),
              const SizedBox(width: 6),
              _buildStatChip(_pendingApprovals.toString(), 'Pending', _orange),
              const SizedBox(width: 6),
              _buildStatChip('0', 'Remote', _accentSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int value, int total, Color color) {
    final pct = total > 0 ? value / total : 0.0;
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800, fontSize: 18, color: color)),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500)),
            ),
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

// ── Day Events Detail Screen ───────────────────────────────────────────────────
class _DayEventsScreen extends StatelessWidget {
  final DateTime day;
  final List<_Event> events;

  const _DayEventsScreen({required this.day, required this.events});

  static const Color _sidebar = Color(0xFF1E1E2E);
  static const Color _mainBg = Color(0xFFF5F7FA);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    // Extract PJPInfo objects (non-null) from events
    final pjpList = events.map((e) => e.pjpInfo).whereType<PJPInfo>().toList();

    return Scaffold(
      backgroundColor: _mainBg,
      appBar: AppBar(
        backgroundColor: _sidebar,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          DateFormat('EEEE, d MMMM yyyy').format(day),
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF2E2E42), height: 1),
        ),
      ),
      body: SafeArea(
        child: pjpList.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy_rounded,
                        size: 56, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('No PJP entries for this day',
                        style: GoogleFonts.inter(
                            color: _textSecondary, fontSize: 14)),
                  ],
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: pjpList.length,
                itemBuilder: (context, index) {
                  final pjp = pjpList[index];
                  return _PjpInfoCard(
                    pjp: pjp,
                    color: events[index].color,
                  );
                },
              ),
      ),
    );
  }
}

// ── PJP Info Card ─────────────────────────────────────────────────────────────
class _PjpInfoCard extends StatelessWidget {
  final PJPInfo pjp;
  final Color color;

  const _PjpInfoCard({required this.pjp, required this.color});

  static const Color _textPrimary = Color(0xFF1A1D2E);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _divider = Color(0xFFE8EDF2);
  static const Color _accent = Color(0xFF26C6DA);
  static const Color _green = Color(0xFF4CAF90);
  static const Color _orange = Color(0xFFFF8A65);

  Color _statusColor(String status) {
    final s = status.trim().toLowerCase();
    if (s.contains('approved')) return _green;
    if (s.contains('pending')) return _orange;
    if (s.contains('reject')) return const Color(0xFFEF5350);
    return _textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final hasLocations =
        pjp.getDetailedPJP != null && pjp.getDetailedPJP!.isNotEmpty;
    final validLocations = pjp.getDetailedPJP
            ?.where((d) => d.Latitude != 0 || d.Longitude != 0)
            .toList() ??
        [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header strip ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pjp.displayName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PJP ID: ${pjp.PJP_Id}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(pjp.ApprovalStatus)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _statusColor(pjp.ApprovalStatus)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    pjp.ApprovalStatus,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(pjp.ApprovalStatus),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Info rows ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _infoRow(
                    Icons.calendar_today_rounded,
                    'From Date',
                    DateFormat('yyyy-MM-dd')
                        .format(DateTime.parse(pjp.fromDate)),
                    _accent),
                _dividerLine(),
                _infoRow(
                    Icons.event_rounded,
                    'To Date',
                    DateFormat('yyyy-MM-dd').format(DateTime.parse(pjp.toDate)),
                    _accent),
                // _dividerLine(),
                /* _infoRow(
                    Icons.info_outline_rounded, 'Status', pjp.Status, _orange), */
                if (pjp.remarks.trim().isNotEmpty &&
                    pjp.remarks.trim() != 'NA') ...[
                  _dividerLine(),
                  _infoRow(Icons.notes_rounded, 'Remarks', pjp.remarks,
                      _textSecondary),
                ],
                /*  if (pjp.isSelfPJP.isNotEmpty) ...[
                  _dividerLine(),
                  _infoRow(
                    Icons.person_pin_rounded,
                    'Self PJP',
                    pjp.isSelfPJP.trim() == '1' ? 'Yes' : 'No',
                    _textSecondary,
                  ),
                ], */
              ],
            ),
          ),

          // ── Detailed visits section ────────────────────────────────────────
          if (hasLocations) ...[
            const Divider(height: 1, color: _divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 14, color: _accent),
                  const SizedBox(width: 6),
                  Text(
                    '${pjp.getDetailedPJP!.length} Visit${pjp.getDetailedPJP!.length > 1 ? 's' : ''} Scheduled',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary),
                  ),
                  const Spacer(),
                  if (validLocations.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _MapScreen(
                              title: '${pjp.displayName} – Visits',
                              visits: validLocations,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map_rounded, size: 14),
                      label: Text('View on Map',
                          style: GoogleFonts.inter(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: _accent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),
            // Visit tiles
            ...pjp.getDetailedPJP!.map((visit) => _VisitTile(
                  visit: visit,
                  isViewOnly: pjp.isSelfPJP.trim() != '1',
                )),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _textPrimary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerLine() =>
      const Divider(height: 1, color: Color(0xFFF0F0F5), thickness: 1);
}

// ── Visit Tile (inside PJP card) ──────────────────────────────────────────────
class _VisitTile extends StatelessWidget {
  final GetDetailedPJP visit;
  final bool isViewOnly;

  const _VisitTile({required this.visit, required this.isViewOnly});

  static const Color _textPrimary = Color(0xFF1A1D2E);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _green = Color(0xFF4CAF90);
  static const Color _orange = Color(0xFFFF8A65);
  static const Color _divider = Color(0xFFE8EDF2);

  Color _statusColor(String s) {
    final lower = s.trim().toLowerCase();
    if (lower.contains('check in')) return _green;
    if (lower.contains('check out')) return _orange;
    if (lower.contains('complete')) return const Color(0xFF26C6DA);
    return _textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var hiveBox = await Utility.openBox();
        int employeeId =
            int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuestionListScreen(
                    cvfView: visit,
                    PJPCVF_Id: int.parse(visit.PJPCVF_Id),
                    employeeId: employeeId,
                    mCategory: visit.purpose?.first.categoryName ?? '',
                    mCategoryId: visit.purpose?.first.categoryId ?? '',
                    isViewOnly: isViewOnly,
                  )),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    visit.franchiseeName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(visit.Status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    visit.Status,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(visit.Status),
                    ),
                  ),
                ),
              ],
            ),
            if (visit.franchiseeCode.isNotEmpty &&
                visit.franchiseeCode != 'NA') ...[
              const SizedBox(height: 2),
              Text(
                'Code: ${visit.franchiseeCode}',
                style: GoogleFonts.inter(fontSize: 11, color: _textSecondary),
              ),
            ],
            if (visit.ActivityTitle.isNotEmpty &&
                visit.ActivityTitle != 'NA') ...[
              const SizedBox(height: 2),
              Text(
                visit.ActivityTitle,
                style: GoogleFonts.inter(fontSize: 11, color: _textSecondary),
              ),
            ],
            if (visit.visitDate.trim().isNotEmpty &&
                visit.visitDate.trim() != 'NA') ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    '${visit.visitDate}  ${visit.visitTime}',
                    style:
                        GoogleFonts.inter(fontSize: 11, color: _textSecondary),
                  ),
                ],
              ),
            ],
            if (visit.Address.trim().isNotEmpty &&
                visit.Address.trim() != 'NA') ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 12, color: Color(0xFF26C6DA)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      visit.Address,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: _textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Map Screen ────────────────────────────────────────────────────────────────
class _MapScreen extends StatefulWidget {
  final String title;
  final List<GetDetailedPJP> visits;

  const _MapScreen({required this.title, required this.visits});

  @override
  State<_MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<_MapScreen> {
  static const Color _sidebar = Color(0xFF1E1E2E);
  static const Color _textPrimary = Color(0xFF1A1D2E);
  static const Color _textSecondary = Color(0xFF6B7280);

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  void _buildMarkers() {
    for (int i = 0; i < widget.visits.length; i++) {
      final visit = widget.visits[i];
      if (visit.Latitude == 0 && visit.Longitude == 0) continue;
      _markers.add(
        Marker(
          markerId: MarkerId('visit_${visit.PJPCVF_Id}_$i'),
          position: LatLng(visit.Latitude, visit.Longitude),
          infoWindow: InfoWindow.noText,
          onTap: () => _showVisitDetails(visit),
        ),
      );
    }
  }

  LatLng get _initialCenter {
    if (widget.visits.isNotEmpty) {
      final first = widget.visits.first;
      return LatLng(first.Latitude, first.Longitude);
    }
    return const LatLng(20.5937, 78.9629); // centre of India fallback
  }

  void _showVisitDetails(GetDetailedPJP visit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VisitDetailSheet(visit: visit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _sidebar,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF2E2E42), height: 1),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialCenter,
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
                // Fit all markers
                if (widget.visits.length > 1) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _fitBounds();
                  });
                }
              },
              myLocationButtonEnabled: true,
              myLocationEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
            ),
            // Legend bar at top
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Color(0xFF26C6DA), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.visits.length} location${widget.visits.length > 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Tap a marker for details',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: _textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fitBounds() {
    if (_mapController == null) return;
    double minLat = widget.visits.first.Latitude;
    double maxLat = widget.visits.first.Latitude;
    double minLng = widget.visits.first.Longitude;
    double maxLng = widget.visits.first.Longitude;

    for (final v in widget.visits) {
      if (v.Latitude < minLat) minLat = v.Latitude;
      if (v.Latitude > maxLat) maxLat = v.Latitude;
      if (v.Longitude < minLng) minLng = v.Longitude;
      if (v.Longitude > maxLng) maxLng = v.Longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.01, minLng - 0.01),
          northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
        ),
        60,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// ── Visit Detail Bottom Sheet ─────────────────────────────────────────────────
class _VisitDetailSheet extends StatelessWidget {
  final GetDetailedPJP visit;

  const _VisitDetailSheet({required this.visit});

  static const Color _textPrimary = Color(0xFF1A1D2E);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _accent = Color(0xFF26C6DA);
  static const Color _green = Color(0xFF4CAF90);
  static const Color _orange = Color(0xFFFF8A65);
  static const Color _divider = Color(0xFFE8EDF2);

  Color _statusColor(String s) {
    final lower = s.trim().toLowerCase();
    if (lower.contains('check in')) return _green;
    if (lower.contains('check out')) return _orange;
    if (lower.contains('complete')) return _accent;
    return _textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.franchiseeName,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        if (visit.franchiseeCode.isNotEmpty &&
                            visit.franchiseeCode != 'NA')
                          Text(
                            'Code: ${visit.franchiseeCode}',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: _textSecondary),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(visit.Status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            _statusColor(visit.Status).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      visit.Status,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(visit.Status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: _divider),
            // Details list
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                children: [
                  if (visit.ActivityTitle != 'NA' &&
                      visit.ActivityTitle.isNotEmpty)
                    _detailRow(Icons.work_outline_rounded, 'Activity',
                        visit.ActivityTitle),
                  _detailRow(Icons.calendar_today_rounded, 'Visit Date',
                      visit.visitDate),
                  _detailRow(
                      Icons.access_time_rounded, 'Visit Time', visit.visitTime),
                  if (visit.DateTimeIn.trim().isNotEmpty &&
                      visit.DateTimeIn.trim() != 'NA')
                    _detailRow(
                        Icons.login_rounded, 'Check-in Time', visit.DateTimeIn),
                  if (visit.CheckInAddress.trim().isNotEmpty &&
                      visit.CheckInAddress.trim() != 'NA')
                    _detailRow(Icons.location_on_rounded, 'Check-in Address',
                        visit.CheckInAddress),
                  if (visit.DateTimeOut.trim().isNotEmpty &&
                      visit.DateTimeOut.trim() != 'NA')
                    _detailRow(Icons.logout_rounded, 'Check-out Time',
                        visit.DateTimeOut),
                  if (visit.CheckOutAddress.trim().isNotEmpty &&
                      visit.CheckOutAddress.trim() != 'NA')
                    _detailRow(Icons.location_off_rounded, 'Check-out Address',
                        visit.CheckOutAddress),
                  if (visit.Address.trim().isNotEmpty &&
                      visit.Address.trim() != 'NA')
                    _detailRow(Icons.place_rounded, 'Address', visit.Address),
                  _detailRow(
                      Icons.verified_rounded, 'Approval', visit.approvalStatus),
                  if (visit.purpose != null && visit.purpose!.isNotEmpty)
                    _detailRow(
                      Icons.category_rounded,
                      'Purpose',
                      visit.purpose!.map((p) => p.categoryName).join(', '),
                    ),
                  _detailRow(
                    Icons.gps_fixed_rounded,
                    'Coordinates',
                    '${visit.Latitude.toStringAsFixed(5)}, ${visit.Longitude.toStringAsFixed(5)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _accent),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
  final PJPInfo? pjpInfo;

  const _Event({
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
    required this.start,
    required this.end,
    this.pjpInfo,
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
