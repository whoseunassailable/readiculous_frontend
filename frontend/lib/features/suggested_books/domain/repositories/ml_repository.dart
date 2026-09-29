abstract class MlRepository {
  /// Retrains the recommendation models with the latest reading data.
  Future<void> retrain();
}
