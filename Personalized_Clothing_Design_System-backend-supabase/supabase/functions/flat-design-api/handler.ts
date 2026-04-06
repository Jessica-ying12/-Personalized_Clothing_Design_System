import { createClient, SupabaseClient, User } from "npm:@supabase/supabase-js@2";
import type { Database } from "../../../types/supabase/index.ts";

type FlatDesignRow = Database["public"]["Tables"]["flat_designs"]["Row"];
type JsonRecord = Record<string, unknown>;

const MAX_REGEN = 2;

export type FlatDesignApiDeps = {
    getUserByToken: (token: string) => Promise<{ user: User | null; error: string | null }>;
    createDesign: (
        userId: string,
        input: FlatDesignInput,
    ) => Promise<{ data: FlatDesignRow | null; error: string | null }>;
    createRandomDesign: (
        userId: string,
    ) => Promise<{ data: FlatDesignRow | null; error: string | null }>;
    regenerate: (
        userId: string,
        designId: string,
    ) => Promise<{ data: FlatDesignRow | null; error: string | null }>;
    listDesigns: (
        userId: string,
        page: number,
        pageSize: number,
    ) => Promise<{ data: FlatDesignRow[] | null; total: number; error: string | null }>;
    listHistory: (
        userId: string,
        page: number,
        pageSize: number,
    ) => Promise<{ data: FlatDesignRow[] | null; total: number; error: string | null }>;
    getDesign: (
        userId: string,
        designId: string,
    ) => Promise<{ data: FlatDesignRow | null; error: string | null }>;
    removeDesign: (
        userId: string,
        designId: string,
    ) => Promise<{ error: string | null }>;
    saveDesign: (
        userId: string,
        designId: string,
    ) => Promise<{ error: string | null }>;
    batchRemove: (
        userId: string,
        designIds: string[],
    ) => Promise<{ count: number; error: string | null }>;
    batchSave: (
        userId: string,
        designIds: string[],
    ) => Promise<{ count: number; error: string | null }>;
};

export type FlatDesignInput = {
    silhouette_id: string;
    pattern_id: string;
    material_id: string;
    style_id: string;
    audience_id: string;
    ai_model_id: string;
    params: JsonRecord;
    auto_save?: boolean; // 是否自动保存到仓库，默认 true
};

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

