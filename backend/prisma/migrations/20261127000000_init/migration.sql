-- Extensão pgvector (embeddings de currículo e vagas)
CREATE EXTENSION IF NOT EXISTS "vector";

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "seniority" AS ENUM ('INTERNSHIP', 'JUNIOR', 'MID', 'SENIOR');

-- CreateEnum
CREATE TYPE "work_model" AS ENUM ('REMOTE', 'HYBRID', 'ONSITE');

-- CreateEnum
CREATE TYPE "job_source" AS ENUM ('GUPY', 'GREENHOUSE', 'LEVER', 'ASHBY', 'MANUAL');

-- CreateEnum
CREATE TYPE "match_status" AS ENUM ('NEW', 'SAVED', 'DISMISSED', 'APPLIED');

-- CreateEnum
CREATE TYPE "application_stage" AS ENUM ('APPLIED', 'SCREENING', 'INTERVIEW', 'OFFER', 'CLOSED');

-- CreateEnum
CREATE TYPE "application_outcome" AS ENUM ('HIRED', 'REJECTED', 'WITHDREW', 'NO_RESPONSE');

-- CreateEnum
CREATE TYPE "application_event_type" AS ENUM ('STAGE_CHANGE', 'DEADLINE', 'INTERVIEW', 'NOTE');

-- CreateEnum
CREATE TYPE "event_author" AS ENUM ('USER', 'AI');

-- CreateEnum
CREATE TYPE "email_classification" AS ENUM ('RECRUITING', 'NOT_RECRUITING', 'NEEDS_REVIEW');

-- CreateEnum
CREATE TYPE "email_review_status" AS ENUM ('PENDING', 'CONFIRMED', 'CORRECTED', 'IGNORED');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "inbound_alias" TEXT NOT NULL,
    "timezone" TEXT NOT NULL DEFAULT 'America/Sao_Paulo',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "search_profiles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "titles" TEXT[],
    "seniorities" "seniority"[],
    "work_models" "work_model"[],
    "locations" TEXT[],
    "stack" TEXT[],
    "sources" "job_source"[],
    "resume_text" TEXT,
    "resume_embedding" vector(1536),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "search_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "companies" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "domain" TEXT,
    "ats" "job_source",
    "ats_slug" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "companies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "jobs" (
    "id" UUID NOT NULL,
    "source" "job_source" NOT NULL,
    "external_id" TEXT NOT NULL,
    "company_id" UUID,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "location" TEXT,
    "work_model" "work_model",
    "contract_type" TEXT,
    "url" TEXT NOT NULL,
    "published_at" TIMESTAMP(3),
    "collected_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closed_at" TIMESTAMP(3),
    "embedding" vector(1536),

    CONSTRAINT "jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "job_matches" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "job_id" UUID NOT NULL,
    "score" DOUBLE PRECISION NOT NULL,
    "status" "match_status" NOT NULL DEFAULT 'NEW',
    "seen_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "job_matches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "applications" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "company_id" UUID,
    "job_id" UUID,
    "job_title" TEXT NOT NULL,
    "company_name" TEXT NOT NULL,
    "url" TEXT,
    "source" "job_source" NOT NULL DEFAULT 'MANUAL',
    "stage" "application_stage" NOT NULL DEFAULT 'APPLIED',
    "outcome" "application_outcome",
    "applied_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_activity_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "applications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "application_events" (
    "id" UUID NOT NULL,
    "application_id" UUID NOT NULL,
    "type" "application_event_type" NOT NULL,
    "stage_from" "application_stage",
    "stage_to" "application_stage",
    "description" TEXT,
    "due_at" TIMESTAMP(3),
    "scheduled_at" TIMESTAMP(3),
    "email_id" UUID,
    "created_by" "event_author" NOT NULL DEFAULT 'USER',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "application_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "emails" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "message_id" TEXT NOT NULL,
    "from_address" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "received_at" TIMESTAMP(3) NOT NULL,
    "body_text" TEXT,
    "classification" "email_classification" NOT NULL DEFAULT 'NEEDS_REVIEW',
    "confidence" DOUBLE PRECISION,
    "extracted" JSONB,
    "application_id" UUID,
    "review_status" "email_review_status" NOT NULL DEFAULT 'PENDING',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "emails_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_inbound_alias_key" ON "users"("inbound_alias");

-- CreateIndex
CREATE UNIQUE INDEX "search_profiles_user_id_key" ON "search_profiles"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "companies_domain_key" ON "companies"("domain");

-- CreateIndex
CREATE UNIQUE INDEX "companies_ats_ats_slug_key" ON "companies"("ats", "ats_slug");

-- CreateIndex
CREATE INDEX "jobs_published_at_idx" ON "jobs"("published_at");

-- CreateIndex
CREATE UNIQUE INDEX "jobs_source_external_id_key" ON "jobs"("source", "external_id");

-- CreateIndex
CREATE INDEX "job_matches_user_id_status_score_idx" ON "job_matches"("user_id", "status", "score");

-- CreateIndex
CREATE UNIQUE INDEX "job_matches_user_id_job_id_key" ON "job_matches"("user_id", "job_id");

-- CreateIndex
CREATE INDEX "applications_user_id_stage_idx" ON "applications"("user_id", "stage");

-- CreateIndex
CREATE INDEX "application_events_application_id_created_at_idx" ON "application_events"("application_id", "created_at");

-- CreateIndex
CREATE INDEX "application_events_due_at_idx" ON "application_events"("due_at");

-- CreateIndex
CREATE INDEX "application_events_scheduled_at_idx" ON "application_events"("scheduled_at");

-- CreateIndex
CREATE UNIQUE INDEX "emails_message_id_key" ON "emails"("message_id");

-- CreateIndex
CREATE INDEX "emails_user_id_review_status_idx" ON "emails"("user_id", "review_status");

-- CreateIndex
CREATE INDEX "emails_user_id_received_at_idx" ON "emails"("user_id", "received_at");

-- AddForeignKey
ALTER TABLE "search_profiles" ADD CONSTRAINT "search_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "jobs" ADD CONSTRAINT "jobs_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "job_matches" ADD CONSTRAINT "job_matches_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "job_matches" ADD CONSTRAINT "job_matches_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "jobs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "applications" ADD CONSTRAINT "applications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "applications" ADD CONSTRAINT "applications_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "applications" ADD CONSTRAINT "applications_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "jobs"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "application_events" ADD CONSTRAINT "application_events_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "applications"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "application_events" ADD CONSTRAINT "application_events_email_id_fkey" FOREIGN KEY ("email_id") REFERENCES "emails"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "emails" ADD CONSTRAINT "emails_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "emails" ADD CONSTRAINT "emails_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "applications"("id") ON DELETE SET NULL ON UPDATE CASCADE;
