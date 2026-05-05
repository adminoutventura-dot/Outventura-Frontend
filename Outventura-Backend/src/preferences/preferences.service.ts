import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpsertPreferencesDto } from './dto/upsert-preferences.dto';

@Injectable()
export class PreferencesService {
  constructor(private prisma: PrismaService) {}

  // GET /preferences — Obtiene las preferencias del usuario autenticado
  async getForUser(userId: number) {
    const prefs = await this.prisma.preferences.findUnique({ where: { userId } });
    if (!prefs) throw new NotFoundException('Preferencias no encontradas para este usuario');
    return prefs;
  }

  // PUT /preferences — Crea o actualiza las preferencias del usuario autenticado
  async upsertForUser(userId: number, dto: UpsertPreferencesDto) {
    return this.prisma.preferences.upsert({
      where: { userId },
      create: { userId, ...dto },
      update: { ...dto },
    });
  }
}
