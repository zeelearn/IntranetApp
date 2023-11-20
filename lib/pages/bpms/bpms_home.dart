import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BPMSScreen {
  communication,
  process,
  indent
}
class BpmsHome extends ConsumerWidget{
  const BpmsHome({Key? key}) : super(key: key);
  static const route = '/bpms';

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    //final franchiseeInfo = ref.watch(authNotifierProvider);
    return Text('');
    /*return Consumer(
      builder: (context, ref, child) {
        final authStatus =
        ref.watch(authNotifierProvider.select((value) => value.status));

        return Container(
          child: authStatus == AuthStatus.unauthenticated
              ? const LoginForm()
              : authStatus == AuthStatus.authenticated
              ? const DashboardScreen()
              : const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    )*/;
  }
  
}