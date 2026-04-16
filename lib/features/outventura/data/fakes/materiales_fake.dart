import 'package:outventura/features/outventura/domain/entities/material.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

// Materiales de prueba del catálogo, con distintas categorías y estados.
final List<Material> materialesFake = [
  // --- Acampada ---
  const Material(
    id: 1,
    nombre: 'Tienda de campaña 4 estaciones',
    descripcion: 'Para 2 personas, resistente al viento y la lluvia.',
    categorias: [CategoriaActividad.acampada, CategoriaActividad.montania],
    stock: 8,
    estado: EstadoMaterial.disponible,
    precioAlquilerDiario: 12.50,
    tarifaDanios: 150.0,
  ),
  const Material(
    id: 2,
    nombre: 'Saco de dormir -10°C',
    categorias: [CategoriaActividad.acampada, CategoriaActividad.nieve],
    stock: 10,
    estado: EstadoMaterial.disponible,
    precioAlquilerDiario: 10.0,
    tarifaDanios: 120.0,
    imageAsset: 'assets/images/Camino.jpg',
  ),

  // --- Acuática ---
  const Material(
    id: 3,
    nombre: 'Kayak individual',
    descripcion: 'Kayak rígido de poliéster con pala y chaleco salvavidas incluidos.',
    categorias: [CategoriaActividad.acuatica],
    stock: 6,
    estado: EstadoMaterial.disponible,
    precioAlquilerDiario: 25.0,
    tarifaDanios: 300.0,
  ),
  const Material(
    id: 4,
    nombre: 'Tabla de SUP',
    descripcion: 'Tabla de paddle surf hinchable con remo y bomba.',
    categorias: [CategoriaActividad.acuatica],
    stock: 3,
    estado: EstadoMaterial.reservado,
    precioAlquilerDiario: 20.0,
    tarifaDanios: 200.0,
    imageAsset: 'assets/images/Camino.jpg',
  ),

  // --- Senderismo ---
  const Material(
    id: 5,
    nombre: 'Mochila 60L',
    descripcion: 'Mochila de trekking con soporte lumbar y funda impermeable.',
    categorias: [CategoriaActividad.montania, CategoriaActividad.acampada],
    stock: 12,
    estado: EstadoMaterial.disponible,
    precioAlquilerDiario: 7.0,
    tarifaDanios: 80.0,
    imageAsset: 'assets/images/Camino.jpg',
  ),
  const Material(
    id: 6,
    nombre: 'Bastones de trekking',
    descripcion: 'Par de bastones telescópicos de aluminio con puntas de carburo.',
    categorias: [CategoriaActividad.montania, CategoriaActividad.nieve],
    stock: 15,
    estado: EstadoMaterial.disponible,
    precioAlquilerDiario: 3.0,
    tarifaDanios: 25.0,
    imageAsset: 'assets/images/Camino.jpg',
  ),

  // --- Montaña ---
  const Material(
    id: 7,
    nombre: 'Arnés de escalada',
    descripcion: 'Arnés homologado CE para escalada y vías ferratas.',
    categorias: [CategoriaActividad.montania],
    stock: 4,
    estado: EstadoMaterial.mantenimiento,
    precioAlquilerDiario: 5.0,
    tarifaDanios: 90.0,
    imageAsset: 'assets/images/Camino.jpg',
  ),
  const Material(
    id: 8,
    nombre: 'Casco de montaña',
    descripcion: 'Casco polivalente para escalada y vías ferratas, ajuste regulable.',
    categorias: [CategoriaActividad.montania, CategoriaActividad.nieve],
    stock: 8,
    estado: EstadoMaterial.disponible,
    precioAlquilerDiario: 4.0,
    tarifaDanios: 70.0,
    imageAsset: 'assets/images/Camino.jpg',
  ),

  // --- Nieve ---
  const Material(
    id: 9,
    nombre: 'Raquetas de nieve',
    descripcion: 'Par de raquetas de aluminio para actividades en terreno nevado.',
    categorias: [CategoriaActividad.nieve],
    stock: 10,
    estado: EstadoMaterial.disponible,
    precioAlquilerDiario: 8.0,
    tarifaDanios: 60.0,
    imageAsset: 'assets/images/Camino.jpg',
  ),
  const Material(
    id: 10,
    nombre: 'Piolet',
    descripcion: 'Piolet técnico de aluminio para ascensiones en nieve y hielo.',
    categorias: [CategoriaActividad.nieve, CategoriaActividad.montania],
    stock: 5,
    estado: EstadoMaterial.fueraDeServicio,
    precioAlquilerDiario: 6.0,
    tarifaDanios: 100.0,
    imageAsset: 'assets/images/Camino.jpg',
  ),
];
