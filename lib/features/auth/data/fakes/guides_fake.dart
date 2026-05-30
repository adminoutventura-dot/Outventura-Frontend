import 'package:outventura/features/auth/domain/entities/guide.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';

// Guías de prueba vinculados a usuarios admin existentes.
final List<Guide> guidesFake = [
  Guide(
    id: 1,
    userId: 1,
    credentials: 'Llicència federativa núm. 0001',
    categories: const [Category(code: 'MOUNTAIN'), Category(code: 'CAMPING')],
    user: usersFake[0],
  ),
  Guide(
    id: 2,
    userId: 2,
    credentials: 'Llicència federativa núm. 1234',
    categories: const [Category(code: 'AQUATIC')],
    user: usersFake[1],
  ),
];