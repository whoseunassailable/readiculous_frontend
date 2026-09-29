import '../repositories/ml_repository.dart';

class RetrainModels {
  final MlRepository repo;

  const RetrainModels(this.repo);

  Future<void> call() => repo.retrain();
}
