# Outventura — API Endpoints

> Documento de referencia para el desarrollo del backend.
> Incluye todos los endpoints necesarios por el frontend actual y los previstos a futuro.

---

## Base URL

```
https://api.outventura.com
```

## Autenticación

Todos los endpoints (salvo los de auth públicos) requieren cabecera:

```
Authorization: Bearer <access_token>
```

---

## Roles del sistema

| Rol | Nivel | Descripción |
|---|---|---|
| `SUPERADMIN` | 0 | Acceso total, gestiona admins |
| `ADMIN` | 1 | Gestiona excursiones, equipamiento, reservas, solicitudes y usuarios |
| `EXPERTO` | 2 | Guía asignado a solicitudes, puede gestionarlas |
| `USUARIO` | 3 | Cliente: solicita excursiones y alquila material |
| `INVITADO` | 4 | Solo lectura del catálogo público |

---

## 1. Auth — `/auth`

### Modelo: Token Response

```json
{
  "accessToken": "string (JWT)",
  "refreshToken": "string",
  "user": { /* Usuario completo */ }
}
```

### Endpoints

| Método | Ruta | Descripción | Auth | Roles |
|---|---|---|---|---|
| `POST` | `/auth/login` | Iniciar sesión | No | Público |
| `POST` | `/auth/refresh` | Renovar access token | No | Público |
| `POST` | `/auth/logout` | Cerrar sesión (invalidar token) | Sí | Todos |
| `POST` | `/auth/register` | Registro de nuevo usuario | No | Público |
| `POST` | `/auth/forgot-password` | Solicitar restablecimiento de contraseña | No | Público |
| `POST` | `/auth/reset-password` | Restablecer contraseña con token | No | Público |
| `GET` | `/auth/me` | Obtener perfil del usuario autenticado | Sí | Todos |

#### `POST /auth/login`

```json
// Request
{
  "email": "admin@outventura.com",
  "password": "string"
}

// Response 200
{
  "accessToken": "eyJhbG...",
  "refreshToken": "dGhpcyBp...",
  "user": {
    "id": 1,
    "nombre": "Ana",
    "apellidos": "García López",
    "email": "admin@outventura.com",
    "telefono": "600 111 222",
    "rol": "superadmin",
    "foto": "https://storage.outventura.com/users/1.jpg",
    "estado": true
  }
}
```

#### `POST /auth/refresh`

```json
// Request
{ "refreshToken": "dGhpcyBp..." }

// Response 200
{ "accessToken": "eyJhbG...", "refreshToken": "bmV3IHJl..." }
```

#### `POST /auth/register` *(futuro)*

```json
// Request
{
  "nombre": "string",
  "apellidos": "string",
  "email": "string",
  "password": "string",
  "telefono": "string (opcional)"
}

// Response 201 → Token Response
```

#### `POST /auth/forgot-password` *(futuro)*

```json
// Request
{ "email": "cliente@outventura.com" }

// Response 200
{ "message": "Email de restablecimiento enviado" }
```

#### `POST /auth/reset-password` *(futuro)*

```json
// Request
{ "token": "string", "newPassword": "string" }

// Response 200
{ "message": "Contraseña actualizada correctamente" }
```

---

## 2. Usuarios — `/users`

### Modelo: Usuario

```json
{
  "id": 1,
  "nombre": "Ana",
  "apellidos": "García López",
  "email": "superadmin@outventura.com",
  "telefono": "600 111 222",
  "rol": "superadmin",
  "foto": "https://storage.outventura.com/users/1.jpg",
  "estado": true
}
```

**Valores de `rol`:** `superadmin`, `admin`, `experto`, `usuario`, `invitado`

### Endpoints

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| `GET` | `/users` | Listar usuarios (paginado, filtrable) | ADMIN, SUPERADMIN |
| `GET` | `/users/{id}` | Obtener usuario por ID | ADMIN, SUPERADMIN |
| `POST` | `/users` | Crear usuario | ADMIN, SUPERADMIN |
| `PUT` | `/users/{id}` | Actualizar usuario completo | ADMIN, SUPERADMIN |
| `DELETE` | `/users/{id}` | Eliminar usuario | SUPERADMIN |
| `PATCH` | `/users/{id}/status` | Activar / desactivar usuario | ADMIN, SUPERADMIN |
| `PUT` | `/users/me` | Editar perfil propio | Todos (autenticado) |
| `PUT` | `/users/me/password` | Cambiar contraseña propia | Todos (autenticado) |
| `POST` | `/users/{id}/avatar` | Subir foto de perfil | ADMIN, SUPERADMIN, propietario |

