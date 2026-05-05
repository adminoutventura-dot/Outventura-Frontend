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
  IsNumber,
} from 'class-validator';
import { ActivityCategory, ExcursionStatus } from '@prisma/client';

export class CreateExcursionDto {
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

  @ApiProperty({ enum: ActivityCategory, isArray: true, example: ['MOUNTAIN', 'AQUATIC'] })
  @IsArray()
  @IsEnum(ActivityCategory, { each: true })
  categories!: ActivityCategory[];

  @ApiProperty({ example: 20 })
  @IsInt()
  @Min(1)
  participant_count!: number;

  @ApiProperty({ required: false, example: 'Ruta costera con kayak incluido' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({ enum: ExcursionStatus, default: ExcursionStatus.AVAILABLE, required: false })
  @IsEnum(ExcursionStatus)
  @IsOptional()
  status?: ExcursionStatus;

  @ApiProperty({ example: 35.0, default: 0 })
  @IsNumber()
  @Min(0)
  @IsOptional()
  price?: number;

  @ApiProperty({ required: false, example: 'https://storage.outventura.com/excursions/1.jpg' })
  @IsString()
  @IsOptional()
  image_url?: string;
}
