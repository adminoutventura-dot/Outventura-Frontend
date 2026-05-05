import { ApiProperty } from '@nestjs/swagger';
import { IsObject, IsNumber, IsOptional, Min } from 'class-validator';

// DTO para registrar daños en la devolución de una reserva
export class RegisterDamagesDto {
  @ApiProperty({
    description: 'Mapa de equipmentId → unidades dañadas',
    example: { '5': 2, '6': 1 },
  })
  @IsObject()
  damaged_items!: Record<string, number>;

  @ApiProperty({ example: 185.0, description: 'Cargo total por daños en €' })
  @IsNumber()
  @Min(0)
  @IsOptional()
  damage_fee?: number;
}
