import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

// Converts a snake_case string to camelCase.
function toCamel(s: string): string {
  return s.replace(/_([a-z])/g, (_, c: string) => c.toUpperCase());
}

// Recursively converts all keys of an object from snake_case to camelCase.
// Arrays and primitive values are returned as-is (or recursed).
function deepCamel(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(deepCamel);
  }
  if (value !== null && typeof value === 'object') {
    const result: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      result[toCamel(k)] = deepCamel(v);
    }
    return result;
  }
  return value;
}

// Global interceptor: transforms every response body so that all JSON keys are camelCase.
// This means Prisma snake_case fields (id_user, start_date, etc.) arrive as
// idUser, startDate, etc. at the Flutter client — matching what fromMap() expects.
@Injectable()
export class CamelCaseInterceptor implements NestInterceptor {
  intercept(_ctx: ExecutionContext, next: CallHandler): Observable<unknown> {
    return next.handle().pipe(map((data) => deepCamel(data)));
  }
}
