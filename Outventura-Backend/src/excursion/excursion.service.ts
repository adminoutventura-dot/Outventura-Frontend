import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateExcursionDto } from './dto/create-excursion.dto';
import { UpdateExcursionDto } from './dto/update-excursion.dto';
import { ExcursionStatus } from '@prisma/client';

@Injectable()
export class ExcursionService {
  constructor(private prisma: PrismaService) {}

  // Crea una nueva excursión
  async create(dto: CreateExcursionDto) {
    this.validateDates(dto.start_date, dto.end_date);
    return this.prisma.excursion.create({
      data: {
        ...dto,
        start_date: new Date(dto.start_date),
        end_date: new Date(dto.end_date),
        price: dto.price ?? 0,
      },
    });
  }

  // Lista todas las excursiones, con filtro opcional por texto (start/end point) y categoría
  async findAll(search?: string, category?: string) {
    return this.prisma.excursion.findMany({
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
          // Filtra si la categoría está en el array
          category ? { categories: { has: category as any } } : {},
        ],
      },
      orderBy: { start_date: 'asc' },
    });
  }

  // Obtiene una excursión por ID o lanza 404
  async findOne(id: number) {
    const excursion = await this.prisma.excursion.findUnique({
      where: { id_excursion: id },
    });
    if (!excursion) throw new NotFoundException(`Excursión con ID ${id} no encontrada`);
    return excursion;
  }

  // Actualiza los campos de una excursión
  async update(id: number, dto: UpdateExcursionDto) {
    await this.findOne(id);
    if (dto.start_date && dto.end_date) {
      this.validateDates(dto.start_date, dto.end_date);
    }
    return this.prisma.excursion.update({
      where: { id_excursion: id },
      data: {
        ...dto,
        start_date: dto.start_date ? new Date(dto.start_date) : undefined,
        end_date: dto.end_date ? new Date(dto.end_date) : undefined,
      },
    });
  }

  // Cambia solo el estado de una excursión (sin tocar el resto de campos)
  async patchStatus(id: number, status: ExcursionStatus) {
    await this.findOne(id);
    return this.prisma.excursion.update({
      where: { id_excursion: id },
      data: { status },
    });
  }

  // Elimina una excursión
  async remove(id: number) {
    await this.findOne(id);
    return this.prisma.excursion.delete({ where: { id_excursion: id } });
  }

  // Valida que la fecha de inicio sea anterior a la de fin
  private validateDates(start: string, end: string) {
    if (new Date(start) >= new Date(end)) {
      throw new BadRequestException('La fecha de inicio debe ser anterior a la fecha de fin');
    }
  }
}
