export type ServiceStatus = 'up' | 'down';

/** Formato da resposta de GET /api/health */
export interface HealthResponse {
  status: 'ok' | 'degraded';
  services: { api: ServiceStatus; database: ServiceStatus };
  checkedAt: string;
}
