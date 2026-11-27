import { Module } from '@nestjs/common';

/**
 * Empresas, vagas coletadas e compatibilidade (companies, jobs, job_matches)
 *
 * Estrutura do módulo:
 * - controllers/  rotas HTTP
 * - services/     regras de negócio e acesso ao Prisma
 * - models/       DTOs de entrada e tipos das respostas
 */
@Module({
  controllers: [],
  providers: [],
})
export class JobsModule {}
