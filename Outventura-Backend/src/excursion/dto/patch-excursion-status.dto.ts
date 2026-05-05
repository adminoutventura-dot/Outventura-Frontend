import { ApiProperty } from '@nestjs/swagger';
import { IsEnum } from 'class-validator';
import { ExcursionStatus } from '@prisma/client';

// DTO específico para cambiar solo el estado de una excursión
export class PatchExcursionStatusDto {
  @ApiProperty({ enum: ExcursionStatus, example: ExcursionStatus.CANCELLED })
  @IsEnum(ExcursionStatus)
  status!: ExcursionStatus;
}
