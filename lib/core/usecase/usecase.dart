/// Base contract for every use case in the domain layer.
abstract interface class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Use case that exposes a stream of values instead of a single result.
abstract interface class StreamUseCase<T, Params> {
  Stream<T> call(Params params);
}

/// Used by use cases that take no input.
class NoParams {
  const NoParams();
}
