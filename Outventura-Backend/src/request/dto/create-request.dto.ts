import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsDateString,
  IsArray,
  IsEnum,
  IsInt,
  Min,
  IsOptional,
} from 'class-validator';
import { ActivityCategory } from '@prisma/client';

export class CreateRequestDto {
  @ApiProperty({ example: 'Puerto de Sóller' })
  @IsString()
  @IsNotEmpty()
  start_point!: string;

  @ApiProperty({ example: 'Torre Picada' })
  @IsString()
  @IsNotEmpty()
  end_point!: string;

  @ApiProperty({ example: '2026-06-01T09:00:00Z' })
  @IsDateString()
  start_date!: string;

  @ApiProperty({ example: '2026-06-01T17:00:00Z' })
  @IsDateString()
  end_date!: string;

  @ApiProperty({ enum: ActivityCategory, isArray: true, example: ['MOUNTAIN'] })
  @IsArray()
  @IsEnum(ActivityCategory, { each: true })
  categories!: ActivityCategory[];

  @ApiProperty({ example: 6 })
  @IsInt()
  @Min(1)
  participant_count!: number;

  @ApiProperty({ required: false, example: 'Queremos hacer la ruta costera' })
  @IsString()
  @IsOptional()
  description?: string;

  // El usuario que hace la solicitud (lo asigna el backend desde el JWT normalmente)
  @ApiProperty({ required: false, example: 3 })
  @IsInt()
  @IsOptional()
  userId?: number;

  // El experto asignado (lo asigna el admin posteriormente)
  @ApiProperty({ required: false, example: 2 })
  @IsInt()
  @IsOptional()
  expertId?: number;

  // Excursión de catálogo vinculada (opcional)
  @ApiProperty({ required: false, example: 1 })
  @IsInt()
  @IsOptional()
  excursionId?: number;
}
