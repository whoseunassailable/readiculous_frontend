import 'library_recommendation.dart';

/// Why [RestockAdvice] suggests what it does.
enum RestockReason {
  /// Readers are waiting and the library can't cover them: order the gap.
  shortfall,

  /// More are waiting than read it in a typical month (e.g. a manga
  /// series): order about a month's worth now, more later if needed.
  gradual,

  /// A new title nobody has asked for yet, but the model expects demand.
  starter,

  /// Enough copies are on the shelf for everyone waiting.
  enoughOnShelf,

  /// Copies coming back soon will cover everyone waiting.
  coveredByReturns,

  /// Not stocked, nobody waiting, and little expected demand.
  noDemand,
}

/// How many copies of a pick to order, from the library's copies and its
/// readers:
///
/// - The gap is readers waiting − copies on the shelf − copies back soon.
///   No gap: nothing to order (the shelf or the returns cover it).
/// - A stocked book read by fewer readers a month than the gap: order a
///   month's worth, so a title few people read isn't over-bought.
/// - A new title nobody is waiting for: one starter copy when the model
///   rates demand HIGH or MEDIUM.
class RestockAdvice {
  final int suggestedOrder;
  final RestockReason reason;

  const RestockAdvice(this.suggestedOrder, this.reason);

  factory RestockAdvice.forPick(LibraryRecommendation pick) {
    final waiting = pick.readersWaiting;
    if (pick.copiesTotal == 0 && waiting == 0) {
      final expectsDemand =
          pick.demandLevel == 'HIGH' || pick.demandLevel == 'MEDIUM';
      return expectsDemand
          ? const RestockAdvice(1, RestockReason.starter)
          : const RestockAdvice(0, RestockReason.noDemand);
    }

    final gap = waiting - pick.copiesAvailable - pick.backSoon;
    if (gap <= 0) {
      return RestockAdvice(
        0,
        waiting <= pick.copiesAvailable
            ? RestockReason.enoughOnShelf
            : RestockReason.coveredByReturns,
      );
    }

    // Monthly readership only means something once the library has copies.
    final monthsWorth = pick.readersPerMonth.ceil().clamp(1, gap);
    if (pick.copiesTotal > 0 && monthsWorth < gap) {
      return RestockAdvice(monthsWorth, RestockReason.gradual);
    }
    return RestockAdvice(gap, RestockReason.shortfall);
  }
}
