import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsEnum,
  IsOptional,
  IsString,
} from 'class-validator';
import { ActivityCategory } from '@prisma/client';

export class UpsertPreferencesDto {
  @ApiPropertyOptional({ enum: ActivityCategory, isArray: true })
  @IsEnum(ActivityCategory, { each: true })
  @IsOptional()
  preferred_categories?: ActivityCategory[];

  @ApiPropertyOptional({ example: 'es' })
  @IsString()
  @IsOptional()
  language?: string;

  @ApiPropertyOptional({ example: true })
  @IsBoolean()
  @IsOptional()
  notifications_enabled?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsBoolean()
  @IsOptional()
  dark_mode?: boolean;
}
