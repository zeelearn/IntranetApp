import 'package:Intranet/api/APIService.dart';
import 'package:Intranet/pages/outdoor/model/getplandetails.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/createemplyeeplanrequestmodel.dart';

part 'getplandetails_state.dart';

class GetplandetailsCubit extends Cubit<GetplandetailsState> {
  GetplandetailsCubit() : super(GetplandetailsInitialState());
  APIService apiService = APIService();

  void getPlanDetails() async {
    emit(GetplandetailsInitialState());

    var response = await apiService.getEmployeeVisitDetails();

    if (response.isLeft) {
      emit(GetplandetailsErrorState(error: response.left));
    } else {
      emit(GetplandetailsSuccessState(listofplandata: response.right));
    }
  }

  void createEmployeePlan(
      {required String date, required List<XMLRequest> xmlRequest}) async {
    emit(GetplandetailsInitialState());

    var response = await apiService.createEmployeeVisitPlan(
        date: date, xmlRequest: xmlRequest);

    if (response.isLeft) {
      emit(GetplandetailsErrorState(error: response.left));
    } else {
      emit(CreateEmplyeePlanSuccessState(listofGetplanDate: response.right));
    }
  }

  void deleteEmployeePlan({required String id}) async {
    emit(GetplandetailsInitialState());

    var response = await apiService.deleteEmployeeVisitPlan(id: id);

    if (response.isLeft) {
      emit(GetplandetailsErrorState(error: response.left));
    } else {
      emit(DeleteEmplyeePlanSuccessState(
          responseMessage: response.right, id: id));
    }
  }
}
