import { Injectable, NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) { }

  async create(dto: CreateUserDto) {
    const existingEmail = await this.prisma.user.findUnique({
      where: { email: dto.email }
    });
    if (existingEmail) throw new ConflictException('Aquest correu ja està registrat');

    const roleExists = await this.prisma.role.findUnique({
      where: { id_role: dto.roleId }
    });
    if (!roleExists) throw new BadRequestException('El rol especificat no existeix');

    const hashedPassword = await bcrypt.hash(dto.password, 10);
    const user = await this.prisma.user.create({
      data: { ...dto, password: hashedPassword },
      include: { role: true }
    });

    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }

  async findAll(search?: string) {
    const users = await this.prisma.user.findMany({
      where: search
        ? {
            OR: [
              { name: { contains: search, mode: 'insensitive' } },
              { surname: { contains: search, mode: 'insensitive' } },
              { email: { contains: search, mode: 'insensitive' } },
            ],
          }
        : undefined,
      include: {
        role: {
          select: { id_role: true, code: true }
        }
      }
    });

    return users.map(({ password, ...userWithoutPassword }) => userWithoutPassword);
  }

  // Activa o desactiva un usuario (PATCH /:id/status)
  async patchStatus(id: number, status: boolean) {
    await this.findOne(id);
    const updatedUser = await this.prisma.user.update({
      where: { id_user: id },
      data: { status },
      include: { role: true },
    });
    const { password, ...userWithoutPassword } = updatedUser;
    return userWithoutPassword;
  }

  async findOne(id: number) {
    const user = await this.prisma.user.findUnique({
      where: { id_user: id },
      include: { role: true }
    });

    if (!user) throw new NotFoundException(`L'usuari amb ID ${id} no existeix`);

    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }

  async update(id: number, dto: UpdateUserDto) {
    await this.findOne(id);

    if (dto.email) {
      const emailConflict = await this.prisma.user.findFirst({
        where: {
          email: dto.email,
          NOT: { id_user: id }
        }
      });
      if (emailConflict) throw new ConflictException('L’email ja està sent usat per un altre usuari');
    }

    if (dto.roleId) {
      const roleExists = await this.prisma.role.findUnique({ where: { id_role: dto.roleId } });
      if (!roleExists) throw new BadRequestException('El rol especificat no existeix');
    }

    const dataToUpdate: UpdateUserDto = { ...dto };
    if (dto.password) {
      dataToUpdate.password = await bcrypt.hash(dto.password, 10);
    }

    const updatedUser = await this.prisma.user.update({
      where: { id_user: id },
      data: dataToUpdate,
      include: { role: true }
    });

    const { password, ...userWithoutPassword } = updatedUser;
    return userWithoutPassword;
  }

  async remove(id: number) {
    await this.findOne(id);

    return this.prisma.user.delete({
      where: { id_user: id }
    });
  }
}