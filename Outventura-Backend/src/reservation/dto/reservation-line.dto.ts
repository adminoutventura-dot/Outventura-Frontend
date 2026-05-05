import { ApiProperty } from '@nestjs/swagger';
import {
  IsInt,
  IsNotEmpty,
  Min,
} from 'class-validator';

// Representa una línea dentro de una reserva (un equipamiento y su cantidad)
export class ReservationLineDto {
  @ApiProperty({ example: 5, description: 'ID del equipamiento' })
  @IsInt()
  @IsNotEmpty()
  equipmentId!: number;

  @ApiProperty({ example: 2, description: 'Unidades reservadas' })
  @IsInt()
  @Min(1)
  quantity!: number;
}
