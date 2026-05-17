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

class CategoriesUpdatedState extends ExpensesCubitState {
  final List<String> categories;

  const CategoriesUpdatedState(this.categories);

  @override
  List<Object> get props => [categories];
}

class CategoryAddedState extends ExpensesCubitState {
  final String category;

  const CategoryAddedState(this.category);

  @override
  List<Object> get props => [category];
}

class CategoryRemovedState extends ExpensesCubitState {
  final String category;

  const CategoryRemovedState(this.category);

  @override
  List<Object> get props => [category];
}

class TypeUpdatedState extends ExpensesCubitState {
  final ExpenseType type;

  const TypeUpdatedState(this.type);

  @override
  List<Object> get props => [type];
}

class BudgetLoadedState extends ExpensesCubitState {
  final MonthlyBudget budget;

  const BudgetLoadedState(this.budget);

  @override
  List<Object> get props => [budget];
}

class BudgetSavedState extends ExpensesCubitState {
  final MonthlyBudget budget;

  const BudgetSavedState(this.budget);

  @override
  List<Object> get props => [budget];
}

class SuccessState extends ExpensesCubitState {}

class ExpenseAddedState extends ExpensesCubitState {
  final String? syncMessage;

  const ExpenseAddedState({this.syncMessage});

  @override
  List<Object> get props => [syncMessage ?? ''];
}

class ExpenseUpdatedState extends ExpensesCubitState {
  final Expense expense;
  final String? syncMessage;

  const ExpenseUpdatedState(this.expense, {this.syncMessage});

  @override
  List<Object> get props => [expense, syncMessage ?? ''];
}

class FailedState extends ExpensesCubitState {
  final String? errorMessage;

  const FailedState({this.errorMessage});
}
