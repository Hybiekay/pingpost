import 'package:fpdart/fpdart.dart';
import 'package:ping_post/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = FutureEither<void>;
