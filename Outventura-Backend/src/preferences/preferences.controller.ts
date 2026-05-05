import { Controller, Get, Put, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PreferencesService } from './preferences.service';
import { UpsertPreferencesDto } from './dto/upsert-preferences.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@ApiTags('Preferences')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('preferences')
export class PreferencesController {
  constructor(private readonly preferencesService: PreferencesService) {}

  // GET /preferences — Devuelve las preferencias del usuario autenticado
  @Get()
  @ApiOperation({ summary: 'Obtener preferencias del usuario autenticado' })
  getMyPreferences(@CurrentUser() user: { id: number }) {
    return this.preferencesService.getForUser(user.id);
  }

  // PUT /preferences — Crea o actualiza las preferencias del usuario autenticado
  @Put()
  @ApiOperation({ summary: 'Crear o actualizar preferencias del usuario autenticado' })
  upsertMyPreferences(
    @CurrentUser() user: { id: number },
    @Body() dto: UpsertPreferencesDto,
  ) {
    return this.preferencesService.upsertForUser(user.id, dto);
  }
}
