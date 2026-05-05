import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { ExcursionService } from './excursion.service';
import { CreateExcursionDto } from './dto/create-excursion.dto';
import { UpdateExcursionDto } from './dto/update-excursion.dto';
import { PatchExcursionStatusDto } from './dto/patch-excursion-status.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Excursions')
@Controller('excursions')
export class ExcursionController {
  constructor(private readonly excursionService: ExcursionService) {}

  // POST /excursions — Crear una nueva excursión (requiere auth)
  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Crear excursión' })
  @ApiResponse({ status: 201, description: 'Excursión creada.' })
  create(@Body() dto: CreateExcursionDto) {
    return this.excursionService.create(dto);
  }

  // GET /excursions — Listar excursiones (público, con filtro opcional)
  @Get()
  @ApiOperation({ summary: 'Listar excursiones' })
  @ApiQuery({ name: 'search', required: false, description: 'Filtrar por punto de inicio o fin' })
  @ApiQuery({ name: 'category', required: false, description: 'Filtrar por categoría (AQUATIC, SNOW, MOUNTAIN, CAMPING)' })
  findAll(
    @Query('search') search?: string,
    @Query('category') category?: string,
  ) {
    return this.excursionService.findAll(search, category);
  }

  // GET /excursions/:id — Obtener excursión por ID (público)
  @Get(':id')
  @ApiOperation({ summary: 'Obtener excursión por ID' })
  @ApiParam({ name: 'id', description: 'ID de la excursión' })
  @ApiResponse({ status: 404, description: 'Excursión no encontrada.' })
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.excursionService.findOne(id);
  }

  // PUT /excursions/:id — Actualizar excursión completa (requiere auth)
  @Put(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Actualizar excursión' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateExcursionDto,
  ) {
    return this.excursionService.update(id, dto);
  }

  // PATCH /excursions/:id/status — Cambiar solo el estado (requiere auth)
  @Patch(':id/status')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Cambiar estado de una excursión' })
  patchStatus(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: PatchExcursionStatusDto,
  ) {
    return this.excursionService.patchStatus(id, dto.status);
  }

  // DELETE /excursions/:id — Eliminar excursión (requiere auth)
  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Eliminar excursión' })
  @ApiResponse({ status: 404, description: 'Excursión no encontrada.' })
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.excursionService.remove(id);
  }
}
