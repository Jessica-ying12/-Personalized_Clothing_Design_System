import { createClient } from "npm:@supabase/supabase-js@2";
import type { Database } from "../../../types/supabase/index.ts";

type DesignOptionRow = Database["public"]["Tables"]["design_options"]["Row"];

export type DesignOptionsApiDeps = {
    listOptions: (category?: string) => Promise<{ data: DesignOptionRow[] | null; error: string | null }>;
    listChildren: (parentId: string) => Promise<{ data: DesignOptionRow[] | null; error: string | null }>;
};

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
};

function jsonResponse(body: Record<string, unknown>, status = 200): Response {
    return new Response(JSON.stringify(body), {
        status,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
}

export async function handleDesignOptionsApi(
    req: Request,
    deps: DesignOptionsApiDeps,
): Promise<Response> {
    if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
    if (req.method !== "GET") return jsonResponse({ error: "Method Not Allowed" }, 405);

    const url = new URL(req.url);
    const { pathname } = url;

    // GET /options?category=silhouette  — 获取某分类的一级选项
    if (pathname.endsWith("/options")) {
        const category = url.searchParams.get("category") ?? undefined;
        const result = await deps.listOptions(category);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data ?? [] });
    }

    // GET /options/children?parent_id=xxx  — 获取某选项的子选项
    if (pathname.endsWith("/options/children")) {
        const parentId = url.searchParams.get("parent_id");
        if (!parentId) return jsonResponse({ error: "parent_id is required" }, 400);
        const result = await deps.listChildren(parentId);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data ?? [] });
    }

    return jsonResponse({ error: "Unknown endpoint", supported: ["/options", "/options/children"] }, 404);
}

export function createRuntimeDeps(): DesignOptionsApiDeps {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const client = createClient<Database>(supabaseUrl, supabaseAnonKey);

    return {
        async listOptions(category) {
            let query = client
                .from("design_options")
                .select("*")
                .eq("is_active", true)
                .is("parent_id", null)
                .order("sort_order");
            if (category) query = query.eq("category", category);
            const { data, error } = await query;
            return { data, error: error?.message ?? null };
        },
        async listChildren(parentId) {
            const { data, error } = await client
                .from("design_options")
                .select("*")
                .eq("parent_id", parentId)
                .eq("is_active", true)
                .order("sort_order");
            return { data, error: error?.message ?? null };
        },
    };
}
