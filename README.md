# Vaga Hunter

Busca vagas de desenvolvimento em várias plataformas (Gupy, Greenhouse, Lever…) e acompanha cada processo seletivo a partir dos e-mails recebidos.

## Stack

| Camada | Tecnologia |
| --- | --- |
| Frontend | Next.js (App Router) + Tailwind CSS |
| Backend | Nest.js — monólito modular (API REST, sem views) |
| ORM | Prisma 7 (driver adapter `@prisma/adapter-pg`) |
| Banco | PostgreSQL 17 + pgvector |
| E-mail (dev) | Mailpit |
| Infra | Docker Compose |

## Subindo o ambiente

```bash
cp .env.example .env      # opcional: tudo tem valor padrão
docker compose up --build
```

| Serviço | Endereço |
| --- | --- |
| Frontend | http://localhost:3000 |
| API | http://localhost:3333/api |
| Health check | http://localhost:3333/api/health |
| Mailpit (caixa de teste) | http://localhost:8025 |
| SMTP do Mailpit | `localhost:1025` (`mailpit:1025` dentro do Docker) |
| Postgres | `localhost:5432` — usuário/senha/banco `vagahunter` |

Na subida, o backend roda `prisma generate` e `prisma migrate deploy`, então as tabelas são criadas sozinhas.

## Estrutura

```
vaga-hunter/
├── docker-compose.yml
├── docker/postgres/init/        # instala o pgvector na 1ª subida do banco
├── frontend/                    # Next.js
│   └── src/
│       ├── app/                 # rotas (App Router)
│       ├── components/
│       └── lib/api.ts           # cliente HTTP da API
└── backend/                     # Nest.js
    ├── prisma/
    │   ├── schema.prisma        # modelo de dados
    │   └── migrations/
    ├── prisma.config.ts
    └── src/
        ├── main.ts
        ├── app.module.ts
        ├── shared/database/     # PrismaService (módulo global)
        └── modules/
            ├── health/          # módulo de exemplo, completo
            ├── users/           # users, search_profiles
            ├── jobs/            # companies, jobs, job_matches
            ├── applications/    # applications, application_events
            └── emails/          # emails
```

Cada módulo segue o mesmo padrão:

```
modules/<modulo>/
├── <modulo>.module.ts
├── controllers/   # rotas HTTP: recebem a requisição e devolvem o JSON
├── services/      # regras de negócio e acesso ao Prisma
└── models/        # DTOs de entrada (class-validator) e tipos das respostas
```

Como o frontend é separado, não há camada de views: o formato da resposta é definido pelos tipos em `models/`. O módulo `health` é a referência: `HealthController` → `HealthService`.

## Banco de dados

Tabelas: `users`, `sessions`, `password_reset_codes`, `search_profiles`, `companies`, `jobs`, `job_matches`, `applications`, `application_events`, `emails`.

- As colunas de embedding (`search_profiles.resume_embedding`, `jobs.embedding`) são `vector(1536)` do pgvector. O Prisma não lê/escreve esse tipo diretamente; use `$queryRaw` / `$executeRaw`.
- `sessions` guarda uma linha por login com o hash do refresh token (rotação com `replaced_by_id`); `password_reset_codes` registra cada envio de código de redefinição de senha (só o hash do código, com expiração e contador de tentativas).
- O Prisma Client é gerado em `backend/src/generated/prisma` (fora do Git).

Comandos úteis (dentro do container):

```bash
docker compose exec backend npm run prisma:migrate -- --name minha_mudanca   # nova migration
docker compose exec backend npm run prisma:studio                            # Prisma Studio
docker compose exec backend npm test                                         # testes
```

## Rodando sem Docker

Suba só o banco e o Mailpit (`docker compose up postgres mailpit`), depois:

```bash
cd backend  && cp .env.example .env && npm install && npx prisma generate && npx prisma migrate deploy && npm run start:dev
cd frontend && npm install && npm run dev
```

> Use npm 11 ou superior (vem com o Node 24). O npm 10 tem um bug que quebra o `npm install` do backend.
