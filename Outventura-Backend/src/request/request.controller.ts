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
import { RequestService } from './request.service';
import { CreateRequestDto } from './dto/create-request.dto';
import { UpdateRequestDto } from './dto/update-request.dto';
import { AssignExpertDto } from './dto/assign-expert.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Requests')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('requests')
export class RequestController {
  constructor(private readonly requestService: RequestService) {}

  // POST /requests — Crear solicitud de excursión
  @Post()
  @ApiOperation({ summary: 'Crear solicitud de excursión' })
  @ApiResponse({ status: 201, description: 'Solicitud creada en estado PENDING.' })
  create(@Body() dto: CreateRequestDto) {
    return this.requestService.create(dto);
  }

  // GET /requests — Listar solicitudes con filtros opcionales
  @Get()
  @ApiOperation({ summary: 'Listar solicitudes' })
  @ApiQuery({ name: 'search', required: false, description: 'Buscar por punto de inicio o fin' })
  @ApiQuery({ name: 'userId', required: false, type: Number, description: 'Filtrar por usuario' })
  findAll(
    @Query('search') search?: string,
    @Query('userId') userId?: string,
  ) {
    return this.requestService.findAll(search, userId ? parseInt(userId) : undefined);
  }

  // GET /requests/:id — Obtener solicitud por ID
  @Get(':id')
  @ApiOperation({ summary: 'Obtener solicitud por ID' })
  @ApiParam({ name: 'id' })
  @ApiResponse({ status: 404, description: 'Solicitud no encontrada.' })
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.requestService.findOne(id);
  }

  // PUT /requests/:id — Actualizar solicitud
  @Put(':id')
  @ApiOperation({ summary: 'Actualizar solicitud' })
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateRequestDto) {
    return this.requestService.update(id, dto);
  }

  // DELETE /requests/:id — Eliminar solicitud
  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar solicitud' })
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.requestService.remove(id);
  }

  // PATCH /requests/:id/accept — Aceptar solicitud (PENDING → CONFIRMED)
  @Patch(':id/accept')
  @ApiOperation({ summary: 'Aceptar solicitud' })
  accept(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { expertId?: number },
  ) {
    return this.requestService.accept(id, body.expertId);
  }

  // PATCH /requests/:id/reject — Rechazar solicitud (PENDING → CANCELLED)
  @Patch(':id/reject')
  @ApiOperation({ summary: 'Rechazar solicitud' })
  reject(@Param('id', ParseIntPipe) id: number) {
    return this.requestService.reject(id);
  }

  // PATCH /requests/:id/start — Iniciar solicitud (CONFIRMED → IN_PROGRESS)
  @Patch(':id/start')
  @ApiOperation({ summary: 'Iniciar solicitud' })
  start(@Param('id', ParseIntPipe) id: number) {
    return this.requestService.start(id);
  }

  // PATCH /requests/:id/finalize — Finalizar solicitud (IN_PROGRESS → FINISHED)
  @Patch(':id/finalize')
  @ApiOperation({ summary: 'Finalizar solicitud' })
  finalize(@Param('id', ParseIntPipe) id: number) {
    return this.requestService.finalize(id);
  }

  // PATCH /requests/:id/cancel — Cancelar solicitud
  @Patch(':id/cancel')
  @ApiOperation({ summary: 'Cancelar solicitud' })
  cancel(@Param('id', ParseIntPipe) id: number) {
    return this.requestService.cancel(id);
  }

  // PATCH /requests/:id/assign-expert — Asignar experto a la solicitud
  @Patch(':id/assign-expert')
  @ApiOperation({ summary: 'Asignar experto a la solicitud' })
  assignExpert(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: AssignExpertDto,
  ) {
    return this.requestService.assignExpert(id, dto.expertId);
  }
}