#### `GET /users`

```
GET /users?page=0&size=20&sort=nombre,asc&rol=usuario&activo=true&search=laura
```

```json
// Response 200
{
  "content": [ /* array de Usuario */ ],
  "totalElements": 42,
  "totalPages": 3,
  "page": 0,
  "size": 20
}
```

#### `POST /users`

```json
// Request
{
  "nombre": "Laura",
  "apellidos": "Sánchez Torres",
  "email": "cliente@outventura.com",
  "password": "string",
  "telefono": "600 555 666",
  "rol": "usuario"
}

// Response 201 → Usuario creado
```

#### `PUT /users/{id}`

```json
// Request
{
  "nombre": "Laura",
  "apellidos": "Sánchez Torres",
  "email": "cliente@outventura.com",
  "telefono": "600 555 666",
  "rol": "usuario"
}

// Response 200 → Usuario actualizado
```

#### `PATCH /users/{id}/status`

```json
// Request
{ "estado": false }

// Response 200 → Usuario actualizado
```

#### `PUT /users/me`

```json
// Request
{
  "nombre": "Laura",
  "apellidos": "Sánchez Torres",
  "email": "nuevo@email.com",
  "telefono": "600 999 000"
}

// Response 200 → Usuario actualizado
```

#### `PUT /users/me/password`

```json
// Request
{
  "currentPassword": "string",
  "newPassword": "string"
}

// Response 200
{ "message": "Contraseña actualizada" }
```

#### `POST /users/{id}/avatar`

```
Content-Type: multipart/form-data
Body: file (imagen)

Response 200
{ "foto": "https://storage.outventura.com/users/1.jpg" }
```

---

## 3. Excursiones — `/excursions`

### Modelo: Excursión

```json
{
  "id": 1,
  "startPoint": "Puerto de Sóller",
  "endPoint": "Torre Picada",
  "imageAsset": "https://storage.outventura.com/excursions/1.jpg",
  "startDate": "2026-05-01T09:00:00",
  "endDate": "2026-05-01T12:00:00",
  "categories": ["Acuático", "Montaña"],
  "participantCount": 20,
  "description": "Ruta sencilla con vistas al mar...",
  "status": "Disponible",
  "price": 35.0,
  "materialsPerParticipant": {
    "5": 1,
    "6": 2
  }
}
```

**Valores de `status`:** `Disponible`, `Pendiente`, `Confirmada`, `EnCurso`, `Finalizada`, `Cancelada`

**Valores de `categories`:** `Acuático`, `Nieve`, `Montaña`, `Camping`

### Endpoints

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| `GET` | `/excursions` | Listar excursiones (paginado, filtrable) | Todos |
| `GET` | `/excursions/{id}` | Obtener excursión por ID | Todos |
| `POST` | `/excursions` | Crear excursión | ADMIN, SUPERADMIN |
| `PUT` | `/excursions/{id}` | Actualizar excursión | ADMIN, SUPERADMIN |
| `DELETE` | `/excursions/{id}` | Eliminar excursión | ADMIN, SUPERADMIN |
| `PATCH` | `/excursions/{id}/status` | Cambiar estado | ADMIN, SUPERADMIN |
| `POST` | `/excursions/{id}/image` | Subir imagen de excursión | ADMIN, SUPERADMIN |

#### `GET /excursions`

```
GET /excursions?page=0&size=20&sort=startDate,desc&category=Montaña&status=Disponible&search=Sóller&dateFrom=2026-01-01&dateTo=2026-12-31
```

```json
// Response 200
{
  "content": [ /* array de Excursión */ ],
  "totalElements": 15,
  "totalPages": 1,
  "page": 0,
  "size": 20
}
```

#### `POST /excursions`

