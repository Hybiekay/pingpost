 
import 'package:fpdart/fpdart.dart';
import 'package:twiiter_clone/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = FutureEither<void>;
