import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsNotEmpty } from 'class-validator';

// DTO para asignar un experto a una solicitud
export class AssignExpertDto {
  @ApiProperty({ example: 2, description: 'ID del usuario con rol EXPERT' })
  @IsInt()
  @IsNotEmpty()
  expertId!: number;
}
