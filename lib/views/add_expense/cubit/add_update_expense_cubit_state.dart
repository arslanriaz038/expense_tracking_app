part of 'add_update_expense_cubit.dart';

abstract class AddUpdateExpenseCubitState extends Equatable {
  const AddUpdateExpenseCubitState();

  @override
  List<Object> get props => [];
}

class AddUpdateExpenseCubitInitial extends AddUpdateExpenseCubitState {}

class LoadingState extends AddUpdateExpenseCubitState {}

class AllExpensesLoadedState extends AddUpdateExpenseCubitState {
  final List<Expense> expenses;

  const AllExpensesLoadedState({required this.expenses});

  @override
  List<Object> get props => [expenses];
}

class CategoryUpdatedState extends AddUpdateExpenseCubitState {}

class SuccessState extends AddUpdateExpenseCubitState {}

class FailedState extends AddUpdateExpenseCubitState {
  final String? errorMessage;

  const FailedState({this.errorMessage});
}
