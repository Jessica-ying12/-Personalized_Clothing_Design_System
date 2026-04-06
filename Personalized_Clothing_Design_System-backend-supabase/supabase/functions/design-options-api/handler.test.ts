import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { handleDesignOptionsApi, DesignOptionsApiDeps } from "./handler.ts";

const mockOption = {
    id: "10000000-0000-0000-0000-000000000001",
    category: "silhouette",
    parent_id: null,
    name: "上衣",
    name_en: "Top",
    sort_order: 1,
    meta: null,
    is_active: true,
    created_at: "2026-04-05T00:00:00Z",
};

function makeDeps(overrides: Partial<DesignOptionsApiDeps> = {}): DesignOptionsApiDeps {
    return {
        listOptions: async () => ({ data: [mockOption], error: null }),
        listChildren: async () => ({ data: [], error: null }),
        ...overrides,
    };
}

Deno.test("OPTIONS preflight returns ok", async () => {
    const req = new Request("http://localhost/options", { method: "OPTIONS" });
    const res = await handleDesignOptionsApi(req, makeDeps());
    assertEquals(res.status, 200);
});

Deno.test("GET /options returns list", async () => {
    const req = new Request("http://localhost/options", { method: "GET" });
    const res = await handleDesignOptionsApi(req, makeDeps());
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.data.length, 1);
    assertEquals(body.data[0].name, "上衣");
});

Deno.test("GET /options?category=silhouette filters by category", async () => {
    let capturedCategory: string | undefined;
    const deps = makeDeps({
        listOptions: async (category) => {
            capturedCategory = category;
            return { data: [mockOption], error: null };
        },
    });
    const req = new Request("http://localhost/options?category=silhouette", { method: "GET" });
    await handleDesignOptionsApi(req, deps);
    assertEquals(capturedCategory, "silhouette");
});

Deno.test("GET /options/children requires parent_id", async () => {
    const req = new Request("http://localhost/options/children", { method: "GET" });
    const res = await handleDesignOptionsApi(req, makeDeps());
    assertEquals(res.status, 400);
});

Deno.test("GET /options/children returns children", async () => {
    const child = { ...mockOption, id: "child-id", parent_id: mockOption.id };
    const deps = makeDeps({ listChildren: async () => ({ data: [child], error: null }) });
    const req = new Request(`http://localhost/options/children?parent_id=${mockOption.id}`, { method: "GET" });
    const res = await handleDesignOptionsApi(req, deps);
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.data.length, 1);
});

Deno.test("unknown endpoint returns 404", async () => {
    const req = new Request("http://localhost/unknown", { method: "GET" });
    const res = await handleDesignOptionsApi(req, makeDeps());
    assertEquals(res.status, 404);
});