```json
// Request
{
  "startPoint": "Puerto de Sóller",
  "endPoint": "Torre Picada",
  "startDate": "2026-05-01T09:00:00",
  "endDate": "2026-05-01T12:00:00",
  "categories": ["Acuático", "Montaña"],
  "participantCount": 20,
  "description": "Ruta sencilla...",
  "status": "Disponible",
  "price": 35.0,
  "materialsPerParticipant": { "5": 1, "6": 2 }
}

// Response 201 → Excursión creada
```

#### `PUT /excursions/{id}`

```json
// Request (mismo formato que POST, todos los campos)
```

#### `PATCH /excursions/{id}/status`

```json
// Request
{ "status": "Cancelada" }

// Response 200 → Excursión actualizada
```

---

## 4. Equipamiento — `/equipment`

### Modelo: Equipamiento

```json
{
  "id": 1,
  "name": "Tienda de campaña 4 estaciones",
  "description": "Para 2 personas, resistente al viento y la lluvia.",
  "categories": ["Camping", "Montaña"],
  "stock": 8,
  "stockTotal": 10,
  "status": "Disponible",
  "dailyRentalPrice": 12.50,
  "damageFee": 150.0,
  "imageAsset": "https://storage.outventura.com/equipment/1.jpg"
}
```

**Valores de `status`:** `Disponible`, `Agotado`, `EnMantenimiento`, `FueraDeServicio`

**Valores de `categories`:** `Acuático`, `Nieve`, `Montaña`, `Camping`

### Endpoints

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| `GET` | `/equipment` | Listar equipamiento (paginado, filtrable) | Todos |
| `GET` | `/equipment/{id}` | Obtener equipamiento por ID | Todos |
| `POST` | `/equipment` | Crear equipamiento | ADMIN, SUPERADMIN |
| `PUT` | `/equipment/{id}` | Actualizar equipamiento | ADMIN, SUPERADMIN |
| `DELETE` | `/equipment/{id}` | Eliminar equipamiento | ADMIN, SUPERADMIN |
| `PATCH` | `/equipment/{id}/status` | Cambiar estado | ADMIN, SUPERADMIN |
| `PATCH` | `/equipment/{id}/stock` | Ajustar stock manualmente | ADMIN, SUPERADMIN |
| `GET` | `/equipment/{id}/availability` | Consultar disponibilidad en rango de fechas | Todos |
| `POST` | `/equipment/{id}/image` | Subir imagen de equipamiento | ADMIN, SUPERADMIN |

#### `GET /equipment`

```
GET /equipment?page=0&size=20&sort=name,asc&category=Acuático&status=Disponible&search=kayak&minPrice=0&maxPrice=50
```

```json
// Response 200
{
  "content": [ /* array de Equipamiento */ ],
  "totalElements": 10,
  "totalPages": 1,
  "page": 0,
  "size": 20
}
```

#### `POST /equipment`

```json
// Request
{
  "name": "Kayak individual",
  "description": "Kayak rígido...",
  "categories": ["Acuático"],
  "stock": 6,
  "stockTotal": 6,
  "status": "Disponible",
  "dailyRentalPrice": 25.0,
  "damageFee": 300.0
}

// Response 201 → Equipamiento creado
```

#### `PATCH /equipment/{id}/stock`

```json
// Request
{ "stock": 12 }

// Response 200 → Equipamiento actualizado
```

#### `GET /equipment/{id}/availability` *(futuro)*

```
GET /equipment/3/availability?from=2026-06-10&to=2026-06-15
```

```json
// Response 200
{
  "equipmentId": 3,
  "totalStock": 6,
  "reserved": 4,
  "available": 2,
  "from": "2026-06-10",
  "to": "2026-06-15"
}
```

---

## 5. Solicitudes — `/requests`

### Modelo: Solicitud

```json
{
  "id": 1,
  "excursionId": 1,
  "participantCount": 6,
  "status": "Confirmada",
  "expertId": 1,
  "userId": 3,
  "reservationId": 101,
  "requestedMaterials": {
    "5": 6,
    "6": 10
  },
  "totalPrice": 450.0
}
```

**Valores de `status`:** `Pendiente`, `Confirmada`, `Finalizada`, `Cancelada`

