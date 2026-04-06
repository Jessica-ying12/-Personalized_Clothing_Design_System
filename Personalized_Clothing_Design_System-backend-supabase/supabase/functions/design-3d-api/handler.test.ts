import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { handleDesign3dApi, Design3dApiDeps } from "./handler.ts";
import type { User } from "npm:@supabase/supabase-js@2";

const mockUser: User = {
    id: "user-001",
    email: "test@example.com",
    app_metadata: {},
    user_metadata: {},
    aud: "authenticated",
    created_at: "2026-01-01T00:00:00Z",
} as User;

const mockDesign3d = {
    id: "3d-001",
    user_id: "user-001",
    flat_design_id: "flat-001",
    body_shape_id: "70000000-0000-0000-0000-000000000001",
    skin_color_id: "80000000-0000-0000-0000-000000000001",
    gender_id: "90000000-0000-0000-0000-000000000001",
    ai_model_id: "60000000-0000-0000-0000-000000000001",
    background_id: null,
    image_url: null,
    status: "pending",
    error_msg: null,
    regen_count: 0,
    is_saved: true,
    created_at: "2026-04-05T00:00:00Z",
    updated_at: "2026-04-05T00:00:00Z",
};

function makeDeps(overrides: Partial<Design3dApiDeps> = {}): Design3dApiDeps {
    return {
        getUserByToken: async () => ({ user: mockUser, error: null }),
        createDesign3d: async () => ({ data: mockDesign3d, error: null }),
        regenerate: async () => ({ data: { ...mockDesign3d, regen_count: 1 }, error: null }),
        changeBackground: async () => ({ data: { ...mockDesign3d, background_id: "bg-001" }, error: null }),
        listDesigns3d: async () => ({ data: [mockDesign3d], total: 1, error: null }),
        listHistory: async () => ({ data: [mockDesign3d, { ...mockDesign3d, is_saved: false }], total: 2, error: null }),
        getDesign3d: async () => ({ data: mockDesign3d, error: null }),
        removeDesign3d: async () => ({ error: null }),
        saveDesign3d: async () => ({ error: null }),
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
    const res = await handleDesign3dApi(req, makeDeps());
    assertEquals(res.status, 200);
});

Deno.test("POST /generate without auth returns 401", async () => {
    const req = new Request("http://localhost/generate", { method: "POST" });
    const res = await handleDesign3dApi(req, makeDeps());
    assertEquals(res.status, 401);
});

Deno.test("POST /generate with missing fields returns 400", async () => {
    const req = new Request("http://localhost/generate", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({ flat_design_id: "flat-001" }),
    });
    const res = await handleDesign3dApi(req, makeDeps());
    assertEquals(res.status, 400);
});

Deno.test("POST /generate success returns 201", async () => {
    const req = new Request("http://localhost/generate", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({
            flat_design_id: "flat-001",
            body_shape_id: "bs1",
            skin_color_id: "sc1",
            gender_id: "g1",
            ai_model_id: "ai1",
        }),
    });
    const res = await handleDesign3dApi(req, makeDeps());
    assertEquals(res.status, 201);
});

Deno.test("POST /regenerate blocks when regen_count >= 1", async () => {
    const deps = makeDeps({
        getDesign3d: async () => ({ data: { ...mockDesign3d, regen_count: 1 }, error: null }),
    });
    const req = new Request("http://localhost/regenerate", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({ design_id: "3d-001" }),
    });
    const res = await handleDesign3dApi(req, deps);
    assertEquals(res.status, 422);
});

Deno.test("POST /background changes background", async () => {
    const req = new Request("http://localhost/background", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({ design_id: "3d-001", background_id: "bg-001" }),
    });
    const res = await handleDesign3dApi(req, makeDeps());
    assertEquals(res.status, 200);
});

Deno.test("GET /list returns paginated results", async () => {
    const req = new Request("http://localhost/list", {
        method: "GET",
        headers: authHeader(),
    });
    const res = await handleDesign3dApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.total, 1);
});

Deno.test("GET /history returns all records including deleted", async () => {
    const req = new Request("http://localhost/history", {
        method: "GET",
        headers: authHeader(),
    });
    const res = await handleDesign3dApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.total, 2);
});

Deno.test("POST /save saves design to warehouse", async () => {
    const req = new Request("http://localhost/save", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({ design_id: "3d-001" }),
    });
    const res = await handleDesign3dApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.message, "Saved to warehouse");
});

Deno.test("GET /status returns generation status", async () => {
    const req = new Request("http://localhost/status?design_id=3d-001", {
        method: "GET",
        headers: authHeader(),
    });
    const res = await handleDesign3dApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.design_id, "3d-001");
    assertEquals(body.status, "pending");
});

Deno.test("POST /batch-remove removes multiple designs", async () => {
    const req = new Request("http://localhost/batch-remove", {
        method: "POST",
        headers: { ...authHeader(), "Content-Type": "application/json" },
        body: JSON.stringify({ design_ids: ["d1", "d2", "d3"] }),
    });
    const res = await handleDesign3dApi(req, makeDeps());
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
    const res = await handleDesign3dApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.count, 3);
});
