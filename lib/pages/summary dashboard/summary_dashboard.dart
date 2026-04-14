import 'package:Intranet/api/ServiceHandler.dart';
import 'package:Intranet/api/request/pjp/get_pjp_report_request.dart';
import 'package:Intranet/api/request/pjp/update_pjpstatuslist_request.dart';
import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/iface/onClick.dart';
import 'package:Intranet/pages/iface/onResponse.dart';
import 'package:Intranet/pages/outdoor/apply_outdoor.dart';
import 'package:Intranet/pages/pjp/add_new_pjp.dart';
import 'package:Intranet/pages/pjp/cvf/add_cvf.dart';
import 'package:Intranet/pages/pjp/cvf/cvf_questions.dart';
import 'package:Intranet/pages/pjp/models/PjpModel.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saathi/core/utility/toastUtility.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class SummaryDashboard extends StatefulWidget {
  const SummaryDashboard({super.key});

  @override
  State<SummaryDashboard> createState() => _SummaryDashboardState();
}

class _SummaryDashboardState extends State<SummaryDashboard>
    implements onResponse {
  int employeeId = 0;
  String employeeCode = '';
  String employeeName = '';
  String managerName = '';
  String zone = '';
  int businessId = 0;

  // ── colors ───────────────────────────────────────────────────────────────
  Color _sidebar = kPrimaryLightColor;
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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String _currentFormat = 'Month';

  // API Data state
  bool _isLoading = true;
  List<PJPInfo> _rawPjpData = [];
  List<MYTEAM> _myTeamData = [];
  bool _isTeamView = false;
  List<PJPInfo> _pjpData = [];
  List<PJPInfo> _filteredPjpData = [];
  String _employeeRoleType = '';
  Set<String> _allTeamMembers = {};
  Set<String> _selectedTeamMembers = {};
  Set<String> _allZones = {};
  Set<String> _selectedZones = {};
  final List<_Event> _events = [];

  // Search state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _mobileSearchFocusNode = FocusNode();
  bool _isMobileSearchActive = false;

  // KPI state
  int _totalEmployees = 0;
  int _totalTeamSize = 0;
  int _totalVisits = 0;
  int _pendingApprovals = 0; // This might need another API
  int _approvedPJP = 0;
  int _totalPJP = 0;
  int _rejectedPJP = 0;

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

  Color _getStatusColor(String status) {
    final s = status.trim().toLowerCase();
    if (s.contains('approved')) return _green;
    if (s.contains('pending')) return _orange;
    if (s.contains('reject')) return _red;
    return _textSecondary;
  }

  @override
  void initState() {
    super.initState();

    _fetchDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mobileSearchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    try {
      var hiveBox = await Utility.openBox();
      employeeId =
          int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
      employeeCode = hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE) as String;
      managerName = hiveBox.get(LocalConstant.KEY_MANAGER_NAME) as String;
      employeeName = hiveBox.get(LocalConstant.KEY_FIRST_NAME) +
          ' ' +
          hiveBox.get(LocalConstant.KEY_LAST_NAME);
      _employeeRoleType = hiveBox.get(LocalConstant.KEY_EMP_TYPE);
      zone = hiveBox.get(LocalConstant.KEY_ZONE) as String? ?? 'N/A';
      businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);
      String? emprole_type = hiveBox.get(LocalConstant.KEY_EMP_TYPE);
      if (emprole_type?.toLowerCase() == 'emp') {
        _isTeamView = false;
      }

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      PJPReportRequest request = PJPReportRequest(
        employeeCode: employeeCode,
        businessId: businessId.toString(),
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
          _rawPjpData = value.responseData;
          _myTeamData = value.myTeamData;
          _updateViewMode();
          _isLoading = false;
        });
      }
    }
  }

  void _updateViewMode() {
    if (_isTeamView) {
      _pjpData =
          _rawPjpData.where((pjp) => pjp.isSelfPJP.trim() != '1').toList();
    } else {
      _pjpData =
          _rawPjpData.where((pjp) => pjp.isSelfPJP.trim() == '1').toList();
    }

    // Populate all team members and select all by default
    _allTeamMembers = _pjpData.map((pjp) => pjp.displayName).toSet();
    if (_isTeamView) {
      _allTeamMembers.addAll(
        _myTeamData
            .map((t) => t.displayName?.trim() ?? '')
            .where((name) => name.isNotEmpty),
      );
    }
    _selectedTeamMembers = Set.from(_allTeamMembers);

    // Populate all zones and select all by default
    _allZones = _pjpData
        .map((pjp) =>
            (pjp.zone?.trim() ?? 'N/A').isEmpty ? 'N/A' : pjp.zone!.trim())
        .toSet();
    if (_isTeamView) {
      _allZones.addAll(
        _myTeamData.map(
            (t) => (t.zone?.trim() ?? 'N/A').isEmpty ? 'N/A' : t.zone!.trim()),
      );
    }
    _selectedZones = Set.from(_allZones);

    // Assign colors once
    _assignUserColors();

    _processFilteredData();
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

  void _assignUserColors() {
    _userColors.clear();
    _colorIndex = 0;
    // Sort to have a consistent color assignment
    final sortedMembers = _allTeamMembers.toList()..sort();
    for (final userName in sortedMembers) {
      _getColorForUser(userName); // This will assign a color if not present
    }
  }

  void _processFilteredData() {
    _filteredPjpData = _pjpData.where((pjp) {
      final bool matchesTeam = _selectedTeamMembers.contains(pjp.displayName);
      final String zoneKey =
          (pjp.zone?.trim() ?? 'N/A').isEmpty ? 'N/A' : pjp.zone!.trim();
      final bool matchesZone = _selectedZones.contains(zoneKey);

      final bool matchesSearch = _searchQuery.isEmpty ||
          pjp.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pjp.PJP_Id.toString().contains(_searchQuery) ||
          pjp.remarks.toString().contains(_searchQuery);

      return matchesTeam && matchesZone && matchesSearch;
    }).toList();

    int totalVisits = 0;
    int pendingApprovals = 0;
    int approvedPjps = 0;
    int rejectedPjps = 0;
    List<_Event> newEvents = [];

    Set<String> teamMembersInFilteredData = {};

    _userEventCount.clear();

    for (var pjpInfo in _filteredPjpData) {
      final userName = pjpInfo.displayName;
      final baseColor = _getStatusColor(pjpInfo.ApprovalStatus);

      newEvents.add(_Event(
        title: '${pjpInfo.displayName}',
        time: pjpInfo.Status,
        color: baseColor,
        icon: Icons.location_on,
        start: Utility.convertDate(pjpInfo.fromDate),
        end: Utility.convertDate(pjpInfo.toDate),
        pjpInfo: pjpInfo,
      ));
      teamMembersInFilteredData.add(pjpInfo.displayName);

      if (pjpInfo.getDetailedPJP != null) {
        totalVisits += pjpInfo.getDetailedPJP!.length;
      }

      if (pjpInfo.ApprovalStatus.trim().toLowerCase() == 'pending') {
        pendingApprovals++;
      }
      if (pjpInfo.ApprovalStatus.trim().toLowerCase() == 'approved') {
        approvedPjps++;
      }
      if (pjpInfo.ApprovalStatus.trim().toLowerCase().contains('reject')) {
        rejectedPjps++;
      }
    }

    // Update state variables
    _totalVisits = totalVisits;
    _pendingApprovals = pendingApprovals;
    _approvedPJP = approvedPjps;
    _rejectedPJP = rejectedPjps;
    _totalPJP = _filteredPjpData.length;
    _totalEmployees = teamMembersInFilteredData.length;
    _totalTeamSize = _selectedTeamMembers.length;
    _events.clear();

    // ── Calculate Layout Slots (Lanes) ──────────────────────────────────────
    // 1. Sort events: Start Date ASC, then Duration DESC
    newEvents.sort((a, b) {
      int cmp = a.start.compareTo(b.start);
      if (cmp != 0) return cmp;
      return b.end.difference(b.start).compareTo(a.end.difference(a.start));
    });

    // 2. Assign slots
    List<DateTime> laneEndDates = [];
    List<_Event> slottedEvents = [];

    for (var event in newEvents) {
      int lane = -1;
      // Find the first lane where this event fits (starts after lane ends)
      for (int i = 0; i < laneEndDates.length; i++) {
        if (event.start.isAfter(laneEndDates[i])) {
          lane = i;
          laneEndDates[i] = event.end;
          break;
        }
      }

      // If no fit, add new lane
      if (lane == -1) {
        lane = laneEndDates.length;
        laneEndDates.add(event.end);
      }

      slottedEvents.add(event.copyWith(slotIndex: lane));
    }

    _events.addAll(slottedEvents);
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
      return const Scaffold(
          body: SafeArea(child: Center(child: CircularProgressIndicator())));
    }

    return Scaffold(
      backgroundColor: _mainBg,
      appBar: _isMobile(w) ? _buildMobileAppBar() : null,
      // drawer:
      //     _isMobile(w) ? Drawer(child: _buildSidebar(compact: false)) : null,
      body: SafeArea(
        child: _isMobile(w)
            ? _buildMobileBody()
            : Row(
                children: [
                  if (_isDesktop(w) && _isSidebarVisible)
                    SizedBox(width: 280, child: _buildSidebar(compact: false)),
                  // else if (_isTablet(w) && _isSidebarVisible)
                  //   SizedBox(width: 240, child: _buildSidebar(compact: true)),
                  Expanded(child: _buildMainContent(w)),
                ],
              ),
      ),
    );
  }

  // ── AppBar (mobile) ───────────────────────────────────────────────────────
  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: _sidebar,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: _isMobileSearchActive ? 0 : 16,
      title: _isMobileSearchActive
          ? RawAutocomplete<PJPInfo>(
              textEditingController: _searchController,
              focusNode: _mobileSearchFocusNode,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<PJPInfo>.empty();
                }
                return _pjpData.where((pjp) {
                  final query = textEditingValue.text.toLowerCase();
                  return pjp.displayName.toLowerCase().contains(query) ||
                      pjp.PJP_Id.toString().contains(query) ||
                      pjp.remarks.toLowerCase().contains(query);
                });
              },
              onSelected: (PJPInfo selection) {
                setState(() {
                  _searchController.text = selection.PJP_Id.toString();
                  _searchQuery = _searchController.text;
                  _focusedDay = Utility.convertDate(selection.fromDate);
                  _selectedDay = Utility.convertDate(selection.fromDate);
                  _processFilteredData();
                  _isMobileSearchActive = false; // Close search on mobile
                  _mobileSearchFocusNode.unfocus();
                });
              },
              displayStringForOption: (PJPInfo option) =>
                  '${option.displayName} - PJP ID: ${option.PJP_Id}',
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.5),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final PJPInfo option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: ListTile(
                              title: Text(
                                  '${option.displayName} - PJP: ${option.PJP_Id}'),
                              subtitle: Text(
                                option.remarks,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return Container(
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.center,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                    cursorColor: _accent,
                    decoration: InputDecoration(
                      fillColor: Colors.white54.withOpacity(0.15),
                      hintText: 'Search...',
                      hintStyle: GoogleFonts.inter(
                          color: Colors.white54, fontSize: 14),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.white54, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.cancel,
                                  color: Colors.white54, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _processFilteredData();
                                });
                              },
                            )
                          : null,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _processFilteredData();
                      });
                    },
                  ),
                );
              },
            )
          : Text('PJP Dashboard',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      bottom: _isMobileSearchActive
          ? null
          : PreferredSize(
              preferredSize: _employeeRoleType.toLowerCase() == 'emp'
                  ? Size.zero
                  : const Size.fromHeight(50),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _employeeRoleType.toLowerCase() == 'emp'
                      ? const SizedBox.shrink()
                      : _buildViewSwitcher(isDark: true),
                ),
              ),
            ),
      actions: [
        if (_isMobileSearchActive)
          TextButton(
            onPressed: () {
              setState(() {
                _isMobileSearchActive = false;
                _searchQuery = '';
                _searchController.clear();
                _processFilteredData();
              });
            },
            child:
                Text('Cancel', style: GoogleFonts.inter(color: Colors.white)),
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isMobileSearchActive = true;
              });
            },
          ),
          if (!_isTeamView) ...[
            IconButton(
              icon: const Icon(Icons.add_task),
              tooltip: 'Add PJP',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddNewPJPScreen(
                            employeeId: employeeId,
                            businessId: businessId,
                            currentDate: DateTime.now(),
                          )),
                );
                print('Add PJP result: $result');
                if (result != null && result is PJPModel) {
                  setState(() {
                    PJPInfo pjpInfo = PJPInfo(
                        PJP_Id: result.pjpId.toString(),
                        displayName: managerName,
                        fromDate: result.fromDate.toString(),
                        toDate: result.toDate.toString(),
                        remarks: result.remark,
                        isSelfPJP: '1',
                        Status: 'Check In',
                        ApprovalStatus: 'Pending');
                    _rawPjpData.add(pjpInfo);
                    _updateViewMode();
                  });
                }
              },
            ),
          ],
          if (_isTeamView)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showMobileFilter,
            ),
        ]
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
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PJP Dashboard',
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

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  // Mini Calendar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _buildSidebarMiniCalendar(compact: compact),
                  ),
                  const Divider(
                      color: Color(0xFF2E2E42), thickness: 1, height: 1),
                  // Events
                  _buildSidebarDaySection(
                    label: 'TODAY  ${DateFormat('M/d/yy').format(now)}',
                    events: _getEventsForDay(now),
                    compact: compact,
                    day: now,
                  ),
                  _buildSidebarDaySection(
                    label:
                        'TOMORROW  ${DateFormat('M/d/yy').format(now.add(const Duration(days: 1)))}',
                    events: _getEventsForDay(now.add(const Duration(days: 1))),
                    compact: compact,
                    day: now.add(const Duration(days: 1)),
                  ),
                  _buildSidebarDaySection(
                    label:
                        '${DateFormat('EEEE').format(now.add(const Duration(days: 2))).toUpperCase()}  ${DateFormat('M/d/yy').format(now.add(const Duration(days: 2)))}',
                    events: _getEventsForDay(now.add(const Duration(days: 2))),
                    compact: compact,
                    day: now.add(const Duration(days: 2)),
                  ),
                  _buildSidebarDaySection(
                    label:
                        '${DateFormat('EEEE').format(now.add(const Duration(days: 3))).toUpperCase()}  ${DateFormat('M/d/yy').format(now.add(const Duration(days: 3)))}',
                    events: _getEventsForDay(now.add(const Duration(days: 3))),
                    compact: compact,
                    day: now.add(const Duration(days: 3)),
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
        onDaySelected: (selected, focused) async {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
          final events = _getEventsForDay(selected);
          if (events.isNotEmpty && mounted) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _DayEventsScreen(
                  day: selected,
                  events: events,
                  empCode: employeeCode,
                  empName: employeeName,
                ),
              ),
            );
            if (result == true) {
              setState(() {
                _processFilteredData();
              });
            }
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
        calendarStyle: const CalendarStyle(
            outsideDaysVisible: true,
            cellMargin: EdgeInsets.all(2),
            markersMaxCount: 0),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) =>
              _buildSidebarCalCell(day, events: _getEventsForDay(day)),
          todayBuilder: (context, day, focusedDay) => _buildSidebarCalCell(day,
              events: _getEventsForDay(day), isToday: true),
          selectedBuilder: (context, day, focusedDay) => _buildSidebarCalCell(
              day,
              events: _getEventsForDay(day),
              isSelected: true),
          outsideBuilder: (context, day, focusedDay) =>
              _buildSidebarCalCell(day, isOutside: true),
        ),
      ),
    );
  }

  Widget _buildSidebarCalCell(DateTime day,
      {List<_Event> events = const [],
      bool isToday = false,
      bool isSelected = false,
      bool isOutside = false}) {
    if (isOutside) {
      return Center(
        child: Text(
          '${day.day}',
          style: GoogleFonts.inter(color: Colors.white24, fontSize: 11),
        ),
      );
    }
    return Center(
      child: Container(
        width: 28,
        height: 28,
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
                  color: isToday
                      ? Colors.black
                      : (isSelected ? Colors.white : Colors.white70),
                  fontSize: 11,
                  fontWeight: (isToday || isSelected)
                      ? FontWeight.w700
                      : FontWeight.normal),
            ),
            if (events.isNotEmpty)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: _red,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF1E1E2E), width: 1.5)),
                  constraints:
                      const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    '${events.length}',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 8,
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

  void _showMobileFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final sortedMembers = _allTeamMembers.toList()..sort();
            final sortedZones = _allZones.toList()..sort();
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Team Members',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white60),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF2E2E42)),
                  CheckboxListTile(
                    title: Text('Select All',
                        style: GoogleFonts.inter(color: Colors.white)),
                    value:
                        _selectedTeamMembers.length == _allTeamMembers.length &&
                            _allTeamMembers.isNotEmpty,
                    activeColor: _accent,
                    checkColor: Colors.black,
                    onChanged: (val) {
                      setSheetState(() {
                        if (val == true) {
                          _selectedTeamMembers = Set.from(_allTeamMembers);
                        } else {
                          _selectedTeamMembers.clear();
                        }
                      });
                      setState(() {
                        _processFilteredData();
                      });
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFF2E2E42)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedMembers.length,
                      itemBuilder: (context, index) {
                        final employeeName = sortedMembers[index];
                        return CheckboxListTile(
                          title: Text(employeeName,
                              style: GoogleFonts.inter(color: Colors.white)),
                          value: _selectedTeamMembers.contains(employeeName),
                          activeColor: _accent,
                          checkColor: Colors.black,
                          secondary: Icon(Icons.circle,
                              color: _userColors[employeeName] ?? Colors.grey,
                              size: 12),
                          onChanged: (val) {
                            setSheetState(() {
                              if (val == true) {
                                _selectedTeamMembers.add(employeeName);
                              } else {
                                _selectedTeamMembers.remove(employeeName);
                              }
                            });
                            setState(() {
                              _processFilteredData();
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Filter Zones',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  const Divider(color: Color(0xFF2E2E42)),
                  CheckboxListTile(
                    title: Text('Select All Zones',
                        style: GoogleFonts.inter(color: Colors.white)),
                    value: _selectedZones.length == _allZones.length &&
                        _allZones.isNotEmpty,
                    activeColor: _accent,
                    checkColor: Colors.black,
                    onChanged: (val) {
                      setSheetState(() {
                        if (val == true) {
                          _selectedZones = Set.from(_allZones);
                        } else {
                          _selectedZones.clear();
                        }
                      });
                      setState(() {
                        _processFilteredData();
                      });
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedZones.length,
                      itemBuilder: (context, index) {
                        final zone = sortedZones[index];
                        return CheckboxListTile(
                          title: Text(zone,
                              style: GoogleFonts.inter(color: Colors.white)),
                          value: _selectedZones.contains(zone),
                          activeColor: _accent,
                          checkColor: Colors.black,
                          onChanged: (val) {
                            setSheetState(() => val == true
                                ? _selectedZones.add(zone)
                                : _selectedZones.remove(zone));
                            setState(() {
                              _processFilteredData();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSidebarDaySection({
    required String label,
    required List<_Event> events,
    required bool compact,
    required DateTime day,
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
            ...events.map((e) => _buildSidebarEventTile(e, compact, day)),
        ],
      ),
    );
  }

  Widget _buildSidebarEventTile(_Event event, bool compact, DateTime day) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _DayEventsScreen(
                day: day,
                events: _getEventsForDay(day),
                empCode: employeeCode,
                empName: employeeName,
              ),
            ),
          );
        },
        child: Padding(
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
        ),
      ),
    );
  }

  // ── main content ──────────────────────────────────────────────────────────
  Widget _buildMainContent(double w) {
    final bool desktop = _isDesktop(w);
    return Column(
      children: [
        // Top bar
        _buildTopBar(desktop: desktop, width: w),
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

  Widget _buildTopBar({required bool desktop, required double width}) {
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
          _isTablet(width)
              ? SizedBox.shrink()
              : InkWell(
                  onTap: () =>
                      setState(() => _isSidebarVisible = !_isSidebarVisible),
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
          // Search
          if (desktop) ...[
            SizedBox(width: 16),
            SizedBox(
              width: 220,
              child: RawAutocomplete<PJPInfo>(
                textEditingController: _searchController,
                focusNode: _searchFocusNode,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<PJPInfo>.empty();
                  }
                  return _pjpData.where((pjp) {
                    final query = textEditingValue.text.toLowerCase();
                    return pjp.displayName.toLowerCase().contains(query) ||
                        pjp.PJP_Id.toString().contains(query) ||
                        pjp.remarks.toLowerCase().contains(query);
                  });
                },
                onSelected: (PJPInfo selection) {
                  setState(() {
                    _searchController.text = selection.PJP_Id.toString();
                    _searchQuery = _searchController.text;
                    _focusedDay = Utility.convertDate(selection.fromDate);
                    _selectedDay = Utility.convertDate(selection.fromDate);
                    _processFilteredData();
                    _searchFocusNode.unfocus();
                  });
                },
                displayStringForOption: (PJPInfo option) =>
                    '${option.displayName} - PJP ID: ${option.PJP_Id}',
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxHeight: 200, maxWidth: 350),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final PJPInfo option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: ListTile(
                                title: Text(
                                    '${option.displayName} - PJP: ${option.PJP_Id}'),
                                subtitle: Text(
                                  option.remarks,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                fieldViewBuilder: (context, textEditingController, focusNode,
                    onFieldSubmitted) {
                  return SizedBox(
                    height: 34,
                    child: TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _processFilteredData();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search PJP...',
                        hintStyle: GoogleFonts.inter(
                            fontSize: 12, color: _textSecondary),
                        prefixIcon: const Icon(Icons.search,
                            size: 16, color: _textSecondary),
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
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    size: 16, color: _textSecondary),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _processFilteredData();
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const Spacer(),
          if (!_isTeamView) ...[
            _buildHeaderActionBtn(Icons.add_task, 'Add PJP', () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddNewPJPScreen(
                          employeeId: employeeId,
                          businessId: businessId,
                          currentDate: DateTime.now(),
                        )),
              );
              print('Add PJP result: $result');
              if (result != null && result is PJPModel) {
                setState(() {
                  PJPInfo pjpInfo = PJPInfo(
                      PJP_Id: result.pjpId.toString(),
                      displayName: employeeName,
                      fromDate: result.fromDate.toString(),
                      toDate: result.toDate.toString(),
                      remarks: result.remark,
                      isSelfPJP: '1',
                      Status: 'Check In',
                      zone: zone,
                      managerName: managerName,
                      ApprovalStatus: 'Pending');
                  _rawPjpData.add(pjpInfo);
                  _updateViewMode();
                });
              }
            }),
            const SizedBox(width: 8),
          ],
          if (desktop && _isTeamView) ...[
            _buildDesktopFilterButton(),
            const SizedBox(width: 12),
          ],
          // Format switcher (desktop only)
          if (desktop) _buildFormatSwitcher(),
          const SizedBox(width: 12),
          if (_employeeRoleType.toLowerCase() != 'emp') ...[
            _buildViewSwitcher(),
          ],

          /* const SizedBox(width: 12),
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

  Widget _buildViewSwitcher({bool isDark = false}) {
    final bgColor = isDark ? Colors.black26 : const Color(0xFFF1F5F9);
    final activeColor = isDark ? Colors.white.withOpacity(0.2) : Colors.white;
    final inactiveTextColor = isDark ? Colors.white60 : _textSecondary;
    final activeTextColor = isDark ? Colors.white : _textPrimary;

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _switcherBtn('Self', !_isTeamView, activeColor, activeTextColor,
              inactiveTextColor),
          _switcherBtn('My Team', _isTeamView, activeColor, activeTextColor,
              inactiveTextColor),
        ],
      ),
    );
  }

  Widget _switcherBtn(String label, bool isActive, Color activeBg,
      Color activeText, Color inactiveText) {
    return InkWell(
      onTap: () {
        if ((label == 'My Team') != _isTeamView) {
          setState(() {
            _isTeamView = label == 'My Team';
            _updateViewMode();
          });
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive && activeBg == Colors.white
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? activeText : inactiveText,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderActionBtn(
      IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: Colors.white),
      label: Text(label,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDesktopFilterButton() {
    return InkWell(
      onTap: _showDesktopFilterDialog,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: _divider),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list_rounded,
                size: 16, color: _textSecondary),
            const SizedBox(width: 8),
            Text('Filters',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary)),
          ],
        ),
      ),
    );
  }

  void _showDesktopFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 400,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filters',
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: _divider),
                const SizedBox(height: 16),
                Text('Team Members',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary)),
                const SizedBox(height: 12),
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setDialogState) {
                      final sortedMembers = _allTeamMembers.toList()..sort();
                      return ListView(
                        children: [
                          CheckboxListTile(
                            title: Text('Select All',
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: _textPrimary)),
                            value: _selectedTeamMembers.length ==
                                    _allTeamMembers.length &&
                                _allTeamMembers.isNotEmpty,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  _selectedTeamMembers =
                                      Set.from(_allTeamMembers);
                                } else {
                                  _selectedTeamMembers.clear();
                                }
                              });
                              setState(() {
                                _processFilteredData();
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            activeColor: _accent,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          ...sortedMembers.map((member) {
                            return CheckboxListTile(
                              title: Text(member,
                                  style: GoogleFonts.inter(
                                      fontSize: 13, color: _textPrimary)),
                              value: _selectedTeamMembers.contains(member),
                              onChanged: (val) {
                                setDialogState(() {
                                  if (val == true) {
                                    _selectedTeamMembers.add(member);
                                  } else {
                                    _selectedTeamMembers.remove(member);
                                  }
                                });
                                setState(() {
                                  _processFilteredData();
                                });
                              },
                              secondary: Icon(Icons.circle,
                                  color: _userColors[member] ?? Colors.grey,
                                  size: 10),
                              contentPadding: EdgeInsets.zero,
                              activeColor: _accent,
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text('Zones',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary)),
                const SizedBox(height: 12),
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setDialogState) {
                      final sortedZones = _allZones.toList()..sort();
                      return ListView(
                        children: [
                          CheckboxListTile(
                            title: Text('Select All Zones',
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: _textPrimary)),
                            value: _selectedZones.length == _allZones.length &&
                                _allZones.isNotEmpty,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  _selectedZones = Set.from(_allZones);
                                } else {
                                  _selectedZones.clear();
                                }
                              });
                              setState(() {
                                _processFilteredData();
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            activeColor: _accent,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          ...sortedZones.map((zone) {
                            return CheckboxListTile(
                              title: Text(zone,
                                  style: GoogleFonts.inter(
                                      fontSize: 13, color: _textPrimary)),
                              value: _selectedZones.contains(zone),
                              onChanged: (val) {
                                setDialogState(() {
                                  if (val == true) {
                                    _selectedZones.add(zone);
                                  } else {
                                    _selectedZones.remove(zone);
                                  }
                                });
                                setState(() {
                                  _processFilteredData();
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              activeColor: _accent,
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormatSwitcher() {
    final formats = ['Week', 'Month'];
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: _divider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: formats.map((f) {
          final isSelected = f == _currentFormat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentFormat = f;
                if (f == 'Month') _calendarFormat = CalendarFormat.month;
                if (f == 'Week') _calendarFormat = CalendarFormat.week;
              });
            },
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
    String onLeaveBadge = _filteredPjpData.isNotEmpty
        ? '${((_pendingApprovals / _filteredPjpData.length) * 100).toStringAsFixed(1)}% of PJPs'
        : '0% of PJPs';
    String approvedBadge = _filteredPjpData.isNotEmpty
        ? '${((_approvedPJP / _filteredPjpData.length) * 100).toStringAsFixed(1)}% of PJPs'
        : '0% of PJPs';
    String rejectedBadge = _filteredPjpData.isNotEmpty
        ? '${((_rejectedPJP / _filteredPjpData.length) * 100).toStringAsFixed(1)}% of PJPs'
        : '0% of PJPs';

    final cards = [
      if (_isTeamView)
        _KPICard(
          'Employees',
          '$_totalEmployees / $_totalTeamSize',
          Icons.people_alt_rounded,
          _accent,
          _totalTeamSize > 0
              ? '${((_totalEmployees / _totalTeamSize) * 100).toStringAsFixed(0)}% with PJP'
              : '',
          true,
        ),
      _KPICard('Total PJP', _totalPJP.toString(), Icons.assignment_rounded,
          Colors.blueAccent, '', true),
      _KPICard('CVF', _totalVisits.toString(), Icons.check_circle_rounded,
          _green, presentBadge, true),
      _KPICard('Pending Approvals', _pendingApprovals.toString(),
          FontAwesomeIcons.umbrellaBeach, _orange, onLeaveBadge, false),
      _KPICard('Approved PJPs', _approvedPJP.toString(), Icons.task_alt_rounded,
          _accentSecondary, approvedBadge, true),
      _KPICard('Rejected PJPs', _rejectedPJP.toString(), Icons.cancel_rounded,
          _red, rejectedBadge, false),
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
          calendarFormat: _calendarFormat,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.week: 'Week',
          },
          onDaySelected: (selected, focused) async {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            });
            final events = _getEventsForDay(selected);
            if (events.isNotEmpty && mounted) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _DayEventsScreen(
                    day: selected,
                    events: events,
                    empCode: employeeCode,
                    empName: employeeName,
                  ),
                ),
              );
              if (result == true) {
                setState(() {
                  _processFilteredData();
                });
              }
            }
          },
          onPageChanged: (focused) => setState(() => _focusedDay = focused),
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
              if (format == CalendarFormat.month) _currentFormat = 'Month';
              if (format == CalendarFormat.week) _currentFormat = 'Week';
            });
          },
          headerVisible: false,
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(),
          ),
          daysOfWeekHeight: 36,
          rowHeight: 120,
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
          ...List.generate(3, (index) {
            // Find the event assigned to this slot (index)
            final e = events.firstWhere(
              (ev) => ev.slotIndex == index,
              orElse: () => _Event.empty(),
            );

            if (e.slotIndex == index) {
              final d = DateTime(day.year, day.month, day.day);
              final s = DateTime(e.start.year, e.start.month, e.start.day);
              final eDate = DateTime(e.end.year, e.end.month, e.end.day);
              final isStart = d.isAtSameMomentAs(s);
              final isEnd = d.isAtSameMomentAs(eDate);

              return Padding(
                padding: EdgeInsets.only(
                  top: 2,
                  left: isStart ? 4 : 0,
                  right: isEnd ? 4 : 0,
                ),
                child: Container(
                  height: 20, // Fixed height for alignment
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                              fontSize: 12,
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
            } else {
              // Render a gap if there are events in lower slots (higher indices)
              bool hasHigherEvents = events.any((ev) => ev.slotIndex > index);
              if (hasHigherEvents) {
                return const SizedBox(height: 22); // 20 + 2 top padding
              } else {
                return const SizedBox.shrink();
              }
            }
          }),
          if (events.any((e) => e.slotIndex >= 3))
            Padding(
              padding: const EdgeInsets.only(top: 1, left: 6),
              child: Text(
                  '+${events.where((e) => e.slotIndex >= 3).length} more',
                  style: GoogleFonts.inter(
                      fontSize: 8,
                      color: _accentSecondary,
                      fontWeight: FontWeight.w600)),
            ),
          const Spacer(), // Push content to top
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
        availableGestures: AvailableGestures.horizontalSwipe,
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
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _DayEventsScreen(
                  day: selected,
                  events: events,
                  empCode: employeeCode,
                  empName: employeeName,
                ),
              ),
            );
            if (result == true) {
              setState(() {
                _processFilteredData();
              });
            }
          }
        },
        onPageChanged: (focused) => setState(() => _focusedDay = focused),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w700, fontSize: 15, color: _textPrimary),
        ),
        calendarStyle:
            const CalendarStyle(outsideDaysVisible: false, markersMaxCount: 0),
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
              ...entry.value.map((e) => _buildEventRow(e, entry.key)),
              const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventRow(_Event event, DateTime day) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _DayEventsScreen(
                day: day,
                events: _getEventsForDay(day),
                empCode: employeeCode,
                empName: employeeName,
              ),
            ),
          );
        },
        child: Padding(
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
        ),
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
              // const Icon(Icons.more_horiz, size: 16, color: _textSecondary),
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
class _DayEventsScreen extends StatefulWidget {
  final DateTime day;
  final List<_Event> events;
  final String empName;
  final String empCode;

  const _DayEventsScreen(
      {required this.day,
      required this.events,
      required this.empName,
      required this.empCode});

  @override
  State<_DayEventsScreen> createState() => _DayEventsScreenState();
}

class _DayEventsScreenState extends State<_DayEventsScreen> {
  static const Color _sidebar = kPrimaryLightColor;
  static const Color _mainBg = Color(0xFFF5F7FA);
  static const Color _textSecondary = Color(0xFF6B7280);

  bool _isUpdated = false;

  void _refresh() {
    if (mounted) {
      setState(() {
        _isUpdated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract PJPInfo objects (non-null) from events
    final pjpList =
        widget.events.map((e) => e.pjpInfo).whereType<PJPInfo>().toList();

    return Scaffold(
      backgroundColor: _mainBg,
      appBar: AppBar(
        backgroundColor: _sidebar,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _isUpdated),
        ),
        title: Text(
          DateFormat('EEEE, d MMMM yyyy').format(widget.day),
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
                    color: widget.events[index].color,
                    onUpdated: _refresh,
                    empCode: widget.empCode,
                    empName: widget.empName,
                  );
                },
              ),
      ),
    );
  }
}

class _OnManagerApprovedRejectResponse implements onResponse {
  final BuildContext context;
  final Function(dynamic) onSuccessCallback;

  _OnManagerApprovedRejectResponse({
    required this.context,
    required this.onSuccessCallback,
  });

  @override
  void onStart() {
    Utility.showLoaderDialog(context);
  }

  @override
  void onSuccess(value) {
    onSuccessCallback(value);
    Navigator.of(context).pop();
  }

  @override
  void onError(value) {
    Navigator.of(context).pop(); // Dismiss loader
    Utility.showMessage(context, value.toString());
  }
}

class _OnCheckINCheckOutResponse implements onResponse {
  final BuildContext context;
  final String message;
  final Function(dynamic) onSuccessCallback;

  _OnCheckINCheckOutResponse({
    required this.context,
    required this.onSuccessCallback,
    required this.message,
  });

  @override
  void onStart() {
    Utility.showLoaderDialog(context);
  }

  @override
  void onSuccess(value) {
    Navigator.of(context).pop();
    onSuccessCallback(value);
    Utility.showMessage(context, message);
  }

  @override
  void onError(value) {
    Navigator.of(context).pop(); // Dismiss loader
    Utility.showMessage(context, value.toString());
  }
}

// ── PJP Info Card ─────────────────────────────────────────────────────────────
class _PjpInfoCard extends StatelessWidget {
  final PJPInfo pjp;
  final Color color;
  final VoidCallback? onUpdated;
  final String empCode;
  final String empName;

  const _PjpInfoCard(
      {required this.pjp,
      required this.color,
      this.onUpdated,
      required this.empCode,
      required this.empName});

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

  void approvePjpList(int isApprove, String pjpid, BuildContext context) {
    StringBuffer DocXML = new StringBuffer("<root>");
    DocXML.write(
        "<subroot><PJP_id>${pjpid}</PJP_id><Is_Approved>${isApprove}</Is_Approved></subroot>");
    DocXML.write("</root>");
    UpdatePJPStatusListRequest request = UpdatePJPStatusListRequest(
        DocXML: DocXML.toString(), Workflow_user: empCode);
    IntranetServiceHandler.updatePJPStatusList(
        request,
        _OnManagerApprovedRejectResponse(
          context: context,
          onSuccessCallback: (p0) {
            pjp.ApprovalStatus = isApprove == 1 ? 'Approved' : 'Rejected';
            onUpdated?.call();
            Navigator.of(context).pop(); // Dismiss confirmation dialog
            Utility.showMessage(
                context,
                isApprove == 1
                    ? 'PJP Approved successfully'
                    : 'PJP Rejected successfully');
          },
        ));
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
                if (pjp.isSelfPJP.trim() == '1' &&
                    pjp.ApprovalStatus != 'Rejected') ...[
                  IconButton(
                    icon: const Icon(Icons.add_location_alt_outlined,
                        color: _accent, size: 20),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCVFScreen(mPjpModel: pjp),
                        ),
                      );
                      if (result == true && onUpdated != null) {
                        onUpdated!();
                      }
                    },
                    tooltip: 'Add CVF',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
                // Status badge
                if (pjp.ApprovalStatus == 'Pending' &&
                    empName.trim() == pjp.managerName) ...[
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Utility.onConfirmationBoxNew(
                            context,
                            'REJECT',
                            'Cancel',
                            'Reject PJP',
                            'Are you sure to reject the PJP',
                            Utility.ACTION_REJECT,
                            () {},
                            () => approvePjpList(0, pjp.PJP_Id, context),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 12.0,
                            textStyle:
                                const TextStyle(color: LightColors.kRed)),
                        child: const Text('Reject'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          approvePjpList(1, pjp.PJP_Id, context);
                        },
                        // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
                        style: ElevatedButton.styleFrom(
                            elevation: 12.0,
                            textStyle: const TextStyle(
                                color: LightColors.kLightGreen)),
                        child: const Text('Approve'),
                      ),
                    ],
                  )
                ] else
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
                if ((pjp.managerName?.trim().isNotEmpty ?? false) &&
                    pjp.managerName?.trim() != 'NA') ...[
                  _infoRow(Icons.supervisor_account_rounded, 'Manager',
                      pjp.managerName ?? '', _accent),
                  _dividerLine(),
                ],
                _infoRow(
                    Icons.calendar_today_rounded,
                    'From Date',
                    DateFormat('dd-MM-yyyy')
                        .format(Utility.convertDate(pjp.fromDate)),
                    _accent),
                _dividerLine(),
                _infoRow(
                    Icons.event_rounded,
                    'To Date',
                    DateFormat('dd-MM-yyyy')
                        .format(Utility.convertDate(pjp.toDate)),
                    _accent),
                /* _dividerLine(),
                  _infoRow(
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
                  pjpApprovalStatus: pjp.ApprovalStatus,
                  isViewOnly: pjp.isSelfPJP.trim() != '1',
                  onCVFUpdateSuccess: (p0) {
                    if (onUpdated != null) onUpdated!();
                  },
                  onupdateResponse: _OnCheckINCheckOutResponse(
                      context: context,
                      message: visit.Status == 'NA' ||
                              visit.Status.toLowerCase() == 'check in'
                          ? 'Checked in successfully'
                          : 'CVF filled successfully',
                      onSuccessCallback: (value) {
                        if (onUpdated != null) onUpdated!();
                      }),
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

class _CheckInClickListener implements onClickListener {
  final BuildContext context;
  final Function(GetDetailedPJP) updateCVF;
  _CheckInClickListener(this.context, this.updateCVF);
  @override
  void onClick(int action, value) {
    if (value is GetDetailedPJP) {
      Navigator.of(context).pop();
      GetDetailedPJP cvfView = value;
      if (action == Utility.ACTION_OK) {
        updateCVF(cvfView);
      } else if (action == Utility.ACTION_CCNCEL) {}
    } else {
      debugPrint('click functions not implemented......');
    }
  }
}

// ── Visit Tile (inside PJP card) ──────────────────────────────────────────────
class _VisitTile extends StatelessWidget {
  final GetDetailedPJP visit;
  final bool isViewOnly;
  final onResponse onupdateResponse;
  final Function(GetDetailedPJP) onCVFUpdateSuccess;
  final String pjpApprovalStatus;
  const _VisitTile(
      {required this.visit,
      required this.isViewOnly,
      required this.onupdateResponse,
      required this.onCVFUpdateSuccess,
      required this.pjpApprovalStatus});

  static const Color _textPrimary = Color(0xFF1A1D2E);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _green = Color(0xFF4CAF90);
  static const Color _orange = Color(0xFFFF8A65);
  static const Color _divider = Color(0xFFE8EDF2);
  static const Color _blue = Color(0xFF2196F3);

  Color _statusColor(String s) {
    final lower = s.trim().toLowerCase();
    if (lower.contains('check in')) return _blue;
    if (lower.contains('check out')) return _orange;
    if (lower.contains('completed')) return _green;
    return _textSecondary;
  }

  String getNextStatus(String key) {
    String value = 'Check In';

    switch (key.trim()) {
      case 'Check In':
        value = 'FILL CVF';
        break;
      case 'NA':
        value = 'FILL CVF';
        break;
      case 'FILL CVF':
        value = 'Completed';
        break;
      case 'Completed':
        value = 'Check Out';
        break;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = visit.Status.trim().toLowerCase() == 'completed';
    final bool hasCheckIn =
        visit.DateTimeIn.isNotEmpty && visit.DateTimeIn != 'NA';
    final bool hasCheckOut =
        visit.DateTimeOut.isNotEmpty && visit.DateTimeOut != 'NA';

    return InkWell(
      onTap: () async {
        if (isViewOnly) {
          ToastUtility.showError(msg: 'You cannot access this visit');
          return;
        }
        print(
            'Visit ${visit.PJPCVF_Id} tapped. Current status: ${visit.Status}');

        if (visit.purpose?.isEmpty ?? true) {
          ToastUtility.showError(msg: 'No purpose found for this visit');
          return;
        } else if (pjpApprovalStatus != 'Approved') {
          ToastUtility.showError(
              msg: 'PJP not yet approve, Please connect with your manager');
          return;
        } else if (pjpApprovalStatus == 'Rejected') {
          ToastUtility.showError(msg: 'This PJP is rejected by your manager');
          return;
        }

        var hiveBox = await Utility.openBox();
        int employeeId =
            int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
        if (visit.Status == 'NA' || visit.Status.toLowerCase() == 'check in') {
          Utility.onConfirmationBox(
              context,
              'Check In',
              'Cancel',
              'PJP Status Update?',
              'Would you like to Check In?',
              visit,
              _CheckInClickListener(context, (updatedCVF) {
                IntranetServiceHandler.updateCVFStatus(
                  employeeId,
                  visit,
                  Utility.getDateTime(),
                  getNextStatus(visit.Status),
                  onupdateResponse,
                );
              }));
        } else {
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
                      onUpdateCVFStatus: (p0) => onCVFUpdateSuccess(p0),
                    )),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _divider.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Planned Section

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.event_note_rounded,
                      size: 14, color: _blue),
                ),
                const SizedBox(width: 10),
                if (visit.Status.trim()
                        .isNotEmpty /* &&
                    visit.Status.trim() != 'NA' */
                    )
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(visit.Status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      visit.Status.trim() == 'NA' ? 'Check In' : visit.Status,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(visit.Status),
                      ),
                    ),
                  ),
              ],
            ),
            if (visit.franchiseeName.trim().isNotEmpty &&
                visit.franchiseeName.trim() != 'NA')
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 2),
                child: Text(
                  visit.franchiseeName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (visit.franchiseeCode.isNotEmpty &&
                      visit.franchiseeCode != 'NA')
                    Text(
                      'Code: ${visit.franchiseeCode}',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                  if (visit.ActivityTitle.isNotEmpty &&
                      visit.ActivityTitle != 'NA') ...[
                    Text(
                      visit.ActivityTitle,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: _textSecondary),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (visit.purpose != null && visit.purpose!.isNotEmpty) ...[
                    Text(visit.purpose!.map((p) => p.categoryName).join(', '),
                        style: GoogleFonts.inter(
                            fontSize: 11, color: _textSecondary)),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: _textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Planned: ${visit.visitDate} at ${visit.visitTime}',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: _textSecondary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (!isCompleted &&
                      visit.Address.trim().isNotEmpty &&
                      visit.Address.trim() != 'NA') ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: Color(0xFF26C6DA)),
                        const SizedBox(width: 6),
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

            if (isCompleted || hasCheckIn || hasCheckOut) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: _divider),
              ),
              // Actual Journey Section (Timeline)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _buildStepIndicator(
                          hasCheckIn, isCompleted ? _green : _blue),
                      Container(width: 2, height: 30, color: _divider),
                      _buildStepIndicator(hasCheckOut,
                          hasCheckOut ? _orange : Colors.grey[300]!),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Check-In
                        _buildActualPoint(
                          title: 'Check-In',
                          time: visit.DateTimeIn,
                          address: visit.AddressIn.isNotEmpty &&
                                  visit.AddressIn != 'NA'
                              ? visit.AddressIn
                              : visit.CheckInAddress,
                          color: hasCheckIn ? _blue : _textSecondary,
                        ),
                        const SizedBox(height: 12),
                        // Check-Out
                        _buildActualPoint(
                          title: 'Check-Out',
                          time: visit.DateTimeOut,
                          address: visit.AddressOut.isNotEmpty &&
                                  visit.AddressOut != 'NA'
                              ? visit.AddressOut
                              : visit.CheckOutAddress,
                          color: hasCheckOut ? _orange : _textSecondary,
                        ),
                      ],
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

  Widget _buildStepIndicator(bool active, Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? color : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: active ? color : Colors.grey[300]!, width: 2),
      ),
    );
  }

  Widget _buildActualPoint(
      {required String title,
      required String time,
      required String address,
      required Color color}) {
    final bool hasData = time.isNotEmpty && time != 'NA';
    String formattedTime = '';
    if (hasData) {
      try {
        formattedTime = DateFormat('HH:mm').format(DateTime.parse(time));
      } catch (e) {
        formattedTime = time;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: hasData ? color : _textSecondary),
            ),
            if (hasData) ...[
              const SizedBox(width: 6),
              Text(
                formattedTime,
                style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w500, color: color),
              ),
            ],
          ],
        ),
        if (hasData && address.isNotEmpty && address != 'NA')
          Text(
            address,
            style: GoogleFonts.inter(fontSize: 10, color: _textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        else if (!hasData)
          Text(
            'Waiting...',
            style: GoogleFonts.inter(
                fontSize: 10,
                color: _textSecondary.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic),
          ),
      ],
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
  static const Color _sidebar = kPrimaryLightColor;
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
                        if (visit.franchiseeName.isNotEmpty &&
                            visit.franchiseeName != 'NA')
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
                  visit.Status.isNotEmpty && visit.Status != 'NA'
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(visit.Status)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _statusColor(visit.Status)
                                  .withValues(alpha: 0.4),
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
                        )
                      : SizedBox.shrink(),
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
  final int slotIndex;

  const _Event({
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
    required this.start,
    required this.end,
    this.pjpInfo,
    this.slotIndex = 0,
  });

  factory _Event.empty() {
    return _Event(
      title: '',
      time: '',
      color: Colors.transparent,
      icon: Icons.error,
      start: DateTime(1900),
      end: DateTime(1900),
      slotIndex: -1,
    );
  }

  _Event copyWith({int? slotIndex}) {
    return _Event(
      title: title,
      time: time,
      color: color,
      icon: icon,
      start: start,
      end: end,
      pjpInfo: pjpInfo,
      slotIndex: slotIndex ?? this.slotIndex,
    );
  }

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
