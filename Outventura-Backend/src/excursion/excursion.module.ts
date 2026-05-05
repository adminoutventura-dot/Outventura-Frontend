import { Module } from '@nestjs/common';
import { ExcursionController } from './excursion.controller';
import { ExcursionService } from './excursion.service';
import { PrismaModule } from '../prisma/prisma.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [PrismaModule, AuthModule],
  controllers: [ExcursionController],
  providers: [ExcursionService],
})
export class ExcursionModule {}
