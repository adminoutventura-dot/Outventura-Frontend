import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';

// Tiempo de vida del access token (15 minutos)
const ACCESS_TOKEN_EXPIRY = '15m';
// Tiempo de vida del refresh token (7 días en ms para guardar la fecha de expiración)
const REFRESH_TOKEN_EXPIRY_DAYS = 7;

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
  ) {}

  // Inicia sesión: valida credenciales y devuelve access + refresh token
  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
      include: { role: true },
    });

    if (!user) throw new UnauthorizedException('Credenciales inválidas');
    if (!user.status) throw new UnauthorizedException('Usuario desactivado');

    const passwordValid = await bcrypt.compare(dto.password, user.password);
    if (!passwordValid) throw new UnauthorizedException('Credenciales inválidas');

    const { password, ...userWithoutPassword } = user;
    return this.generateTokens(userWithoutPassword);
  }

  // Renueva el access token usando un refresh token válido
  async refresh(token: string) {
    const stored = await this.prisma.refreshToken.findUnique({
      where: { token },
      include: { user: { include: { role: true } } },
    });

    if (!stored) throw new UnauthorizedException('Refresh token inválido');
    if (stored.expiresAt < new Date()) {
      // Token expirado: eliminar y forzar re-login
      await this.prisma.refreshToken.delete({ where: { token } });
      throw new UnauthorizedException('Refresh token expirado');
    }

    // Rotar el token: eliminar el viejo y generar uno nuevo
    await this.prisma.refreshToken.delete({ where: { token } });
    const { password, ...user } = stored.user;
    return this.generateTokens(user);
  }

  // Cierra sesión eliminando el refresh token de la DB
  async logout(token: string) {
    await this.prisma.refreshToken.deleteMany({ where: { token } });
    return { message: 'Sesión cerrada correctamente' };
  }

  // Devuelve el usuario autenticado a partir del payload del JWT
  async getMe(userId: number) {
    const user = await this.prisma.user.findUnique({
      where: { id_user: userId },
      include: { role: true },
    });
    if (!user) throw new UnauthorizedException('Usuario no encontrado');
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }

  // Genera access token + refresh token y guarda el refresh en DB
  private async generateTokens(user: any) {
    const payload = { sub: user.id_user, email: user.email, role: user.role.code };

    const accessToken = this.jwt.sign(payload, { expiresIn: ACCESS_TOKEN_EXPIRY });

    // El refresh token es un JWT de larga duración sin info sensible
    const rawRefresh = this.jwt.sign({ sub: user.id_user }, { expiresIn: `${REFRESH_TOKEN_EXPIRY_DAYS}d` });

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_EXPIRY_DAYS);

    await this.prisma.refreshToken.create({
      data: {
        token: rawRefresh,
        userId: user.id_user,
        expiresAt,
      },
    });

    return { accessToken, refreshToken: rawRefresh, user };
  }
}
