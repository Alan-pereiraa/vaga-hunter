import { Test } from '@nestjs/testing';
import { HealthController } from './health.controller.js';
import { HealthService } from '../services/health.service.js';

describe('HealthController', () => {
  it('repassa o status calculado pelo serviço', async () => {
    const response = {
      status: 'degraded',
      services: { api: 'up', database: 'down' },
      checkedAt: '2026-11-27T12:00:00.000Z',
    };
    const moduleRef = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [{ provide: HealthService, useValue: { check: vi.fn().mockResolvedValue(response) } }],
    }).compile();

    await expect(moduleRef.get(HealthController).check()).resolves.toEqual(response);
  });
});
