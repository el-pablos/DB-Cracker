import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure([super.message = 'Terjadi kesalahan pada server', this.statusCode]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Data cache tidak tersedia']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Koneksi timeout']);
}

class RateLimitFailure extends Failure {
  final Duration? retryAfter;
  const RateLimitFailure([super.message = 'Terlalu banyak request', this.retryAfter]);
}

class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Gagal memproses data']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Data tidak ditemukan']);
}
