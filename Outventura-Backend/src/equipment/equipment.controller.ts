// equipment.controller.ts
import { Controller, Get, Post, Body, Patch, Param, Delete, ParseIntPipe, Query, UseGuards } from '@nestjs/common';
import { EquipmentService } from './equipment.service';
import { CreateEquipmentDto } from './dto/create-equipment.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Equipment')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('equipment')
export class EquipmentController {
  constructor(private readonly equipmentService: EquipmentService) { }

  @Post()
  @ApiOperation({ summary: 'Registrar nou material en el catàleg' })
  @ApiResponse({ status: 201, description: 'Material creat correctament.' })
  create(@Body() dto: CreateEquipmentDto) {
    return this.equipmentService.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Llistar tot el material' })
  @ApiQuery({ name: 'search', required: false, description: 'Buscar por título o descripción' })
  findAll(@Query('search') search?: string) {
    return this.equipmentService.findAll(search);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtenir detalls d\'un material per ID' })
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.equipmentService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualitzar dades del material' })
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: Partial<CreateEquipmentDto>) {
    return this.equipmentService.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar material del catàleg' })
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.equipmentService.remove(id);
  }

  // PATCH /equipment/:id/status — Actualizar estado del equipamiento
  @Patch(':id/status')
  @ApiOperation({ summary: 'Cambiar estado del material' })
  patchStatus(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { statusId: number },
  ) {
    return this.equipmentService.patchStatus(id, body.statusId);
  }

  // PATCH /equipment/:id/stock — Actualizar stock disponible
  @Patch(':id/stock')
  @ApiOperation({ summary: 'Actualizar stock disponible del material' })
  patchStock(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { stock: number },
  ) {
    return this.equipmentService.patchStock(id, body.stock);
  }
}