function jsonResponse(body: JsonRecord, status = 200): Response {
    return new Response(JSON.stringify(body), {
        status,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
}

async function parseJson(req: Request): Promise<{ data: JsonRecord | null; error: string | null }> {
    try {
        return { data: (await req.json()) as JsonRecord, error: null };
    } catch {
        return { data: null, error: "Invalid JSON payload" };
    }
}

async function getAuthUser(req: Request, deps: FlatDesignApiDeps): Promise<{ user: User | null; error: Response | null }> {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
        return { user: null, error: jsonResponse({ error: "Missing or invalid Authorization header" }, 401) };
    }
    const token = authHeader.slice(7).trim();
    const result = await deps.getUserByToken(token);
    if (result.error || !result.user) {
        return { user: null, error: jsonResponse({ error: "Unauthorized" }, 401) };
    }
    return { user: result.user, error: null };
}

export async function handleFlatDesignApi(req: Request, deps: FlatDesignApiDeps): Promise<Response> {
    if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

    const { pathname } = new URL(req.url);

    // POST /generate — 生成平面图
    if (pathname.endsWith("/generate") && req.method === "POST") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const { data: body, error: parseError } = await parseJson(req);
        if (parseError || !body) return jsonResponse({ error: parseError ?? "Invalid payload" }, 400);

        const required = ["silhouette_id", "pattern_id", "material_id", "style_id", "audience_id", "ai_model_id"];
        for (const field of required) {
            if (typeof body[field] !== "string" || !body[field]) {
                return jsonResponse({ error: `${field} is required` }, 400);
            }
        }

        const input: FlatDesignInput = {
            silhouette_id: body.silhouette_id as string,
            pattern_id: body.pattern_id as string,
            material_id: body.material_id as string,
            style_id: body.style_id as string,
            audience_id: body.audience_id as string,
            ai_model_id: body.ai_model_id as string,
            params: (body.params as JsonRecord) ?? {},
            auto_save: typeof body.auto_save === "boolean" ? body.auto_save : true,
        };

        const result = await deps.createDesign(user!.id, input);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data }, 201);
    }

    // POST /generate-random — 随机生成平面图
    if (pathname.endsWith("/generate-random") && req.method === "POST") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const result = await deps.createRandomDesign(user!.id);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data }, 201);
    }

    // POST /regenerate — 重新生成（最多2次）
    if (pathname.endsWith("/regenerate") && req.method === "POST") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const { data: body, error: parseError } = await parseJson(req);
        if (parseError || !body) return jsonResponse({ error: parseError ?? "Invalid payload" }, 400);

        const designId = typeof body.design_id === "string" ? body.design_id : "";
        if (!designId) return jsonResponse({ error: "design_id is required" }, 400);

        // 检查重生成次数
        const existing = await deps.getDesign(user!.id, designId);
        if (existing.error || !existing.data) return jsonResponse({ error: "Design not found" }, 404);
        if (existing.data.regen_count >= MAX_REGEN) {
            return jsonResponse({ error: `Max regeneration limit (${MAX_REGEN}) reached` }, 422);
        }

        const result = await deps.regenerate(user!.id, designId);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data });
    }

    // GET /list — 获取平面图列表（仓库用）
    if (pathname.endsWith("/list") && req.method === "GET") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const url = new URL(req.url);
        const page = Math.max(1, parseInt(url.searchParams.get("page") ?? "1", 10));
        const pageSize = Math.min(50, Math.max(1, parseInt(url.searchParams.get("page_size") ?? "20", 10)));

        const result = await deps.listDesigns(user!.id, page, pageSize);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data ?? [], total: result.total, page, page_size: pageSize });
    }

    // GET /history — 获取历史记录（包括已删除）
    if (pathname.endsWith("/history") && req.method === "GET") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const url = new URL(req.url);
        const page = Math.max(1, parseInt(url.searchParams.get("page") ?? "1", 10));
        const pageSize = Math.min(50, Math.max(1, parseInt(url.searchParams.get("page_size") ?? "20", 10)));

        const result = await deps.listHistory(user!.id, page, pageSize);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data ?? [], total: result.total, page, page_size: pageSize });
    }

    // GET /status?design_id=xxx — 查询生成状态
    if (pathname.endsWith("/status") && req.method === "GET") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const designId = new URL(req.url).searchParams.get("design_id") ?? "";
        if (!designId) return jsonResponse({ error: "design_id is required" }, 400);

        const result = await deps.getDesign(user!.id, designId);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        if (!result.data) return jsonResponse({ error: "Design not found" }, 404);

        // 只返回状态相关字段
        return jsonResponse({
            design_id: result.data.id,
            status: result.data.status,
            image_url: result.data.image_url,
            error_msg: result.data.error_msg,
            regen_count: result.data.regen_count,
        });
    }

    // GET /detail?design_id=xxx — 获取单条平面图详情
    if (pathname.endsWith("/detail") && req.method === "GET") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const designId = new URL(req.url).searchParams.get("design_id") ?? "";
        if (!designId) return jsonResponse({ error: "design_id is required" }, 400);

        const result = await deps.getDesign(user!.id, designId);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        if (!result.data) return jsonResponse({ error: "Design not found" }, 404);
        return jsonResponse({ data: result.data });
    }

    // DELETE /remove — 从仓库软删除平面图
    if (pathname.endsWith("/remove") && req.method === "DELETE") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const { data: body, error: parseError } = await parseJson(req);
        if (parseError || !body) return jsonResponse({ error: parseError ?? "Invalid payload" }, 400);

        const designId = typeof body.design_id === "string" ? body.design_id : "";
        if (!designId) return jsonResponse({ error: "design_id is required" }, 400);

        const result = await deps.removeDesign(user!.id, designId);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ message: "Removed from warehouse" });
    }

    // POST /save — 保存到仓库
    if (pathname.endsWith("/save") && req.method === "POST") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const { data: body, error: parseError } = await parseJson(req);
        if (parseError || !body) return jsonResponse({ error: parseError ?? "Invalid payload" }, 400);

        const designId = typeof body.design_id === "string" ? body.design_id : "";
        if (!designId) return jsonResponse({ error: "design_id is required" }, 400);

        const result = await deps.saveDesign(user!.id, designId);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ message: "Saved to warehouse" });
    }

    // POST /batch-remove — 批量删除
    if (pathname.endsWith("/batch-remove") && req.method === "POST") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const { data: body, error: parseError } = await parseJson(req);
        if (parseError || !body) return jsonResponse({ error: parseError ?? "Invalid payload" }, 400);

        const designIds = Array.isArray(body.design_ids) ? body.design_ids : [];
        if (designIds.length === 0) return jsonResponse({ error: "design_ids array is required" }, 400);
        if (designIds.length > 100) return jsonResponse({ error: "Maximum 100 items per batch" }, 400);

        const result = await deps.batchRemove(user!.id, designIds);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ message: "Batch removed from warehouse", count: result.count });
    }

    // POST /batch-save — 批量保存
    if (pathname.endsWith("/batch-save") && req.method === "POST") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const { data: body, error: parseError } = await parseJson(req);
        if (parseError || !body) return jsonResponse({ error: parseError ?? "Invalid payload" }, 400);

        const designIds = Array.isArray(body.design_ids) ? body.design_ids : [];
        if (designIds.length === 0) return jsonResponse({ error: "design_ids array is required" }, 400);
        if (designIds.length > 100) return jsonResponse({ error: "Maximum 100 items per batch" }, 400);

        const result = await deps.batchSave(user!.id, designIds);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ message: "Batch saved to warehouse", count: result.count });
    }

    return jsonResponse({ error: "Unknown endpoint", supported: ["/generate", "/generate-random", "/regenerate", "/list", "/history", "/status", "/detail", "/remove", "/save", "/batch-remove", "/batch-save"] }, 404);
}

