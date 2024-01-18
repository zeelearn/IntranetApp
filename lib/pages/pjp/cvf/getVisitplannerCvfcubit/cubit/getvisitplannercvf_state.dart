part of 'getvisitplannercvf_cubit.dart';

class GetvisitplannercvfState extends Equatable {
  const GetvisitplannercvfState();

  @override
  List<Object> get props => [];
}

class GetvisitplannercvfInitial extends GetvisitplannercvfState {}

class GetvisitplannercvfLoadingState extends GetvisitplannercvfState {
  const GetvisitplannercvfLoadingState();
}

class GetvisitplannercvfErrorState extends GetvisitplannercvfState {
  final String error;

  const GetvisitplannercvfErrorState({required this.error});
}

class GetvisitplannercvfSuccessSatte extends GetvisitplannercvfState {
  final List<VisitPlanDateWise> listofPlanData;

  const GetvisitplannercvfSuccessSatte({required this.listofPlanData});
}
