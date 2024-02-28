import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../task/task_list.dart';
import '../data/providers/auth_provider.dart';
import 'communication.dart';
import 'indent_list.dart';

class BPMSDashboardScreen extends ConsumerWidget {
  const BPMSDashboardScreen({Key? key}) : super(key: key);
  static const route = '/bpmsdashboard';

  final int PAGE_COMMUNICATION = 0;
  final int PAGE_PROGRESS = 1;
  final int PAGE_INDENT = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      body: auth.action == PAGE_PROGRESS
          ? const BPMSTaskScreen()
          : auth.action == PAGE_INDENT
              ? const BPMSIndenScreen()
              : auth.action == PAGE_COMMUNICATION
                  ? const BPMSCommunication()
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(authNotifierProvider.notifier)
                                  .logout(context);
                            },
                            child: Text(auth.action == PAGE_INDENT
                                ? 'Indents'
                                : auth.action == PAGE_PROGRESS
                                    ? 'Progress'
                                    : auth.loading
                                        ? 'Logging Out'
                                        : '${auth.action} Logout'),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