### Endpoints

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| `GET` | `/requests` | Listar solicitudes (paginado, filtrable) | ADMIN: todas; USUARIO: las propias |
| `GET` | `/requests/{id}` | Obtener solicitud por ID | ADMIN, EXPERTO, propietario |
| `POST` | `/requests` | Crear solicitud | USUARIO, ADMIN |
| `PUT` | `/requests/{id}` | Editar solicitud | ADMIN, EXPERTO |
| `DELETE` | `/requests/{id}` | Eliminar solicitud | ADMIN, SUPERADMIN |
| `PATCH` | `/requests/{id}/accept` | Aceptar solicitud → Confirmada | ADMIN, EXPERTO |
| `PATCH` | `/requests/{id}/reject` | Rechazar solicitud → Cancelada | ADMIN, EXPERTO |
| `PATCH` | `/requests/{id}/start` | Iniciar solicitud → EnCurso | ADMIN, EXPERTO |
| `PATCH` | `/requests/{id}/finalize` | Finalizar solicitud → Finalizada | ADMIN, EXPERTO |
| `PATCH` | `/requests/{id}/cancel` | Cancelar solicitud → Cancelada | ADMIN, propietario |
| `PATCH` | `/requests/{id}/assign-expert` | Asignar experto a la solicitud | ADMIN |
| `GET` | `/requests/my` | Solicitudes del usuario autenticado | USUARIO |

#### `GET /requests`

```
GET /requests?page=0&size=20&sort=id,desc&status=Pendiente&userId=3&expertId=1&search=Sóller
```

```json
// Response 200
{
  "content": [ /* array de Solicitud */ ],
  "totalElements": 5,
  "totalPages": 1,
  "page": 0,
  "size": 20
}
```

#### `POST /requests`

```json
// Request
{
  "startPoint": "Puerto de Sóller",
  "endPoint": "Torre Picada",
  "startDate": "2026-06-01T09:00:00",
  "endDate": "2026-06-01T17:00:00",
  "categories": ["Montaña", "Acuático"],
  "participantCount": 6,
  "description": "Ruta costera con kayak incluido",
  "expertId": null
}

// Response 201 → Solicitud creada (status = Pendiente)
```

#### `PUT /requests/{id}`

```json
// Request
{
  "startPoint": "Puerto de Sóller",
  "endPoint": "Torre Picada",
  "startDate": "2026-06-01T09:00:00",
  "endDate": "2026-06-01T17:00:00",
  "categories": ["Montaña"],
  "participantCount": 8,
  "expertId": 2
}

// Response 200 → Solicitud actualizada
```

#### `PATCH /requests/{id}/accept`

```json
// Response 200
// El backend cambia status → Confirmada
// Puede asignar experto si se incluye en el body
{ "expertId": 2 }  // opcional
```

#### `PATCH /requests/{id}/assign-expert`

```json
// Request
{ "expertId": 2 }

// Response 200 → Solicitud actualizada
```

---

## 6. Reservas — `/reservations`

### Modelo: Reserva

```json
{
  "id": 101,
  "userId": 3,
  "excursionId": 1,
  "startDate": "2026-05-01T09:00:00",
  "endDate": "2026-05-01T12:00:00",
  "status": "Pendiente",
  "lines": [
    { "equipmentId": 5, "quantity": 6 },
    { "equipmentId": 6, "quantity": 10 }
  ],
  "damageFee": 0,
  "damagedItems": {}
}
```

**Valores de `status`:** `Pendiente`, `Confirmada`, `Devuelta`, `Cancelada`

### Endpoints

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| `GET` | `/reservations` | Listar reservas (paginado, filtrable) | ADMIN: todas; USUARIO: las propias |
| `GET` | `/reservations/{id}` | Obtener reserva por ID | ADMIN, propietario |
| `POST` | `/reservations` | Crear reserva | ADMIN, USUARIO |
| `PUT` | `/reservations/{id}` | Editar reserva (líneas, fechas, usuario) | ADMIN |
| `DELETE` | `/reservations/{id}` | Eliminar reserva | ADMIN, SUPERADMIN |
| `PATCH` | `/reservations/{id}/approve` | Aprobar → Confirmada | ADMIN |
| `PATCH` | `/reservations/{id}/reject` | Rechazar → Cancelada | ADMIN |
| `PATCH` | `/reservations/{id}/cancel` | Cancelar reserva | ADMIN, propietario |
| `PATCH` | `/reservations/{id}/return` | Registrar devolución → Devuelta | ADMIN |
| `PATCH` | `/reservations/{id}/damages` | Registrar daños + calcular cargo | ADMIN |
| `GET` | `/reservations/my` | Reservas del usuario autenticado | USUARIO |

