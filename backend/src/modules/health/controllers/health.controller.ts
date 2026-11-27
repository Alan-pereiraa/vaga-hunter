import { Controller, Get } from '@nestjs/common';
import { HealthResponse } from '../models/health-status.model.js';
import { HealthService } from '../services/health.service.js';

@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  check(): Promise<HealthResponse> {
    return this.healthService.check();
  }
}
