part of 'expenses_cubit.dart';

abstract class ExpensesCubitState extends Equatable {
  const ExpensesCubitState();

  @override
  List<Object> get props => [];
}

class ExpenseCubitInitial extends ExpensesCubitState {}

class LoadingState extends ExpensesCubitState {}

class AllExpensesLoadedState extends ExpensesCubitState {
  final List<Expense> expenses;

  const AllExpensesLoadedState({required this.expenses});

  @override
  List<Object> get props => [expenses];
}

class CategoryUpdatedState extends ExpensesCubitState {}

class SuccessState extends ExpensesCubitState {}

class FailedState extends ExpensesCubitState {
  final String? errorMessage;

  const FailedState({this.errorMessage});
}
