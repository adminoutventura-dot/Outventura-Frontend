import { ApiProperty } from '@nestjs/swagger';
import {
  IsInt,
  IsNotEmpty,
  IsDateString,
  IsArray,
  ValidateNested,
  IsOptional,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ReservationLineDto } from './reservation-line.dto';

export class CreateReservationDto {
  @ApiProperty({ example: '2026-06-01T09:00:00Z' })
  @IsDateString()
  start_date!: string;

  @ApiProperty({ example: '2026-06-03T17:00:00Z' })
  @IsDateString()
  end_date!: string;

  @ApiProperty({ example: 3, description: 'ID del usuario que hace la reserva' })
  @IsInt()
  @IsNotEmpty()
  userId!: number;

  @ApiProperty({ example: 1, required: false, description: 'ID de la excursión vinculada (opcional)' })
  @IsInt()
  @IsOptional()
  excursionId?: number;

  @ApiProperty({ type: [ReservationLineDto], description: 'Líneas de equipamiento reservado' })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ReservationLineDto)
  lines!: ReservationLineDto[];
}
