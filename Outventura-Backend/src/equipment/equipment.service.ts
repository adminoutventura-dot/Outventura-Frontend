import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateEquipmentDto } from './dto/create-equipment.dto';

@Injectable()
export class EquipmentService {
  constructor(private prisma: PrismaService) { }

  async create(dto: CreateEquipmentDto) {
    return this.prisma.equipment.create({
      data: dto,
    });
  }

  // Lista equipamiento con filtro opcional por texto y categoría
  async findAll(search?: string) {
    return this.prisma.equipment.findMany({
      where: search
        ? {
            OR: [
              { title: { contains: search, mode: 'insensitive' } },
              { description: { contains: search, mode: 'insensitive' } },
            ],
          }
        : undefined,
      include: { status: true },
    });
  }

  async findOne(id: number) {
    const item = await this.prisma.equipment.findUnique({
      where: { id_equipment: id },
      include: { status: true },
    });
    if (!item) throw new NotFoundException(`Material amb ID ${id} no trobat`);
    return item;
  }

  async update(id: number, dto: Partial<CreateEquipmentDto>) {
    return this.prisma.equipment.update({
      where: { id_equipment: id },
      data: dto,
    });
  }

  async remove(id: number) {
    return this.prisma.equipment.delete({
      where: { id_equipment: id },
    });
  }

  // PATCH /equipment/:id/status — Cambia el estado del equipamiento
  async patchStatus(id: number, statusId: number) {
    await this.findOne(id);
    return this.prisma.equipment.update({
      where: { id_equipment: id },
      data: { statusId },
      include: { status: true },
    });
  }

  // PATCH /equipment/:id/stock — Actualiza las unidades disponibles
  async patchStock(id: number, stock: number) {
    await this.findOne(id);
    return this.prisma.equipment.update({
      where: { id_equipment: id },
      data: { stock },
      include: { status: true },
    });
  }
}