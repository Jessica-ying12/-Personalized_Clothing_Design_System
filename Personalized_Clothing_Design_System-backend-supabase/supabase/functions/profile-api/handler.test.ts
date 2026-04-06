import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { handleProfileApi, ProfileApiDeps } from "./handler.ts";
import type { User } from "npm:@supabase/supabase-js@2";

const mockUser: User = {
    id: "user-001",
    email: "test@example.com",
    app_metadata: {},
    user_metadata: {},
    aud: "authenticated",
    created_at: "2026-01-01T00:00:00Z",
} as User;

const mockProfile = {
    id: "user-001",
    full_name: "Test User",
    avatar_url: null,
    created_at: "2026-01-01T00:00:00Z",
    updated_at: "2026-04-05T00:00:00Z",
};

function makeDeps(overrides: Partial<ProfileApiDeps> = {}): ProfileApiDeps {
    return {
        getUserByToken: async () => ({ user: mockUser, error: null }),
        updateProfile: async () => ({ data: mockProfile, error: null }),
        deleteAccount: async () => ({ error: null }),
        getStats: async () => ({
            data: { flat_total: 10, flat_saved: 8, design_3d_total: 5, design_3d_saved: 4 },
            error: null,
        }),
        ...overrides,
    };
}

function authHeader() {
    return { Authorization: "Bearer test-token" };
}

Deno.test("OPTIONS preflight returns ok", async () => {
    const req = new Request("http://localhost/update", { method: "OPTIONS" });
    const res = await handleProfileApi(req, makeDeps());
    assertEquals(res.status, 200);
});

Deno.test("POST /update without auth returns 401", async () => {
    const req = new Request("http://localhost/update", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ full_name: "New Name" }),
    });
    const res = await handleProfileApi(req, makeDeps());
    assertEquals(res.status, 401);
});

Deno.test("POST /update with empty body returns 400", async () => {
    const req = new Request("http://localhost/update", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({}),
    });
    const res = await handleProfileApi(req, makeDeps());
    assertEquals(res.status, 400);
});

Deno.test("POST /update success returns updated profile", async () => {
    const req = new Request("http://localhost/update", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({ full_name: "New Name" }),
    });
    const res = await handleProfileApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.data.full_name, "Test User");
});

Deno.test("DELETE /account without auth returns 401", async () => {
    const req = new Request("http://localhost/account", { method: "DELETE" });
    const res = await handleProfileApi(req, makeDeps());
    assertEquals(res.status, 401);
});

Deno.test("DELETE /account success returns message", async () => {
    const req = new Request("http://localhost/account", {
        method: "DELETE",
        headers: authHeader(),
    });
    const res = await handleProfileApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.message, "Account deleted successfully");
});

Deno.test("GET /stats returns statistics", async () => {
    const req = new Request("http://localhost/stats", {
        method: "GET",
        headers: authHeader(),
    });
    const res = await handleProfileApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.data.flat_total, 10);
    assertEquals(body.data.flat_saved, 8);
    assertEquals(body.data.design_3d_total, 5);
    assertEquals(body.data.design_3d_saved, 4);
});
