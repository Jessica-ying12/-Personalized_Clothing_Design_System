import { createClient, SupabaseClient, User } from "npm:@supabase/supabase-js@2";
import type { Database } from "../../../types/supabase/index.ts";

type Design3dRow = Database["public"]["Tables"]["designs_3d"]["Row"];
type JsonRecord = Record<string, unknown>;

const MAX_REGEN = 1; // 立体图重新生成1次

export type Design3dApiDeps = {
    getUserByToken: (token: string) => Promise<{ user: User | null; error: string | null }>;
    createDesign3d: (
        userId: string,
        input: Design3dInput,
    ) => Promise<{ data: Design3dRow | null; error: string | null }>;
    regenerate: (
        userId: string,
        designId: string,
    ) => Promise<{ data: Design3dRow | null; error: string | null }>;
    changeBackground: (
        userId: string,
        designId: string,
        backgroundId: string,
    ) => Promise<{ data: Design3dRow | null; error: string | null }>;
    listDesigns3d: (
        userId: string,
        page: number,
        pageSize: number,
    ) => Promise<{ data: Design3dRow[] | null; total: number; error: string | null }>;
    listHistory: (
        userId: string,
        page: number,
        pageSize: number,
    ) => Promise<{ data: Design3dRow[] | null; total: number; error: string | null }>;
    getDesign3d: (
        userId: string,
        designId: string,
    ) => Promise<{ data: Design3dRow | null; error: string | null }>;
    removeDesign3d: (
        userId: string,
        designId: string,
    ) => Promise<{ error: string | null }>;
    saveDesign3d: (
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

export type Design3dInput = {
    flat_design_id: string;
    body_shape_id: string;
    skin_color_id: string;
    gender_id: string;
    ai_model_id: string;
    background_id?: string;
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

async function getAuthUser(
    req: Request,
    deps: Design3dApiDeps,
): Promise<{ user: User | null; token: string; error: Response | null }> {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
        return { user: null, token: "", error: jsonResponse({ error: "Missing or invalid Authorization header" }, 401) };
    }
    const token = authHeader.slice(7).trim();
    const result = await deps.getUserByToken(token);
    if (result.error || !result.user) {
        return { user: null, token: "", error: jsonResponse({ error: "Unauthorized" }, 401) };
    }
    return { user: result.user, token, error: null };
}

export async function handleDesign3dApi(req: Request, deps: Design3dApiDeps): Promise<Response> {
    if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

    const { pathname } = new URL(req.url);

    // POST /generate — 生成立体图
    if (pathname.endsWith("/generate") && req.method === "POST") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const { data: body, error: parseError } = await parseJson(req);
        if (parseError || !body) return jsonResponse({ error: parseError ?? "Invalid payload" }, 400);

        const required = ["flat_design_id", "body_shape_id", "skin_color_id", "gender_id", "ai_model_id"];
        for (const field of required) {
            if (typeof body[field] !== "string" || !body[field]) {
                return jsonResponse({ error: `${field} is required` }, 400);
            }
        }

        const input: Design3dInput = {
            flat_design_id: body.flat_design_id as string,
            body_shape_id: body.body_shape_id as string,
            skin_color_id: body.skin_color_id as string,
            gender_id: body.gender_id as string,
            ai_model_id: body.ai_model_id as string,
            background_id: typeof body.background_id === "string" ? body.background_id : undefined,
            auto_save: typeof body.auto_save === "boolean" ? body.auto_save : true,
        };

        const result = await deps.createDesign3d(user!.id, input);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data }, 201);
    }

    // POST /regenerate — 重新生成立体图
    if (pathname.endsWith("/regenerate") && req.method === "POST") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const { data: body, error: parseError } = await parseJson(req);
        if (parseError || !body) return jsonResponse({ error: parseError ?? "Invalid payload" }, 400);

        const designId = typeof body.design_id === "string" ? body.design_id : "";
        if (!designId) return jsonResponse({ error: "design_id is required" }, 400);

        const existing = await deps.getDesign3d(user!.id, designId);
        if (existing.error || !existing.data) return jsonResponse({ error: "Design not found" }, 404);
        if (existing.data.regen_count >= MAX_REGEN) {
            return jsonResponse({ error: `Max regeneration limit (${MAX_REGEN}) reached` }, 422);
        }

        const result = await deps.regenerate(user!.id, designId);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data });
    }

    // POST /background — 切换背景
    if (pathname.endsWith("/background") && req.method === "POST") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const { data: body, error: parseError } = await parseJson(req);
        if (parseError || !body) return jsonResponse({ error: parseError ?? "Invalid payload" }, 400);

        const designId = typeof body.design_id === "string" ? body.design_id : "";
        const backgroundId = typeof body.background_id === "string" ? body.background_id : "";
        if (!designId || !backgroundId) {
            return jsonResponse({ error: "design_id and background_id are required" }, 400);
        }

        const result = await deps.changeBackground(user!.id, designId, backgroundId);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data });
    }

    // GET /list — 获取立体图列表（仓库用）
    if (pathname.endsWith("/list") && req.method === "GET") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const url = new URL(req.url);
        const page = Math.max(1, parseInt(url.searchParams.get("page") ?? "1", 10));
        const pageSize = Math.min(50, Math.max(1, parseInt(url.searchParams.get("page_size") ?? "20", 10)));

        const result = await deps.listDesigns3d(user!.id, page, pageSize);
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

        const result = await deps.getDesign3d(user!.id, designId);
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

    // GET /detail?design_id=xxx — 获取单条立体图详情
    if (pathname.endsWith("/detail") && req.method === "GET") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const designId = new URL(req.url).searchParams.get("design_id") ?? "";
        if (!designId) return jsonResponse({ error: "design_id is required" }, 400);

        const result = await deps.getDesign3d(user!.id, designId);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        if (!result.data) return jsonResponse({ error: "Design not found" }, 404);
        return jsonResponse({ data: result.data });
    }

    // DELETE /remove — 从仓库软删除立体图
    if (pathname.endsWith("/remove") && req.method === "DELETE") {
        const { user, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const { data: body, error: parseError } = await parseJson(req);
        if (parseError || !body) return jsonResponse({ error: parseError ?? "Invalid payload" }, 400);

        const designId = typeof body.design_id === "string" ? body.design_id : "";
        if (!designId) return jsonResponse({ error: "design_id is required" }, 400);

        const result = await deps.removeDesign3d(user!.id, designId);
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

        const result = await deps.saveDesign3d(user!.id, designId);
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

    return jsonResponse(
        { error: "Unknown endpoint", supported: ["/generate", "/regenerate", "/background", "/list", "/history", "/status", "/detail", "/remove", "/save", "/batch-remove", "/batch-save"] },
        404,
    );
}

export function createRuntimeDeps(): Design3dApiDeps {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

    let _currentToken = "";

    const tokenClient = (): SupabaseClient<Database> =>
        createClient<Database>(supabaseUrl, supabaseAnonKey, {
            global: { headers: { Authorization: `Bearer ${_currentToken}` } },
        });

    return {
        async getUserByToken(token) {
            _currentToken = token;
            const { data: { user }, error } = await createClient<Database>(supabaseUrl, supabaseAnonKey, {
                global: { headers: { Authorization: `Bearer ${token}` } },
            }).auth.getUser();
            return { user, error: error?.message ?? null };
        },
        async createDesign3d(userId, input) {
            const { data, error } = await tokenClient()
                .from("designs_3d")
                .insert({
                    user_id: userId,
                    flat_design_id: input.flat_design_id,
                    body_shape_id: input.body_shape_id,
                    skin_color_id: input.skin_color_id,
                    gender_id: input.gender_id,
                    ai_model_id: input.ai_model_id,
                    background_id: input.background_id ?? null,
                    status: "pending",
                    is_saved: input.auto_save ?? true,
                })
                .select()
                .single();
            return { data, error: error?.message ?? null };
        },
        async regenerate(userId, designId) {
            // increment first (atomic via RPC), then reset status
            await tokenClient().rpc("increment_3d_regen_count" as never, { design_id: designId });
            const { data, error } = await tokenClient()
                .from("designs_3d")
                .update({ status: "pending", image_url: null, error_msg: null })
                .eq("id", designId)
                .eq("user_id", userId)
                .select()
                .single();
            return { data, error: error?.message ?? null };
        },
        async changeBackground(userId, designId, backgroundId) {
            const { data, error } = await tokenClient()
                .from("designs_3d")
                .update({ background_id: backgroundId, status: "pending", image_url: null })
                .eq("id", designId)
                .eq("user_id", userId)
                .select()
                .single();
            return { data, error: error?.message ?? null };
        },
        async listDesigns3d(userId, page, pageSize) {
            const from = (page - 1) * pageSize;
            const to = from + pageSize - 1;
            const { data, error, count } = await tokenClient()
                .from("designs_3d")
                .select("*", { count: "exact" })
                .eq("user_id", userId)
                .eq("is_saved", true)
                .order("created_at", { ascending: false })
                .range(from, to);
            return { data, total: count ?? 0, error: error?.message ?? null };
        },
        async listHistory(userId, page, pageSize) {
            const from = (page - 1) * pageSize;
            const to = from + pageSize - 1;
            const { data, error, count } = await tokenClient()
                .from("designs_3d")
                .select("*", { count: "exact" })
                .eq("user_id", userId)
                // 不过滤 is_saved，返回全部历史
                .order("created_at", { ascending: false })
                .range(from, to);
            return { data, total: count ?? 0, error: error?.message ?? null };
        },
        async getDesign3d(userId, designId) {
            const { data, error } = await tokenClient()
                .from("designs_3d")
                .select("*")
                .eq("id", designId)
                .eq("user_id", userId)
                .maybeSingle();
            return { data, error: error?.message ?? null };
        },
        async removeDesign3d(userId, designId) {
            const { error } = await tokenClient()
                .from("designs_3d")
                .update({ is_saved: false })
                .eq("id", designId)
                .eq("user_id", userId);
            return { error: error?.message ?? null };
        },
        async saveDesign3d(userId, designId) {
            const { error } = await tokenClient()
                .from("designs_3d")
                .update({ is_saved: true })
                .eq("id", designId)
                .eq("user_id", userId);
            return { error: error?.message ?? null };
        },
        async batchRemove(userId, designIds) {
            const { count, error } = await tokenClient()
                .from("designs_3d")
                .update({ is_saved: false })
                .in("id", designIds)
                .eq("user_id", userId)
                .select("*", { count: "exact", head: true });
            return { count: count ?? 0, error: error?.message ?? null };
        },
        async batchSave(userId, designIds) {
            const { count, error } = await tokenClient()
                .from("designs_3d")
                .update({ is_saved: true })
                .in("id", designIds)
                .eq("user_id", userId)
                .select("*", { count: "exact", head: true });
            return { count: count ?? 0, error: error?.message ?? null };
        },
    };
}
