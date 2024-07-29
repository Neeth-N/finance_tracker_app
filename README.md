# Finance Tracker App 
**By Abhineeth N**

Welcome to the Finance Tracker App! This app helps you manage your finances by tracking your income and expenses. It includes a real-time pie chart representation of your transactions, categorized by income and expenses.

## Features

- **Firestore Integration**: Seamless integration with Firestore for storing and retrieving transaction data.
- **Real-time Updates**: The pie chart updates in real-time as you add or remove transactions.
- **User-friendly UI**: Clean and intuitive user interface built with Flutter.
- **Categorized Transactions**: Track your transactions categorized into income and expenses.
- **Graphical Representation**: Visual representation of your transactions using a pie chart.
- **Bottom Navigation**: Easy navigation through the app using a BottomNavigationBar.
- **Dark Mode**: Supports dark mode for a comfortable viewing experience in low-light environments.

## Screens

### Home Screen
- Displays a list of all your transactions.
- Add new transactions by clicking the '+' button.
- Each transaction includes a description, amount, and date.

### Graph Screen
- Visualize your income and expenses with a pie chart.
- Income amounts are displayed in green.
- Expense amounts are displayed in red.
- Real-time updates when transactions are added or removed.


## Usage

1. **Opening the App**: Once the app is running on your device or emulator, you will be greeted with the Home Screen.

2. **Adding a Project**:
    - Tap the '+' button located at the bottom of the Home Screen.
    - A form will appear where you can enter the transaction details:
        - **Project Name**: Enter the Name of the Project.
        - **Initial Amount**: Enter the initial amount of the Project.
    
    - *Date*: The date of the Project is automatically set as the date of creation.
    - After filling in the details, tap 'Create' to add the Project.

3. **Dark Mode**:
    - On the Home Screen, Tap on the settings icon on the bottom navigation bar to open Settings Page
    - Toggle Dark Mode to turn on the Dark mode

4. **Adding a Transaction**:
    - Tap the '+' button located at the bottom of the Project Screen.
    - A form will appear where you can enter the transaction details:
        - **Description**: Enter a brief description of the transaction.
        - **Amount**: Enter the amount of the transaction. Use positive values for income and negative values for expenses.
        - **Date**: Select the date of the transaction.
    - After filling in the details, tap 'Save' to add the transaction.

5. **Viewing Transactions**:
    - The Home Screen will display a list of all your transactions, showing the description, amount, and date.
    - Transactions are sorted by date, with the most recent ones at the top.

6. **Viewing the Pie Chart**:
    - Navigate to the Graph Screen by tapping the 'Graph' icon in the BottomNavigationBar.
    - The pie chart displays a visual breakdown of your transactions:
        - Green segments represent income.
        - Red segments represent expenses.
    - The pie chart updates in real-time as transactions are added or removed.

7. **Real-time Updates**:
    - Any changes you make to transactions (adding, editing) will be reflected immediately in the pie chart on the Graph Screen.

8. **Editing a Transaction**:
    - On the Project Screen, slide left on a transaction to show the edit button, click the edit button to edit the transaction
    - Make your changes and tap 'Save' to update the transaction.


## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project.
2. Create your Feature Branch: `git checkout -b feature/AmazingFeature`
3. Commit your Changes: `git commit -m 'Add some AmazingFeature'`
4. Push to the Branch: `git push origin feature/AmazingFeature`
5. Open a Pull Request.

## Contact

Abhineeth N - just.neeth@gmail.com

Project Link: [https://github.com/Neeth-N/finance_tracker_app](https://github.com/Neeth-N/finance_tracker_app)
