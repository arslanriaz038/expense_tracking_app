import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:expense_tracking_app/views/profile_screen.dart';
import 'package:flutter/material.dart';

class UserProfileAvatar extends StatelessWidget {
  final bool showOnlineIndicator;
  final double imageRadius;
  final List<Expense> expensesList;

  const UserProfileAvatar({
    super.key,
    required this.showOnlineIndicator,
    this.imageRadius = 18,
    required this.expensesList,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppNavigator.push(
            context,
            ProfileScreen(
              expensesList: expensesList,
            ));
      },
      child: Stack(
        children: [
          CircleAvatar(
            radius: imageRadius,
            backgroundImage: NetworkImage(
              MyPref.readUserInfo()?.profilePictureUrl ?? '',
            ),
          ),
          if (showOnlineIndicator)
            const Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 7,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
