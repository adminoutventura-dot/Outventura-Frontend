import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class RefreshTokenDto {
  @ApiProperty({ description: 'Token de refresco obtenido en el login' })
  @IsString()
  @IsNotEmpty()
  refreshToken!: string;
}
