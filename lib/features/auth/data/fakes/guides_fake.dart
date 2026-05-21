import 'package:outventura/features/auth/domain/entities/guide.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

// Guías de prueba vinculados a usuarios admin existentes.
final List<Guide> guidesFake = [
  Guide(
    id: 1,
    userId: 1,
    specialty: Category.montana,
    credentials: 'Llicència federativa núm. 0001',
    user: usersFake[0],
  ),
  Guide(
    id: 2,
    userId: 2,
    specialty: Category.acuatico,
    credentials: 'Llicència federativa núm. 1234',
    user: usersFake[1],
  ),
];
