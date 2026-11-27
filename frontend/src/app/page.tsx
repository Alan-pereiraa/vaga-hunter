import { Suspense } from "react";
import { ApiStatus } from "@/components/api-status";

export default function Home() {
  return (
    <main className="mx-auto flex w-full max-w-2xl flex-1 flex-col justify-center gap-8 px-6 py-16">
      <div>
        <h1 className="font-display text-4xl font-semibold">
          vaga<span className="text-indigo-600">.hunter</span>
        </h1>
        <p className="mt-3 text-gray-600">
          Busque vagas de desenvolvimento em várias plataformas e acompanhe cada processo
          seletivo a partir dos seus e-mails.
        </p>
      </div>

      <section className="rounded-xl border border-gray-200 bg-white p-6">
        <h2 className="mb-4 font-display text-lg font-semibold">Ambiente de desenvolvimento</h2>
        <Suspense fallback={<p className="text-sm text-gray-600">Verificando serviços…</p>}>
          <ApiStatus />
        </Suspense>
        <p className="mt-4 text-sm text-gray-600">
          E-mails de teste:{" "}
          <a className="text-indigo-700 underline" href="http://localhost:8025">
            Mailpit em localhost:8025
          </a>
        </p>
      </section>
    </main>
  );
}
