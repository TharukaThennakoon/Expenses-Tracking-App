import 'package:flutter/foundation.dart';

import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/save_expense.dart';

/// State for the "New expense" / "Edit expense" form.
///
/// Field errors stay hidden until the first save attempt; after that they
/// update live as the user fixes each field.
class ExpenseFormController extends ChangeNotifier {
  ExpenseFormController({
    required this._saveExpense,
    required this._deleteExpense,
    this.initial,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    final expense = initial;
    _amount = expense?.amount;
    _title = expense?.title ?? '';
    _category = expense?.category;
    _date = expense?.date ?? _clock();
    _note = expense?.note ?? '';
  }

  static const int maxNoteLength = SaveExpense.maxNoteLength;

  final SaveExpense _saveExpense;
  final DeleteExpense _deleteExpense;
  final DateTime Function() _clock;

  /// The expense being edited; null when creating a new one.
  final Expense? initial;

  double? _amount;
  late String _title;
  ExpenseCategory? _category;
  late DateTime _date;
  late String _note;
  bool _showErrors = false;
  bool _isBusy = false;
  String? _actionError;

  bool get isEditing => initial != null;
  double? get amount => _amount;
  String get title => _title;
  ExpenseCategory? get category => _category;
  DateTime get date => _date;
  String get note => _note;
  bool get isBusy => _isBusy;
  String? get actionError => _actionError;
  DateTime get now => _clock();

  String? get amountError => _showErrors && (_amount ?? 0) <= 0
      ? 'Enter an amount greater than 0'
      : null;

  String? get titleError =>
      _showErrors && _title.trim().isEmpty ? 'Title is required' : null;

  String? get categoryError =>
      _showErrors && _category == null ? 'Pick a category' : null;

  int get errorCount =>
      [amountError, titleError, categoryError].where((e) => e != null).length;

  /// Whether anything differs from what the form started with.
  bool get isDirty {
    final start = initial;
    if (start == null) {
      return _amount != null ||
          _title.trim().isNotEmpty ||
          _category != null ||
          _note.trim().isNotEmpty;
    }
    return _amount != start.amount ||
        _title.trim() != start.title ||
        _category != start.category ||
        !_sameDay(_date, start.date) ||
        _note.trim() != (start.note ?? '');
  }

  void setAmount(double? amount) {
    _amount = amount;
    notifyListeners();
  }

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void setCategory(ExpenseCategory category) {
    _category = category;
    notifyListeners();
  }

  /// Keeps the original time of day; only the calendar day changes.
  void setDay(DateTime day) {
    _date = DateTime(
      day.year,
      day.month,
      day.day,
      _date.hour,
      _date.minute,
      _date.second,
    );
    notifyListeners();
  }

  void setNote(String note) {
    _note = note;
    notifyListeners();
  }

  /// Validates and saves. Returns the saved expense, or null if the form is
  /// invalid or saving failed.
  Future<Expense?> save() async {
    if (_isBusy) return null;
    _showErrors = true;
    _actionError = null;
    if (errorCount > 0) {
      notifyListeners();
      return null;
    }

    _isBusy = true;
    notifyListeners();
    try {
      final draft = Expense(
        id: '',
        title: _title,
        amount: _amount!,
        category: _category!,
        date: _date,
        note: _note,
      );
      return await _saveExpense(
        initial == null
            ? draft
            : initial!.copyWith(
                title: draft.title,
                amount: draft.amount,
                category: draft.category,
                date: draft.date,
                note: draft.note,
              ),
      );
    } catch (_) {
      _actionError = 'Could not save. Please try again.';
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Deletes the expense being edited. Returns true on success.
  Future<bool> delete() async {
    final expense = initial;
    if (expense == null || _isBusy) return false;
    _isBusy = true;
    _actionError = null;
    notifyListeners();
    try {
      await _deleteExpense(expense.id);
      return true;
    } catch (_) {
      _actionError = 'Could not delete. Please try again.';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
