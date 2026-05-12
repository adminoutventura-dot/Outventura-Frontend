import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';

// Usuarios de prueba: un superadmin, un admin y un cliente.
final List<Usuario> usuariosFake = [
  // Administrador jefe con acceso total al sistema.
  const Usuario(
    id: 1,
    name: 'Ana',
    surname: 'García López',
    email: 'superadmin@outventura.com',
    phone: '600 111 222',
    role: TipoRol.superadmin,
    photo: 'assets/images/Camino.jpg',
    active: true,
  ),

  // Administrador (trabajador) que gestiona excursiones y material.
  const Usuario(
    id: 2,
    name: 'Carlos',
    surname: 'Martínez Ruiz',
    email: 'admin@outventura.com',
    phone: '600 333 444',
    role: TipoRol.admin,
    photo: 'assets/images/Camino.jpg',
    active: true,
  ),

  // Cliente registrado que puede solicitar excursiones y alquilar material.
  const Usuario(
    id: 3,
    name: 'Laura',
    surname: 'Sánchez Torres',
    email: 'cliente@outventura.com',
    phone: '600 555 666',
    role: TipoRol.usuario,
    active: true,
  ),

  // Segundo cliente para probar filtros admin/cliente.
  const Usuario(
    id: 4,
    name: 'Diego',
    surname: 'Navarro Pérez',
    email: 'cliente2@outventura.com',
    phone: '600 777 888',
    role: TipoRol.usuario,
    active: false,
  ),
];
