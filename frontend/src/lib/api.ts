/**
 * URL base da API.
 * - No servidor (Server Components) dentro do Docker usamos o nome do serviço: http://backend:3333/api
 * - No navegador usamos a porta exposta no host: http://localhost:3333/api
 */
export const API_URL =
  typeof window === "undefined"
    ? (process.env.API_URL ?? process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3333/api")
    : (process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3333/api");

export async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${API_URL}${path}`, {
    ...init,
    headers: { "Content-Type": "application/json", ...init?.headers },
  });
  if (!res.ok) {
    throw new Error(`API ${res.status} em ${path}`);
  }
  return res.json() as Promise<T>;
}
