import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { handleFlatDesignApi, FlatDesignApiDeps } from "./handler.ts";
import type { User } from "npm:@supabase/supabase-js@2";

const mockUser: User = {
    id: "user-001",
    email: "test@example.com",
    app_metadata: {},
    user_metadata: {},
    aud: "authenticated",
    created_at: "2026-01-01T00:00:00Z",
} as User;

const mockDesign = {
    id: "design-001",
    user_id: "user-001",
    silhouette_id: "10000000-0000-0000-0000-000000000001",
    pattern_id: "20000000-0000-0000-0000-000000000001",
    material_id: "30000000-0000-0000-0000-000000000001",
    style_id: "40000000-0000-0000-0000-000000000001",
    audience_id: "50000000-0000-0000-0000-000000000001",
    ai_model_id: "60000000-0000-0000-0000-000000000001",
    params: {},
    image_url: null,
    status: "pending",
    error_msg: null,
    regen_count: 0,
    is_saved: true,
    created_at: "2026-04-05T00:00:00Z",
    updated_at: "2026-04-05T00:00:00Z",
};

function makeDeps(overrides: Partial<FlatDesignApiDeps> = {}): FlatDesignApiDeps {
    return {
        getUserByToken: async () => ({ user: mockUser, error: null }),
        createDesign: async () => ({ data: mockDesign, error: null }),
        createRandomDesign: async () => ({ data: mockDesign, error: null }),
        regenerate: async () => ({ data: { ...mockDesign, regen_count: 1 }, error: null }),
        listDesigns: async () => ({ data: [mockDesign], total: 1, error: null }),
        listHistory: async () => ({ data: [mockDesign], total: 1, error: null }),
        getDesign: async () => ({ data: mockDesign, error: null }),
        removeDesign: async () => ({ error: null }),
        saveDesign: async () => ({ error: null }),
        batchRemove: async () => ({ count: 3, error: null }),
        batchSave: async () => ({ count: 3, error: null }),
        ...overrides,
    };
}

function authHeader() {
    return { Authorization: "Bearer test-token" };
}

Deno.test("OPTIONS preflight returns ok", async () => {
    const req = new Request("http://localhost/generate", { method: "OPTIONS" });
    const res = await handleFlatDesignApi(req, makeDeps());
    assertEquals(res.status, 200);
});

Deno.test("POST /generate without auth returns 401", async () => {
    const req = new Request("http://localhost/generate", { method: "POST" });
    const res = await handleFlatDesignApi(req, makeDeps());
    assertEquals(res.status, 401);
});

Deno.test("POST /generate with missing fields returns 400", async () => {
    const req = new Request("http://localhost/generate", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({ silhouette_id: "xxx" }),
    });
    const res = await handleFlatDesignApi(req, makeDeps());
    assertEquals(res.status, 400);
});

Deno.test("POST /generate success returns 201", async () => {
    const req = new Request("http://localhost/generate", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({
            silhouette_id: "s1",
            pattern_id: "p1",
            material_id: "m1",
            style_id: "st1",
            audience_id: "a1",
            ai_model_id: "ai1",
            params: {},
        }),
    });
    const res = await handleFlatDesignApi(req, makeDeps());
    assertEquals(res.status, 201);
});

Deno.test("POST /regenerate blocks when regen_count >= 2", async () => {
    const deps = makeDeps({
        getDesign: async () => ({ data: { ...mockDesign, regen_count: 2 }, error: null }),
    });
    const req = new Request("http://localhost/regenerate", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({ design_id: "design-001" }),
    });
    const res = await handleFlatDesignApi(req, deps);
    assertEquals(res.status, 422);
});

Deno.test("GET /list returns paginated results", async () => {
    const req = new Request("http://localhost/list?page=1&page_size=10", {
        method: "GET",
        headers: authHeader(),
    });
    const res = await handleFlatDesignApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.total, 1);
});


Deno.test("POST /generate-random success returns 201", async () => {
    const req = new Request("http://localhost/generate-random", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({}),
    });
    const res = await handleFlatDesignApi(req, makeDeps());
    assertEquals(res.status, 201);
});

Deno.test("GET /history returns all records", async () => {
    const req = new Request("http://localhost/history?page=1&page_size=10", {
        method: "GET",
        headers: authHeader(),
    });
    const res = await handleFlatDesignApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.total, 1);
});

Deno.test("POST /save saves design to warehouse", async () => {
    const req = new Request("http://localhost/save", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({ design_id: "design-001" }),
    });
    const res = await handleFlatDesignApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.message, "Saved to warehouse");
});

Deno.test("GET /status returns generation status", async () => {
    const req = new Request("http://localhost/status?design_id=design-001", {
        method: "GET",
        headers: authHeader(),
    });
    const res = await handleFlatDesignApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.design_id, "design-001");
    assertEquals(body.status, "pending");
});

Deno.test("POST /batch-remove removes multiple designs", async () => {
    const req = new Request("http://localhost/batch-remove", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({ design_ids: ["d1", "d2", "d3"] }),
    });
    const res = await handleFlatDesignApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.count, 3);
});

Deno.test("POST /batch-save saves multiple designs", async () => {
    const req = new Request("http://localhost/batch-save", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({ design_ids: ["d1", "d2", "d3"] }),
    });
    const res = await handleFlatDesignApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.count, 3);
});
