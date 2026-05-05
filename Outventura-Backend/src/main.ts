import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';
import { CamelCaseInterceptor } from './common/interceptors/camel-case.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Allow Flutter clients (Android emulator uses 10.0.2.2, iOS simulator uses localhost)
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    allowedHeaders: 'Content-Type, Authorization',
  });

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // Convert all response JSON keys from snake_case to camelCase
  app.useGlobalInterceptors(new CamelCaseInterceptor());

  const config = new DocumentBuilder()
    .setTitle('Outventura API')
    .setDescription('REST API para la aplicación Outventura')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  await app.listen(3000);
}
bootstrap();
