import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';

// Usuarios de prueba: un superadmin, un admin y un cliente.
final List<Usuario> usuariosFake = [
  // Administrador jefe con acceso total al sistema.
  const Usuario(
    id: 1,
    nombre: 'Ana',
    apellidos: 'García López',
    email: 'superadmin@outventura.com',
    telefono: '600 111 222',
    rol: TipoRol.superadmin,
    foto: 'assets/images/Camino.jpg',
    activo: true,
  ),

  // Administrador (trabajador) que gestiona excursiones y material.
  const Usuario(
    id: 2,
    nombre: 'Carlos',
    apellidos: 'Martínez Ruiz',
    email: 'admin@outventura.com',
    telefono: '600 333 444',
    rol: TipoRol.admin,
    foto: 'assets/images/Camino.jpg',
    activo: true,
  ),

  // Cliente registrado que puede solicitar excursiones y alquilar material.
  const Usuario(
    id: 3,
    nombre: 'Laura',
    apellidos: 'Sánchez Torres',
    email: 'cliente@outventura.com',
    telefono: '600 555 666',
    rol: TipoRol.usuario,
    activo: true,
  ),

  // Segundo cliente para probar filtros admin/cliente.
  const Usuario(
    id: 4,
    nombre: 'Diego',
    apellidos: 'Navarro Pérez',
    email: 'cliente2@outventura.com',
    telefono: '600 777 888',
    rol: TipoRol.usuario,
    activo: true,
  ),
];
