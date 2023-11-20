import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../helper/constants.dart';
import '../../../helper/utils.dart';
import '../data/enums/auth_status.dart';
import '../data/providers/auth_provider.dart';
import 'dashboard_screen.dart';

class BPMSHome extends ConsumerWidget {
  BPMSHome({Key? key}) : super(key: key);
  static const route = '/bpmshome';
  final int PAGE_COMMUNICATION = 0;
  final int PAGE_PROGRESS = 1;
  final int PAGE_INDENT = 2;

  int current_index = 0;
  //final List<Widget> pages = [Home(), SearchPage(), SettingsPage()];

  void OnTapped(int index) {
    //ref.read(authNotifierProvider.notifier).changepage(PAGE_COMMUNICATION);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final currentPage = ref.watch(pageProvider);
    return Consumer(
      builder: (context, ref, child) {
        final authStatus =
            ref.watch(authNotifierProvider.select((value) => value.status));
        final franchiseeModel =
            ref.watch(authNotifierProvider.select((value) => value.user));
        final int currentPage =
            ref.watch(authNotifierProvider.select((value) => value.action));
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: authStatus != AuthStatus.unauthenticated
              ? AppBar(
                  backgroundColor: kPrimaryLightColor,
                  titleSpacing: 10.0,
                  centerTitle: false,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        franchiseeModel != null
                            ? franchiseeModel.FranchiseeName
                            : '--',
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                      Text(
                        franchiseeModel != null
                            ? franchiseeModel.Address1
                            : '--',
                        style: GoogleFonts.inter(
                          fontSize: 10.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    // InkWell(
                    //   onTap: () {
                    //     ref.read(authNotifierProvider.notifier).logout();
                    //   },
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Image.asset(
                    //       'assets/icons/ic_applogout.png',
                    //       width: 25,
                    //     ),
                    //   ),
                    // ),
                  ],
                )
              : null,
          body: Container(
            padding: EdgeInsets.only(bottom: 1),
            child: authStatus == AuthStatus.loading
                ? Center(
                  child: Utility.showLoader(),
                )
                : authStatus == AuthStatus.unauthenticated
                    ? Utility.showLoader()
                    : authStatus == AuthStatus.authenticated
                        ? const BPMSDashboardScreen()
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
          ),
          bottomNavigationBar: authStatus != AuthStatus.unauthenticated
              ? SizedBox(
                  height: 70,
                  child: BottomNavigationBar(
                        elevation: 10,
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Colors.white,
                        iconSize: 20.0,
                        selectedIconTheme: const IconThemeData(size: 28.0),
                        selectedItemColor: kPrimaryLightColor,
                        unselectedItemColor: Colors.black45,
                        selectedFontSize: 14.0,
                        unselectedFontSize: 12,
                        currentIndex: currentPage,
                        onTap: (index) {
                          ref
                              .read(authNotifierProvider.notifier)
                              .changepage(index);
                        },
                        items: const <BottomNavigationBarItem>[
                          BottomNavigationBarItem(
                            icon: Icon(Icons.chat),
                            label: "Communication",
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.workspaces_filled),
                            label: "Task",
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.list_alt),
                            label: "Indent",
                          ),
                        ]),
                )
              : null,
        );
      },
    );
  }
}
