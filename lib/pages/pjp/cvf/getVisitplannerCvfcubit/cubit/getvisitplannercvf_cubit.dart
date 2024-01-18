import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../api/APIService.dart';
import '../../model/getvisitplandatewisemodel.dart';

part 'getvisitplannercvf_state.dart';

class GetvisitplannercvfCubit extends Cubit<GetvisitplannercvfState> {
  GetvisitplannercvfCubit() : super(GetvisitplannercvfInitial());

  APIService apiService = APIService();

  void getPlanDetails(String fromDate, String toDate) async {
    emit(const GetvisitplannercvfLoadingState());

    var response = await apiService.getplanVisitDatevise(
        fromDate: fromDate, toDate: toDate);

    if (response.isLeft) {
      emit(GetvisitplannercvfErrorState(error: response.left));
    } else {
      emit(GetvisitplannercvfSuccessSatte(listofPlanData: response.right));
    }
  }
}
