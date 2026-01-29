import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/book.dart';

class StockController extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void addBook(Book book) {
    state = {...state, book.id};
  }

  void removeBook(Book book) {
    final copy = {...state};
    copy.remove(book.id);
    state = copy;
  }

  bool contains(Book book) => state.contains(book.id);
}

final stockControllerProvider =
    NotifierProvider<StockController, Set<String>>(StockController.new);
