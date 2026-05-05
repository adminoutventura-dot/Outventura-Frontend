// create-equipment.dto.ts
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsNumber, IsOptional, Min, IsInt, IsEnum, IsArray, IsUrl } from 'class-validator';
import { ActivityCategory } from '@prisma/client';

export class CreateEquipmentDto {
    @ApiProperty({ description: 'Títol o nom del material', example: 'Bicicleta de muntanya Trek Fuel EX' })
    @IsString()
    @IsNotEmpty()
    title!: string;

    @ApiPropertyOptional({ description: 'Descripció detallada', example: 'Talla L, frens de disc hidràulics' })
    @IsString()
    @IsOptional()
    description?: string;

    @ApiProperty({ description: 'Preu de lloguer per dia', example: 25.50 })
    @IsNumber()
    @Min(0)
    price_per_day!: number;

    @ApiPropertyOptional({ description: 'Cargo per danys', example: 50.0, default: 0 })
    @IsNumber()
    @Min(0)
    @IsOptional()
    damage_fee?: number;

    @ApiProperty({ description: 'Unitats totals en stock', example: 10, default: 1 })
    @IsInt()
    @Min(1)
    units!: number;

    @ApiPropertyOptional({ description: 'Unitats disponibles actualment', example: 8, default: 1 })
    @IsInt()
    @Min(0)
    @IsOptional()
    stock?: number;

    @ApiPropertyOptional({ enum: ActivityCategory, isArray: true, description: 'Categories d\'activitat' })
    @IsEnum(ActivityCategory, { each: true })
    @IsArray()
    @IsOptional()
    categories?: ActivityCategory[];

    @ApiPropertyOptional({ description: 'URL de la imatge del material' })
    @IsString()
    @IsOptional()
    image_url?: string;

    @ApiProperty({ description: 'ID de l\'estat del material (FK)', example: 1 })
    @IsInt()
    @IsNotEmpty()
    statusId!: number;
}