import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { handleStorageApi, StorageApiDeps } from "./handler.ts";
import type { User } from "npm:@supabase/supabase-js@2";

const mockUser: User = {
    id: "user-001",
    email: "test@example.com",
    app_metadata: {},
    user_metadata: {},
    aud: "authenticated",
    created_at: "2026-01-01T00:00:00Z",
} as User;

function makeDeps(overrides: Partial<StorageApiDeps> = {}): StorageApiDeps {
    return {
        getUserByToken: async () => ({ user: mockUser, error: null }),
        uploadFile: async () => ({
            url: "https://example.supabase.co/storage/v1/object/public/designs/flat/test.png",
            path: "flat/test.png",
            error: null,
        }),
        getSignedUrl: async () => ({
            url: "https://example.supabase.co/storage/v1/object/sign/designs/flat/test.png?token=xxx",
            expiresAt: "2026-04-05T12:00:00Z",
            error: null,
        }),
        ...overrides,
    };
}

function authHeader() {
    return { Authorization: "Bearer test-token" };
}

Deno.test("OPTIONS preflight returns ok", async () => {
    const req = new Request("http://localhost/upload", { method: "OPTIONS" });
    const res = await handleStorageApi(req, makeDeps());
    assertEquals(res.status, 200);
});

Deno.test("POST /upload without auth returns 401", async () => {
    const req = new Request("http://localhost/upload", { method: "POST" });
    const res = await handleStorageApi(req, makeDeps());
    assertEquals(res.status, 401);
});

Deno.test("POST /upload with non-multipart returns 400", async () => {
    const req = new Request("http://localhost/upload", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({}),
    });
    const res = await handleStorageApi(req, makeDeps());
    assertEquals(res.status, 400);
});

Deno.test("POST /upload success returns 201", async () => {
    const formData = new FormData();
    const blob = new Blob(["fake image data"], { type: "image/png" });
    formData.append("file", blob, "test.png");
    formData.append("folder", "flat");

    const req = new Request("http://localhost/upload", {
        method: "POST",
        headers: authHeader(),
        body: formData,
    });
    const res = await handleStorageApi(req, makeDeps());
    assertEquals(res.status, 201);
    const body = await res.json();
    assertEquals(typeof body.url, "string");
    assertEquals(typeof body.path, "string");
});

Deno.test("GET /download without path returns 400", async () => {
    const req = new Request("http://localhost/download", {
        method: "GET",
        headers: authHeader(),
    });
    const res = await handleStorageApi(req, makeDeps());
    assertEquals(res.status, 400);
});

Deno.test("GET /download success returns signed URL", async () => {
    const req = new Request("http://localhost/download?path=flat/test.png", {
        method: "GET",
        headers: authHeader(),
    });
    const res = await handleStorageApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(typeof body.url, "string");
    assertEquals(typeof body.expires_at, "string");
});