export function createRuntimeDeps(): FlatDesignApiDeps {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

    const tokenClient = (token: string): SupabaseClient<Database> =>
        createClient<Database>(supabaseUrl, supabaseAnonKey, {
            global: { headers: { Authorization: `Bearer ${token}` } },
        });

    // 从 Authorization header 中提取 token（运行时用）
    let _currentToken = "";

    return {
        async getUserByToken(token) {
            _currentToken = token;
            const client = tokenClient(token);
            const { data: { user }, error } = await client.auth.getUser();
            return { user, error: error?.message ?? null };
        },
        async createDesign(userId, input) {
            const client = tokenClient(_currentToken);
            const { data, error } = await client
                .from("flat_designs")
                .insert({
                    user_id: userId,
                    silhouette_id: input.silhouette_id,
                    pattern_id: input.pattern_id,
                    material_id: input.material_id,
                    style_id: input.style_id,
                    audience_id: input.audience_id,
                    ai_model_id: input.ai_model_id,
                    params: input.params,
                    status: "pending",
                    is_saved: input.auto_save ?? true,
                })
                .select()
                .single();
            return { data, error: error?.message ?? null };
        },
        async createRandomDesign(userId) {
            const client = tokenClient(_currentToken);
            // 从每个 category 随机选一个一级选项
            const categories = ['silhouette', 'pattern', 'material', 'style', 'audience', 'ai_model'];
            const randomIds: Record<string, string> = {};

            for (const cat of categories) {
                const { data } = await client
                    .from('design_options')
                    .select('id')
                    .eq('category', cat)
                    .is('parent_id', null)
                    .eq('is_active', true);
                if (data && data.length > 0) {
                    randomIds[`${cat}_id`] = data[Math.floor(Math.random() * data.length)].id;
                }
            }

            // 插入记录
            const { data, error } = await client
                .from('flat_designs')
                .insert({
                    user_id: userId,
                    silhouette_id: randomIds.silhouette_id ?? null,
                    pattern_id: randomIds.pattern_id ?? null,
                    material_id: randomIds.material_id ?? null,
                    style_id: randomIds.style_id ?? null,
                    audience_id: randomIds.audience_id ?? null,
                    ai_model_id: randomIds.ai_model_id ?? null,
                    params: {},
                    status: 'pending',
                })
                .select()
                .single();
            return { data, error: error?.message ?? null };
        },
        async regenerate(userId, designId) {
            const client = tokenClient(_currentToken);
            // 先递增计数（通过 RPC 保证原子性）
            await client.rpc("increment_flat_regen_count" as never, { design_id: designId });
            // 再重置状态触发重新生成
            const { data, error } = await client
                .from("flat_designs")
                .update({ status: "pending", image_url: null, error_msg: null })
                .eq("id", designId)
                .eq("user_id", userId)
                .select()
                .single();
            return { data, error: error?.message ?? null };
        },
        async listDesigns(userId, page, pageSize) {
            const client = tokenClient(_currentToken);
            const from = (page - 1) * pageSize;
            const to = from + pageSize - 1;
            const { data, error, count } = await client
                .from("flat_designs")
                .select("*", { count: "exact" })
                .eq("user_id", userId)
                .eq("is_saved", true)
                .order("created_at", { ascending: false })
                .range(from, to);
            return { data, total: count ?? 0, error: error?.message ?? null };
        },
        async listHistory(userId, page, pageSize) {
            const client = tokenClient(_currentToken);
            const from = (page - 1) * pageSize;
            const to = from + pageSize - 1;
            const { data, error, count } = await client
                .from("flat_designs")
                .select("*", { count: "exact" })
                .eq("user_id", userId)
                // 不过滤 is_saved，返回全部历史
                .order("created_at", { ascending: false })
                .range(from, to);
            return { data, total: count ?? 0, error: error?.message ?? null };
        },
        async getDesign(userId, designId) {
            const client = tokenClient(_currentToken);
            const { data, error } = await client
                .from("flat_designs")
                .select("*")
                .eq("id", designId)
                .eq("user_id", userId)
                .maybeSingle();
            return { data, error: error?.message ?? null };
        },
        async removeDesign(userId, designId) {
            const client = tokenClient(_currentToken);
            const { error } = await client
                .from("flat_designs")
                .update({ is_saved: false })
                .eq("id", designId)
                .eq("user_id", userId);
            return { error: error?.message ?? null };
        },
        async saveDesign(userId, designId) {
            const client = tokenClient(_currentToken);
            const { error } = await client
                .from("flat_designs")
                .update({ is_saved: true })
                .eq("id", designId)
                .eq("user_id", userId);
            return { error: error?.message ?? null };
        },
        async batchRemove(userId, designIds) {
            const client = tokenClient(_currentToken);
            const { count, error } = await client
                .from("flat_designs")
                .update({ is_saved: false })
                .in("id", designIds)
                .eq("user_id", userId)
                .select("*", { count: "exact", head: true });
            return { count: count ?? 0, error: error?.message ?? null };
        },
        async batchSave(userId, designIds) {
            const client = tokenClient(_currentToken);
            const { count, error } = await client
                .from("flat_designs")
                .update({ is_saved: true })
                .in("id", designIds)
                .eq("user_id", userId)
                .select("*", { count: "exact", head: true });
            return { count: count ?? 0, error: error?.message ?? null };
        },
    };
}
