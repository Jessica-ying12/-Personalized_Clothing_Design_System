import { assertEquals } from "jsr:@std/assert@1";
import { AuthApiDeps, handleAuthApi } from "./handler.ts";

function createDeps(overrides?: Partial<AuthApiDeps>): AuthApiDeps {
  return {
    signUp: async () => ({ user: { id: "u1", email: "u@test.com" } as never, session: { token: "s1" }, error: null }),
    signIn: async () => ({ user: { id: "u1", email: "u@test.com" } as never, session: { token: "s1" }, error: null }),
    getUserByToken: async () => ({ user: { id: "u1", email: "u@test.com" } as never, error: null }),
    getProfileByUserId: async () => ({
      profile: {
        id: "u1",
        full_name: "User",
        avatar_url: null,
        created_at: "2026-01-01T00:00:00.000Z",
        updated_at: "2026-01-01T00:00:00.000Z",
      },
      error: null,
    }),
    ...overrides,
  };
}

Deno.test("register returns 400 when email missing", async () => {
  const req = new Request("http://localhost/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ password: "secret" }),
  });

  const res = await handleAuthApi(req, createDeps());
  const body = await res.json();

  assertEquals(res.status, 400);
  assertEquals(body.error, "email and password are required");
});

Deno.test("register returns success body", async () => {
  const req = new Request("http://localhost/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: "u@test.com", password: "secret", full_name: "User" }),
  });

  const res = await handleAuthApi(req, createDeps());
  const body = await res.json();

  assertEquals(res.status, 200);
  assertEquals(body.message, "registered");
});

Deno.test("login returns 401 when service rejects", async () => {
  const req = new Request("http://localhost/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: "u@test.com", password: "wrong" }),
  });

  const deps = createDeps({
    signIn: async () => ({ user: null, session: null, error: "invalid credentials" }),
  });
  const res = await handleAuthApi(req, deps);
  const body = await res.json();

  assertEquals(res.status, 401);
  assertEquals(body.error, "Login failed");
});

Deno.test("me returns 401 when authorization missing", async () => {
  const req = new Request("http://localhost/me", { method: "GET" });
  const res = await handleAuthApi(req, createDeps());
  const body = await res.json();

  assertEquals(res.status, 401);
  assertEquals(body.error, "Missing or invalid Authorization header");
});

Deno.test("me returns profile payload", async () => {
  const req = new Request("http://localhost/me", {
    method: "GET",
    headers: { Authorization: "Bearer token1" },
  });
  const res = await handleAuthApi(req, createDeps());
  const body = await res.json();

  assertEquals(res.status, 200);
  assertEquals(body.user.id, "u1");
  assertEquals(body.profile.full_name, "User");
});
