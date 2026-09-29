import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/entities/library_recommendation.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/entities/restock_advice.dart';

LibraryRecommendation _pick({
  int total = 0,
  int available = 0,
  int waiting = 0,
  int backSoon = 0,
  double perMonth = 0,
  String? demand = 'HIGH',
}) =>
    LibraryRecommendation(
      recommendationId: 1,
      libraryId: 4,
      bookId: 1,
      title: 'Book',
      demandScore: 0.8,
      demandLevel: demand,
      copiesTotal: total,
      copiesAvailable: available,
      readersWaiting: waiting,
      backSoon: backSoon,
      readersPerMonth: perMonth,
    );

void expectAdvice(LibraryRecommendation pick, int order, RestockReason why) {
  final advice = RestockAdvice.forPick(pick);
  expect((advice.suggestedOrder, advice.reason), (order, why));
}

void main() {
  test(
      'Harry Potter: 0 of 25 on the shelf, 10 waiting, 4 back soon '
      '=> order the other 6', () {
    expectAdvice(
        _pick(total: 25, available: 0, waiting: 10, backSoon: 4, perMonth: 12),
        6,
        RestockReason.shortfall);
  });

  test('5 of 25 on the shelf and 10 waiting => order the remaining 5', () {
    expectAdvice(_pick(total: 25, available: 5, waiting: 10, perMonth: 12), 5,
        RestockReason.shortfall);
  });

  test('need 5 and 5 are coming back soon => order nothing', () {
    expectAdvice(
        _pick(total: 8, available: 0, waiting: 5, backSoon: 5, perMonth: 6),
        0,
        RestockReason.coveredByReturns);
  });

  test('enough on the shelf => order nothing', () {
    expectAdvice(_pick(total: 10, available: 6, waiting: 4, perMonth: 3), 0,
        RestockReason.enoughOnShelf);
  });

  test('Haikyuu: 4 waiting but ~1 reader a month => order 1 for now', () {
    expectAdvice(_pick(total: 2, available: 0, waiting: 4, perMonth: 0.7), 1,
        RestockReason.gradual);
  });

  test('a title the library lacks: order for everyone waiting', () {
    // No copies yet, so no monthly readership to go by.
    expectAdvice(_pick(total: 0, waiting: 10), 10, RestockReason.shortfall);
  });

  test('a new title nobody asked for: 1 starter copy if demand is expected',
      () {
    expectAdvice(_pick(demand: 'HIGH'), 1, RestockReason.starter);
    expectAdvice(_pick(demand: 'MEDIUM'), 1, RestockReason.starter);
    expectAdvice(_pick(demand: 'LOW'), 0, RestockReason.noDemand);
    expectAdvice(_pick(demand: null), 0, RestockReason.noDemand);
  });

  test('readers per month is rounded up: 2.2 a month allows 3', () {
    expectAdvice(_pick(total: 5, available: 0, waiting: 8, perMonth: 2.2), 3,
        RestockReason.gradual);
  });
}
