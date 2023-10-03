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

class DateUpdatedState extends ExpensesCubitState {
  final DateTime selectedDate;

  const DateUpdatedState(this.selectedDate);

  @override
  List<Object> get props => [selectedDate];
}

class ExpenseUpdatedState extends ExpensesCubitState {
  final Expense expense;

  const ExpenseUpdatedState(this.expense);

  @override
  List<Object> get props => [expense];
}

class ExpenseDeletedState extends ExpensesCubitState {
  final String expenseId;

  const ExpenseDeletedState(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class PickedImagePathState extends ExpensesCubitState {
  final String pickedImagePath;

  const PickedImagePathState(this.pickedImagePath);

  @override
  List<Object> get props => [pickedImagePath];
}

class CategoryUpdatedState extends ExpensesCubitState {}

class SuccessState extends ExpensesCubitState {}

class FailedState extends ExpensesCubitState {
  final String? errorMessage;

  const FailedState({this.errorMessage});
}
