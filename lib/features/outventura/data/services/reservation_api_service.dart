import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';

final reservationApiProvider = Provider<ReservationApiService>((ref) {
  return ReservationApiService(ref.watch(dioProvider));
});

class ReservationApiService {
  final Dio _dio;

  ReservationApiService(this._dio);

  // GET /reservations?search=&userId=
  Future<List<Reserva>> getAll({String? search, int? userId}) async {
    final resp = await _dio.get('/reservations', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (userId != null) 'userId': userId,
    });
    return (resp.data as List<dynamic>)
        .map((e) => Reserva.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // GET /reservations/:id
  Future<Reserva> getOne(int id) async {
    final resp = await _dio.get('/reservations/$id');
    return Reserva.fromMap(resp.data as Map<String, dynamic>);
  }

  // POST /reservations
  Future<Reserva> create(Map<String, dynamic> data) async {
    final resp = await _dio.post('/reservations', data: data);
    return Reserva.fromMap(resp.data as Map<String, dynamic>);
  }

  // PUT /reservations/:id
  Future<Reserva> update(int id, Map<String, dynamic> data) async {
    final resp = await _dio.put('/reservations/$id', data: data);
    return Reserva.fromMap(resp.data as Map<String, dynamic>);
  }

  // DELETE /reservations/:id
  Future<void> delete(int id) async {
    await _dio.delete('/reservations/$id');
  }

  // PATCH /reservations/:id/approve
  Future<Reserva> approve(int id) async {
    final resp = await _dio.patch('/reservations/$id/approve');
    return Reserva.fromMap(resp.data as Map<String, dynamic>);
  }

  // PATCH /reservations/:id/reject
  Future<Reserva> reject(int id) async {
    final resp = await _dio.patch('/reservations/$id/reject');
    return Reserva.fromMap(resp.data as Map<String, dynamic>);
  }

  // PATCH /reservations/:id/cancel
  Future<Reserva> cancel(int id) async {
    final resp = await _dio.patch('/reservations/$id/cancel');
    return Reserva.fromMap(resp.data as Map<String, dynamic>);
  }

  // PATCH /reservations/:id/return
  Future<Reserva> returnReservation(int id, {Map<String, dynamic>? damages}) async {
    final resp = await _dio.patch('/reservations/$id/return', data: damages);
    return Reserva.fromMap(resp.data as Map<String, dynamic>);
  }
}
