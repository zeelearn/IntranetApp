import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api/response/bpms/franchisee_details_response.dart';
import '../../../helper/utils.dart';
import '../../../utils/theme/colors/light_colors.dart';
import '../data/providers/auth_provider.dart';

class BPMSIndenScreen extends ConsumerStatefulWidget {
  const BPMSIndenScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BPMSIndenScreenState();
}

class _BPMSIndenScreenState extends ConsumerState<BPMSIndenScreen> {
  final _formKey = GlobalKey<FormState>();
  //FranchiseeIndentModel

/*

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      context.showSnackBar(context, message: 'Could not launch URL: $url');
    }
  }
*/

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();
    return SafeArea(
      child: RefreshIndicator(
          key: refreshIndicatorKey,
          color: Colors.white,
          backgroundColor: Colors.blue,
          strokeWidth: 4.0,
          onRefresh: () async {
            // Replace this delay with the code to be executed during refresh
            ref.read(authNotifierProvider.notifier).refreshCommunication();
            return Future<void>.delayed(const Duration(seconds: 3));
          },
          // Pull from top to show refresh indicator.
          child: auth.indentList == null || auth.indentList!.isEmpty
              ? Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 1),
                  child: Column(children: [
                    Utility.emptyDataSet(context,
                        "Data are not available at this moment please check later"),
                  ]),
                )
              : Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 1),
                  child: Container(
                      child: ListView.builder(
                    itemCount: auth.indentList!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return getIndentView(auth.indentList![index]);
                    },
                  )))),
    );
  }

  getIndentView(FranchiseeIndentModel model) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Card(
        color: Colors.white,
        child: ListTile(
          title: Padding(
            padding: const EdgeInsetsDirectional.all(0),
            child: Text(model.IndentNo, style: LightColors.textHeaderStyle13),
          ),
          subtitle: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Text(
                Utility.parseShortDate(model.IndentDate),
                style: LightColors.textvSmallStyle,
              )),
          trailing: Text(
            'Rs ${model.IndentAmount.toString()}',
            style: LightColors.textHeaderStyle,
          ),
        ),
      ),
    );
  }
}