#### `GET /reservations`

```
GET /reservations?page=0&size=20&sort=startDate,desc&status=Pendiente&userId=3&excursionId=1&dateFrom=2026-01-01&dateTo=2026-12-31
```

```json
// Response 200
{
  "content": [ /* array de Reserva */ ],
  "totalElements": 5,
  "totalPages": 1,
  "page": 0,
  "size": 20
}
```

#### `POST /reservations`

```json
// Request
{
  "userId": 3,
  "excursionId": 1,
  "startDate": "2026-05-01T09:00:00",
  "endDate": "2026-05-01T12:00:00",
  "lines": [
    { "equipmentId": 5, "quantity": 6 },
    { "equipmentId": 6, "quantity": 10 }
  ]
}

// Response 201 → Reserva creada (status = Pendiente)
// Backend valida disponibilidad de stock
```

#### `PUT /reservations/{id}`

```json
// Request (mismo formato que POST, todos los campos editables)
{
  "userId": 3,
  "excursionId": 1,
  "startDate": "2026-05-01T09:00:00",
  "endDate": "2026-05-01T12:00:00",
  "lines": [
    { "equipmentId": 5, "quantity": 8 },
    { "equipmentId": 6, "quantity": 12 }
  ]
}

// Response 200 → Reserva actualizada
```

#### `PATCH /reservations/{id}/return`

```json
// Request (opcionalmente con daños)
{
  "damagedItems": { "5": 2 },
  "damageFee": 160.0
}

// Response 200 → Reserva con status = Devuelta
// Backend ajusta stock del equipamiento dañado
```

#### `PATCH /reservations/{id}/damages`

```json
// Request
{
  "damagedItems": { "5": 2, "6": 1 },
  "damageFee": 185.0
}

// Response 200 → Daños registrados
```

---

## 7. Preferencias — `/preferences`

### Modelo: Preferencias

```json
{
  "language": "es",
  "darkMode": false
}```

### Endpoints

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| `GET` | `/preferences` | Obtener preferencias del usuario autenticado | Todos (autenticado) |
| `PUT` | `/preferences` | Actualizar preferencias | Todos (autenticado) |

#### `PUT /preferences`

```json
// Request
{ "language": "en", "darkMode": true }

// Response 200 → Preferencias actualizadas
```

---

## 8. Estadísticas / Dashboard — `/stats` *(futuro)*

> Estos endpoints alimentan el panel admin y el futuro panel cliente.

### Endpoints

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| `GET` | `/stats/dashboard` | Resumen general del admin | ADMIN, SUPERADMIN |
| `GET` | `/stats/my` | Resumen del usuario autenticado | USUARIO |
| `GET` | `/stats/revenue` | Ingresos por período | ADMIN, SUPERADMIN |
| `GET` | `/stats/equipment-usage` | Uso de equipamiento por período | ADMIN |

#### `GET /stats/dashboard`

```json
// Response 200
{
  "totalExcursions": 15,
  "totalEquipment": 10,
  "pendingRequests": 3,
  "pendingReservations": 5,
  "activeUsers": 42,
  "confirmedReservationsThisMonth": 12,
  "revenueThisMonth": 2350.00,
  "recentRequests": [ /* últimas 5-10 solicitudes */ ]
}
```

#### `GET /stats/my` *(futuro — para HomeClientPage)*

```json
// Response 200
{
  "activeReservations": 2,
  "pendingRequests": 1,
  "completedExcursions": 5,
  "totalSpent": 450.00,
  "upcomingExcursions": [ /* próximas excursiones del usuario */ ]
}
```

#### `GET /stats/revenue` *(futuro)*

```
GET /stats/revenue?from=2026-01-01&to=2026-06-30&groupBy=month
```

```json
// Response 200
{
  "total": 15200.00,
  "breakdown": [
    { "period": "2026-01", "excursions": 2500, "equipment": 1200 },
    { "period": "2026-02", "excursions": 3000, "equipment": 800 }
  ]
}
```

---

## 9. Categorías — `/categories` *(futuro)*

