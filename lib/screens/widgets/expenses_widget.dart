import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:autoledger/models/expense_model.dart';
import 'package:autoledger/services/expense_service.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/utils/voice_assistant.dart';
import 'package:autoledger/utils/voice_event_bus.dart';

class ExpensesWidget extends StatefulWidget {
  @override
  _ExpensesWidgetState createState() => _ExpensesWidgetState();
}

class _ExpensesWidgetState extends State<ExpensesWidget> {
  List<Expense> allExpenses = [];
  List<Expense> filteredExpenses = [];
  final _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExpenses();

    VoiceEventBus().on('refresh_expenses', (_) => loadExpenses());
    VoiceEventBus().on('search_expenses', (query) {
      _searchController.text = query;
      applySearch(query);
    });
  }

  Future<void> loadExpenses() async {
    setState(() => isLoading = true);
    final expenses = await ExpenseService.getExpenses();
    setState(() {
      allExpenses = expenses;
      filteredExpenses = expenses;
      isLoading = false;
    });
  }

  void applySearch(String query) {
    final lower = query.toLowerCase();
    setState(() {
      filteredExpenses = allExpenses.where((e) {
        return e.vendor.toLowerCase().contains(lower) ||
            e.category.toLowerCase().contains(lower) ||
            e.notes.toLowerCase().contains(lower) ||
            DateFormat.yMd().format(e.date).contains(lower);
      }).toList();
    });
  }

  void addExpense() {
    VoiceAssistant().simulateCommand("Add expense");
  }

  void editExpense(Expense expense) {
    VoiceAssistant().simulateCommand("Edit expense ${expense.id}");
  }

  void deleteExpense(Expense expense) async {
    await ExpenseService.deleteExpense(expense.id);
    loadExpenses();
  }

  Widget buildExpenseCard(Expense e) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(e.vendor),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${e.amount.toStringAsFixed(2)} • ${e.category}'),
            Text('${DateFormat.yMMMd().format(e.date)}'),
            if (e.notes.isNotEmpty) Text(e.notes),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => editExpense(e),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => deleteExpense(e),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExpenseList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Wrap both empty and non-empty lists in a RefreshIndicator
    return RefreshIndicator(
      onRefresh: loadExpenses,
      child: filteredExpenses.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 200),
                Center(child: Text('No expenses found.')),
              ],
            )
          : ListView.builder(
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) =>
                  buildExpenseCard(filteredExpenses[index]),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("Expenses"),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.mic),
            tooltip: "Voice Command",
            onPressed: () => VoiceAssistant().startListening(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        onPressed: addExpense,
        child: Icon(Icons.add),
        tooltip: "Add Expense",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: applySearch,
              decoration: InputDecoration(
                labelText: 'Search expenses',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: buildExpenseList()),
        ],
      ),
    );
  }
}
