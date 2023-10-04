# expense_tracking_app

Certainly! Here's a README file summarizing the key components and features of your app's code:

---

# Expense Tracking App

**Table of Contents**

1. [Introduction](#introduction)
2. [Features](#features)
3. [Screens and Widgets](#screens-and-widgets)
4. [Firebase Integration](#firebase-integration)
5. [Firestore Rules](#firestore-rules)
6. [Getting Started](#getting-started)
7. [Contributing](#contributing)
8. [License](#license)

## Introduction

The Expense Tracking App is a mobile application developed to help users manage their expenses efficiently. The app allows users to log and categorize their expenses, view expense statistics, and keep track of their financial transactions. It is built using Flutter for the frontend and integrates with Firebase for user authentication and cloud-based data storage.

## Features

- **User Authentication**: Users can sign up and log in to the app using their email and password.

- **Expense Management**: Users can add, edit, and delete expenses. Each expense includes details such as description, amount, date, category, and an optional receipt image.

- **Expense Categorization**: Expenses can be categorized into different categories like Grocery, Transportation, Entertainment, and Other.

- **Expense Statistics**: The app provides visual statistics in the form of a pie chart to show the distribution of expenses across categories.

- **Profile Screen**: Users can view their profile information, including their name, email, and profile picture. They can also log out from the app.

## Screens and Widgets

The app consists of several screens and widgets, including:

- **Login Screen**: Allows users to log in or sign up.

- **Expenses Screen**: Displays a list of all expenses, categorized and sortable by date. Users can add new expenses or click on an expense to edit or delete it.

- **Add/Edit Expense Screen**: Provides a form to add or edit expense details, including description, amount, date, category, and an optional receipt image.

- **Profile Screen**: Shows user profile information and a pie chart summarizing expenses.

- **Pie Chart Widget**: A reusable widget to display expense category distribution in a pie chart format.

- **Expense Item Card Widget**: A widget to display individual expense items with a card-like UI.

## Firebase Integration

Firebase is used for the following purposes:

- **User Authentication**: Firebase Authentication is used for user registration and login.

- **Firestore Database**: Firestore is used to store and retrieve user expense data. It includes collections for users and their expenses.

- **Firebase Storage**: Firebase Storage is used to store receipt images associated with expenses.

## Firestore Rules

Firestore security rules are implemented to ensure data access control. Rules are set up to allow users to read and write their own expense data while preventing unauthorized access.

## Getting Started

To run the app locally, follow these steps:

1. Clone this repository to your local machine.

2. Make sure you have Flutter and Dart installed. If not, [install Flutter](https://flutter.dev/docs/get-started/install).

3. Set up a Firebase project and configure it with your Firebase credentials. Update the configuration files in the app accordingly.

4. Run `flutter pub get` to fetch the app's dependencies.

5. Connect a physical device or emulator.

6. Run the app using `flutter run`.

7. You should now be able to access the app on your device or emulator.

## Contributing

Contributions are welcome! If you'd like to contribute to the project, please follow the standard GitHub at https://github.com/arslanriaz038/expense_tracking_app fork and pull request workflow.

## License

This project has no License. I made it for a Task.

---

Feel free to customize this README to include additional details about your app or any specific instructions for setup and deployment.