import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../api/response/bpms/get_communication_response.dart';
import '../../../helper/constants.dart';
import '../../../helper/utils.dart';
import '../../../utils/theme/colors/light_colors.dart';
import '../../../widget/MyWebSiteView.dart';
import '../../../widget/MyWidget.dart';
import '../data/providers/auth_provider.dart';

class BPMSCommunication extends ConsumerStatefulWidget {
  const BPMSCommunication({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BPMSCommunicationState();
}

class _BPMSCommunicationState extends ConsumerState<BPMSCommunication> {
  final _formKey = GlobalKey<FormState>();

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
          child:
              auth.communicationList == null || auth.communicationList!.isEmpty
                  ? Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(top: 1),
                      child: Column(children: [
                        Utility.emptyDataSet(context,"Data are not available at this moment please check later"),
                      ]),
                    )
                  : Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(top: 1),
                      child: Column(
                        children: [
                          Flexible(
                              child: ListView.builder(
                            itemCount: auth.communicationList!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: Card(
                                  color: Colors.white,
                                  margin: const EdgeInsets.all(10),
                                  child: CommunicationCard(
                                    model: auth.communicationList![index],
                                    context: context,
                                  ),
                                ),
                              );
                            },
                          ))
                        ],
                      ),
                    )),
    );
  }

  getCommunicationView(CommunicationModel model) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Color(0x430F1113),
              offset: Offset(0, 1),
            )
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        MyWidget().richTextBox('', LightColors.textSmallStyle),
                        MyWidget().richTextBox('', LightColors.textSmallStyle),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                    child: Text(
                      'Ref Id : ${model.ID}',
                      style: LightColors.textSmallStyle,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsetsDirectional.all(0),
                child: Text(
                  model.EmailSubject,
                  style: GoogleFonts.roboto(
                    fontSize: 14.0,
                    color: const Color(0xFF4B39EF),
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                ),
              ),
              subtitle: HtmlWidget(
                model.EmailBody.toString(),
                enableCaching: false,
              ),
              trailing: Text(
                Utility.parseShortDate(model.CreatedDate),
                style: GoogleFonts.roboto(
                  fontSize: 14.0,
                  color: const Color(0xFF4B39EF),
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        MyWidget().richTextBox('', LightColors.textSmallStyle),
                        MyWidget().richTextBox('', LightColors.textSmallStyle),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                    child: model.EmailStatus == 'SENT'
                        ? const Icon(
                            Icons.done_all,
                            size: 20,
                          )
                        : const Icon(
                            Icons.done,
                            size: 20,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunicationCard extends StatelessWidget {
  final CommunicationModel model;
  BuildContext context;

  CommunicationCard({Key? key, required this.model, required this.context})
      : super(key: key);

  getMyView() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  print(' tap width ${MediaQuery.of(context).size.width}');
                  //MyWebsiteView(title: '', url: Uri.dataFromString(model.EmailBody, mimeType: 'text/html').toString());
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => MyWebsiteView(
                            title: model.EmailSubject,
                            url: Uri.dataFromString(model.EmailBody,
                                    mimeType: 'text/html')
                                .toString(),
                          )));
                },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date : ${model.CreatedDate}',
                            style: LightColors.smallTextStyle,
                          ),
                          Text(
                            'Created By - ${model.CreatedBy}',
                            style: LightColors.smallTextStyle,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(model.EmailSubject,
                                      style: const TextStyle(
                                          color: kPrimaryLightColor,
                                          fontSize: 14)),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  //WebView(initialUrl: Uri.dataFromString(model.EmailBody, mimeType: 'text/html').toString(),)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return getMyView();
  }
}