> Actualmente es un enum fijo en el frontend. Si se quiere hacer dinámico:

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| `GET` | `/categories` | Listar categorías de actividad | Todos |
| `POST` | `/categories` | Crear categoría | SUPERADMIN |
| `PUT` | `/categories/{id}` | Editar categoría | SUPERADMIN |
| `DELETE` | `/categories/{id}` | Eliminar categoría | SUPERADMIN |

```json
// GET /categories Response
[
  { "id": 1, "name": "Acuático", "icon": "water" },
  { "id": 2, "name": "Nieve", "icon": "snow" },
  { "id": 3, "name": "Montaña", "icon": "mountain" },
  { "id": 4, "name": "Camping", "icon": "tent" }
]
```

---

## 10. Notificaciones — `/notifications` *(futuro)*

> Para alertas push y avisos in-app.

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| `GET` | `/notifications` | Listar notificaciones del usuario | Todos |
| `PATCH` | `/notifications/{id}/read` | Marcar como leída | Todos |
| `PATCH` | `/notifications/read-all` | Marcar todas como leídas | Todos |
| `DELETE` | `/notifications/{id}` | Eliminar notificación | Todos |

```json
// GET /notifications Response
{
  "content": [
    {
      "id": 1,
      "type": "REQUEST_ACCEPTED",
      "title": "Solicitud aceptada",
      "body": "Tu solicitud #3 ha sido confirmada",
      "read": false,
      "createdAt": "2026-04-27T10:30:00",
      "data": { "requestId": 3 }
    }
  ],
  "unreadCount": 3
}
```

---

## 11. Archivos / Imágenes — `/files` *(futuro)*

> Gestión centralizada de uploads (fotos de perfil, excursiones, equipamiento).

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| `POST` | `/files/upload` | Subir archivo | Todos (autenticado) |
| `GET` | `/files/{id}` | Descargar archivo | Todos |
| `DELETE` | `/files/{id}` | Eliminar archivo | ADMIN, propietario |

```json
// POST /files/upload
// Content-Type: multipart/form-data
// Body: file + type (avatar|excursion|equipment)

// Response 201
{
  "id": "uuid",
  "url": "https://storage.outventura.com/uploads/uuid.jpg",
  "type": "avatar",
  "createdAt": "2026-04-27T10:00:00"
}
```

---

## Resumen de conteo

| Recurso | Endpoints actuales | Endpoints futuros | Total |
|---|---|---|---|
| Auth | 3 | 4 | **7** |
| Usuarios | 6 | 3 | **9** |
| Excursiones | 5 | 2 | **7** |
| Equipamiento | 5 | 4 | **9** |
| Solicitudes | 8 | 3 | **11** |
| Reservas | 8 | 3 | **11** |
| Preferencias | 2 | 0 | **2** |
| Estadísticas | 0 | 4 | **4** |
| Categorías | 0 | 4 | **4** |
| Notificaciones | 0 | 4 | **4** |
| Archivos | 0 | 3 | **3** |
| **TOTAL** | **37** | **34** | **~71** |

---

## Diagrama de relaciones

```
                     ┌─────────────┐
                     │  Categoría  │
                     └──────┬──────┘
                            │ N:M
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
       ┌────────────┐ ┌──────────┐ ┌────────────┐
       │ Equipamiento│ │Excursión │ │            │
       └──────┬─────┘ └────┬─────┘ │            │
              │             │       │            │
              │        ┌────┴────┐  │            │
              │        │Solicitud│──┤  Usuario   │
              │        └────┬────┘  │            │
              │             │       │            │
              │      ┌──────┴──────┐│            │
              └─────►│   Reserva   ├┤            │
                     │  (líneas)   ││            │
                     └─────────────┘└────────────┘
```

---

## Códigos de error estándar

| Código | Significado |
|---|---|
| `400` | Datos de entrada inválidos (validación) |
| `401` | No autenticado (token ausente o expirado) |
| `403` | Sin permisos para este recurso |
| `404` | Recurso no encontrado |
| `409` | Conflicto (email duplicado, stock insuficiente) |
| `422` | Entidad no procesable (regla de negocio) |
| `500` | Error interno del servidor |

```json
// Formato de error estándar
{
  "status": 400,
  "error": "Bad Request",
  "message": "El email ya está registrado",
  "timestamp": "2026-04-27T10:30:00",
  "path": "/users"
}
```
