part of 'getplandetails_cubit.dart';

class GetplandetailsState extends Equatable {
  const GetplandetailsState();

  @override
  List<Object> get props => [];
}

class GetplandetailsInitialState extends GetplandetailsState {}

class GetplandetailsLoadingState extends GetplandetailsState {}

class GetplandetailsErrorState extends GetplandetailsState {
  final String error;

  const GetplandetailsErrorState({required this.error});
}

class GetplandetailsSuccessState extends GetplandetailsState {
  final List<GetPlanData> listofplandata;

  const GetplandetailsSuccessState({required this.listofplandata});
}

class GetFranchiseeLastVisitplandetailsSuccessState
    extends GetplandetailsState {
  final List<getFranchiseeLastVisitModelPlaceholder.ResponseData>
      listofFranchiseeplandata;

  const GetFranchiseeLastVisitplandetailsSuccessState(
      {required this.listofFranchiseeplandata});
}

class CreateEmplyeePlanSuccessState extends GetplandetailsState {
  final List<GetPlanData> listofGetplanDate;

  const CreateEmplyeePlanSuccessState({required this.listofGetplanDate});
}

class DeleteEmplyeePlanSuccessState extends GetplandetailsState {
  final String responseMessage, id;

  const DeleteEmplyeePlanSuccessState(
      {required this.responseMessage, required this.id});
}
