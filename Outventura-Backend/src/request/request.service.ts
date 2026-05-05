import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateRequestDto } from './dto/create-request.dto';
import { UpdateRequestDto } from './dto/update-request.dto';
import { RequestStatus } from '@prisma/client';

// Relaciones que se incluyen por defecto al consultar una solicitud
const REQUEST_INCLUDE = {
  user: { select: { id_user: true, name: true, surname: true, email: true } },
  expert: { select: { id_user: true, name: true, surname: true, email: true } },
  excursion: {
    select: {
      id_excursion: true,
      start_point: true,
      end_point: true,
      status: true,
    },
  },
};

@Injectable()
export class RequestService {
  constructor(private prisma: PrismaService) {}

  // Crea una nueva solicitud de excursión
  async create(dto: CreateRequestDto) {
    this.validateDates(dto.start_date, dto.end_date);
    return this.prisma.request.create({
      data: {
        ...dto,
        start_date: new Date(dto.start_date),
        end_date: new Date(dto.end_date),
      },
      include: REQUEST_INCLUDE,
    });
  }

  // Lista todas las solicitudes, con filtro opcional por búsqueda de ruta y userId
  async findAll(search?: string, userId?: number) {
    return this.prisma.request.findMany({
      where: {
        AND: [
          search
            ? {
                OR: [
                  { start_point: { contains: search, mode: 'insensitive' } },
                  { end_point: { contains: search, mode: 'insensitive' } },
                ],
              }
            : {},
          userId ? { userId } : {},
        ],
      },
      include: REQUEST_INCLUDE,
      orderBy: { createdAt: 'desc' },
    });
  }

  // Obtiene una solicitud por ID o lanza 404
  async findOne(id: number) {
    const request = await this.prisma.request.findUnique({
      where: { id_request: id },
      include: REQUEST_INCLUDE,
    });
    if (!request) throw new NotFoundException(`Solicitud con ID ${id} no encontrada`);
    return request;
  }

  // Actualiza los campos de una solicitud
  async update(id: number, dto: UpdateRequestDto) {
    await this.findOne(id);
    if (dto.start_date && dto.end_date) {
      this.validateDates(dto.start_date, dto.end_date);
    }
    return this.prisma.request.update({
      where: { id_request: id },
      data: {
        ...dto,
        start_date: dto.start_date ? new Date(dto.start_date) : undefined,
        end_date: dto.end_date ? new Date(dto.end_date) : undefined,
      },
      include: REQUEST_INCLUDE,
    });
  }

  // Elimina una solicitud
  async remove(id: number) {
    await this.findOne(id);
    return this.prisma.request.delete({ where: { id_request: id } });
  }

  // PATCH /requests/:id/accept — Cambia estado a CONFIRMED
  async accept(id: number, expertId?: number) {
    const request = await this.findOne(id);
    if (request.status !== RequestStatus.PENDING) {
      throw new BadRequestException('Solo se pueden aceptar solicitudes en estado PENDING');
    }
    return this.prisma.request.update({
      where: { id_request: id },
      data: {
        status: RequestStatus.CONFIRMED,
        ...(expertId ? { expertId } : {}),
      },
      include: REQUEST_INCLUDE,
    });
  }

  // PATCH /requests/:id/reject — Cambia estado a CANCELLED
  async reject(id: number) {
    const request = await this.findOne(id);
    if (request.status !== RequestStatus.PENDING) {
      throw new BadRequestException('Solo se pueden rechazar solicitudes en estado PENDING');
    }
    return this.prisma.request.update({
      where: { id_request: id },
      data: { status: RequestStatus.CANCELLED },
      include: REQUEST_INCLUDE,
    });
  }

  // PATCH /requests/:id/start — Cambia estado a IN_PROGRESS
  async start(id: number) {
    const request = await this.findOne(id);
    if (request.status !== RequestStatus.CONFIRMED) {
      throw new BadRequestException('Solo se pueden iniciar solicitudes en estado CONFIRMED');
    }
    return this.prisma.request.update({
      where: { id_request: id },
      data: { status: RequestStatus.IN_PROGRESS },
      include: REQUEST_INCLUDE,
    });
  }

  // PATCH /requests/:id/finalize — Cambia estado a FINISHED
  async finalize(id: number) {
    const request = await this.findOne(id);
    if (request.status !== RequestStatus.IN_PROGRESS) {
      throw new BadRequestException('Solo se pueden finalizar solicitudes en estado IN_PROGRESS');
    }
    return this.prisma.request.update({
      where: { id_request: id },
      data: { status: RequestStatus.FINISHED },
      include: REQUEST_INCLUDE,
    });
  }

  // PATCH /requests/:id/cancel — Cancela una solicitud desde cualquier estado activo
  async cancel(id: number) {
    const request = await this.findOne(id);
    const cancellable: RequestStatus[] = [RequestStatus.PENDING, RequestStatus.CONFIRMED];
    if (!cancellable.includes(request.status)) {
      throw new BadRequestException('No se puede cancelar una solicitud en este estado');
    }
    return this.prisma.request.update({
      where: { id_request: id },
      data: { status: RequestStatus.CANCELLED },
      include: REQUEST_INCLUDE,
    });
  }

  // PATCH /requests/:id/assign-expert — Asigna un experto a la solicitud
  async assignExpert(id: number, expertId: number) {
    await this.findOne(id);
    // Verificar que el usuario existe
    const expert = await this.prisma.user.findUnique({ where: { id_user: expertId } });
    if (!expert) throw new NotFoundException(`Usuario con ID ${expertId} no encontrado`);
    return this.prisma.request.update({
      where: { id_request: id },
      data: { expertId },
      include: REQUEST_INCLUDE,
    });
  }

  // Valida que la fecha de inicio sea anterior a la de fin
  private validateDates(start: string, end: string) {
    if (new Date(start) >= new Date(end)) {
      throw new BadRequestException('La fecha de inicio debe ser anterior a la fecha de fin');
    }
  }
}
