import { api } from "@/lib/api";

type Health = {
  status: "ok" | "degraded";
  services: { api: "up" | "down"; database: "up" | "down" };
};

function Dot({ up }: { up: boolean }) {
  return (
    <span
      aria-hidden="true"
      className={`inline-block h-2.5 w-2.5 rounded-full ${up ? "bg-green-600" : "bg-orange-600"}`}
    />
  );
}

export async function ApiStatus() {
  let health: Health | null = null;
  try {
    health = await api<Health>("/health");
  } catch {
    health = null;
  }

  const apiUp = health?.services.api === "up";
  const dbUp = health?.services.database === "up";

  return (
    <ul className="flex flex-col gap-2 text-sm">
      <li className="flex items-center gap-2">
        <Dot up={apiUp} /> API (Nest.js): {apiUp ? "online" : "fora do ar"}
      </li>
      <li className="flex items-center gap-2">
        <Dot up={dbUp} /> Banco (Postgres): {dbUp ? "online" : "fora do ar"}
      </li>
    </ul>
  );
}
