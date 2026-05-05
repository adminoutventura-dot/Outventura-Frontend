import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReservationDto } from './dto/create-reservation.dto';
import { UpdateReservationDto } from './dto/update-reservation.dto';
import { RegisterDamagesDto } from './dto/register-damages.dto';
import { ReservationStatus } from '@prisma/client';

// Relaciones que se incluyen por defecto al consultar una reserva
const RESERVATION_INCLUDE = {
  user: { select: { id_user: true, name: true, surname: true, email: true } },
  excursion: { select: { id_excursion: true, start_point: true, end_point: true } },
  lines: {
    include: {
      equipment: { select: { id_equipment: true, title: true, price_per_day: true } },
    },
  },
};

@Injectable()
export class ReservationService {
  constructor(private prisma: PrismaService) {}

  // Crea una reserva con sus líneas de equipamiento
  async create(dto: CreateReservationDto) {
    this.validateDates(dto.start_date, dto.end_date);

    // Verificar que el usuario existe
    const user = await this.prisma.user.findUnique({ where: { id_user: dto.userId } });
    if (!user) throw new NotFoundException(`Usuario con ID ${dto.userId} no encontrado`);

    return this.prisma.reservation.create({
      data: {
        start_date: new Date(dto.start_date),
        end_date: new Date(dto.end_date),
        userId: dto.userId,
        excursionId: dto.excursionId,
        // Crea las líneas anidadas en la misma operación
        lines: {
          create: dto.lines.map((l) => ({
            quantity: l.quantity,
            equipmentId: l.equipmentId,
          })),
        },
      },
      include: RESERVATION_INCLUDE,
    });
  }

  // Lista reservas con filtro opcional por usuario
  async findAll(search?: string, userId?: number) {
    return this.prisma.reservation.findMany({
      where: {
        AND: [
          userId ? { userId } : {},
          search
            ? {
                excursion: {
                  OR: [
                    { start_point: { contains: search, mode: 'insensitive' } },
                    { end_point: { contains: search, mode: 'insensitive' } },
                  ],
                },
              }
            : {},
        ],
      },
      include: RESERVATION_INCLUDE,
      orderBy: { start_date: 'desc' },
    });
  }

  // Obtiene una reserva por ID o lanza 404
  async findOne(id: number) {
    const reservation = await this.prisma.reservation.findUnique({
      where: { id_reservation: id },
      include: RESERVATION_INCLUDE,
    });
    if (!reservation) throw new NotFoundException(`Reserva con ID ${id} no encontrada`);
    return reservation;
  }

  // Actualiza una reserva reemplazando las líneas por completo
  async update(id: number, dto: UpdateReservationDto) {
    await this.findOne(id);
    if (dto.start_date && dto.end_date) this.validateDates(dto.start_date, dto.end_date);

    return this.prisma.reservation.update({
      where: { id_reservation: id },
      data: {
        start_date: dto.start_date ? new Date(dto.start_date) : undefined,
        end_date: dto.end_date ? new Date(dto.end_date) : undefined,
        userId: dto.userId,
        excursionId: dto.excursionId,
        // Si vienen líneas nuevas, borramos las antiguas y creamos las nuevas
        ...(dto.lines
          ? {
              lines: {
                deleteMany: {},
                create: dto.lines.map((l) => ({
                  quantity: l.quantity,
                  equipmentId: l.equipmentId,
                })),
              },
            }
          : {}),
      },
      include: RESERVATION_INCLUDE,
    });
  }

  // Elimina una reserva (y sus líneas por cascade)
  async remove(id: number) {
    await this.findOne(id);
    return this.prisma.reservation.delete({ where: { id_reservation: id } });
  }

  // PATCH /reservations/:id/approve — PENDING → CONFIRMED
  async approve(id: number) {
    const r = await this.findOne(id);
    if (r.status !== ReservationStatus.PENDING) {
      throw new BadRequestException('Solo se pueden aprobar reservas en estado PENDING');
    }
    return this.prisma.reservation.update({
      where: { id_reservation: id },
      data: { status: ReservationStatus.CONFIRMED },
      include: RESERVATION_INCLUDE,
    });
  }

  // PATCH /reservations/:id/reject — PENDING/CONFIRMED → CANCELLED
  async reject(id: number) {
    const r = await this.findOne(id);
    const rejectable = [ReservationStatus.PENDING, ReservationStatus.CONFIRMED] as ReservationStatus[];
    if (!rejectable.includes(r.status)) {
      throw new BadRequestException('No se puede rechazar una reserva en este estado');
    }
    return this.prisma.reservation.update({
      where: { id_reservation: id },
      data: { status: ReservationStatus.CANCELLED },
      include: RESERVATION_INCLUDE,
    });
  }

  // PATCH /reservations/:id/cancel — Cancelación por parte del usuario o admin
  async cancel(id: number) {
    const r = await this.findOne(id);
    const cancellable = [ReservationStatus.PENDING, ReservationStatus.CONFIRMED] as ReservationStatus[];
    if (!cancellable.includes(r.status)) {
      throw new BadRequestException('No se puede cancelar una reserva en este estado');
    }
    return this.prisma.reservation.update({
      where: { id_reservation: id },
      data: { status: ReservationStatus.CANCELLED },
      include: RESERVATION_INCLUDE,
    });
  }

  // PATCH /reservations/:id/return — CONFIRMED → RETURNED, con registro opcional de daños
  async return(id: number, dto?: RegisterDamagesDto) {
    const r = await this.findOne(id);
    if (r.status !== ReservationStatus.CONFIRMED && r.status !== ReservationStatus.IN_PROGRESS) {
      throw new BadRequestException('Solo se pueden devolver reservas en estado CONFIRMED o IN_PROGRESS');
    }
    return this.prisma.reservation.update({
      where: { id_reservation: id },
      data: {
        status: ReservationStatus.RETURNED,
        damaged_items: dto?.damaged_items ?? {},
        damage_fee: dto?.damage_fee ?? 0,
      },
      include: RESERVATION_INCLUDE,
    });
  }

  // PATCH /reservations/:id/damages — Registra daños sin cambiar el estado
  async damages(id: number, dto: RegisterDamagesDto) {
    await this.findOne(id);
    return this.prisma.reservation.update({
      where: { id_reservation: id },
      data: {
        damaged_items: dto.damaged_items,
        damage_fee: dto.damage_fee ?? 0,
      },
      include: RESERVATION_INCLUDE,
    });
  }

  private validateDates(start: string, end: string) {
    if (new Date(start) >= new Date(end)) {
      throw new BadRequestException('La fecha de inicio debe ser anterior a la fecha de fin');
    }
  }
}
