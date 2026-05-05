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
import { ReservationService } from './reservation.service';
import { CreateReservationDto } from './dto/create-reservation.dto';
import { UpdateReservationDto } from './dto/update-reservation.dto';
import { RegisterDamagesDto } from './dto/register-damages.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Reservations')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('reservations')
export class ReservationController {
  constructor(private readonly reservationService: ReservationService) {}

  // POST /reservations
  @Post()
  @ApiOperation({ summary: 'Crear reserva de equipamiento' })
  @ApiResponse({ status: 201, description: 'Reserva creada.' })
  create(@Body() dto: CreateReservationDto) {
    return this.reservationService.create(dto);
  }

  // GET /reservations
  @Get()
  @ApiOperation({ summary: 'Listar reservas' })
  @ApiQuery({ name: 'search', required: false })
  @ApiQuery({ name: 'userId', required: false, type: Number })
  findAll(@Query('search') search?: string, @Query('userId') userId?: string) {
    return this.reservationService.findAll(search, userId ? parseInt(userId) : undefined);
  }

  // GET /reservations/:id
  @Get(':id')
  @ApiOperation({ summary: 'Obtener reserva por ID' })
  @ApiParam({ name: 'id' })
  @ApiResponse({ status: 404, description: 'Reserva no encontrada.' })
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.reservationService.findOne(id);
  }

  // PUT /reservations/:id
  @Put(':id')
  @ApiOperation({ summary: 'Actualizar reserva' })
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateReservationDto) {
    return this.reservationService.update(id, dto);
  }

  // DELETE /reservations/:id
  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar reserva' })
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.reservationService.remove(id);
  }

  // PATCH /reservations/:id/approve
  @Patch(':id/approve')
  @ApiOperation({ summary: 'Aprobar reserva (PENDING → CONFIRMED)' })
  approve(@Param('id', ParseIntPipe) id: number) {
    return this.reservationService.approve(id);
  }

  // PATCH /reservations/:id/reject
  @Patch(':id/reject')
  @ApiOperation({ summary: 'Rechazar reserva' })
  reject(@Param('id', ParseIntPipe) id: number) {
    return this.reservationService.reject(id);
  }

  // PATCH /reservations/:id/cancel
  @Patch(':id/cancel')
  @ApiOperation({ summary: 'Cancelar reserva' })
  cancel(@Param('id', ParseIntPipe) id: number) {
    return this.reservationService.cancel(id);
  }

  // PATCH /reservations/:id/return
  @Patch(':id/return')
  @ApiOperation({ summary: 'Registrar devolución (CONFIRMED → RETURNED)' })
  return(@Param('id', ParseIntPipe) id: number, @Body() dto?: RegisterDamagesDto) {
    return this.reservationService.return(id, dto);
  }

  // PATCH /reservations/:id/damages
  @Patch(':id/damages')
  @ApiOperation({ summary: 'Registrar daños sin cambiar el estado' })
  damages(@Param('id', ParseIntPipe) id: number, @Body() dto: RegisterDamagesDto) {
    return this.reservationService.damages(id, dto);
  }
}
