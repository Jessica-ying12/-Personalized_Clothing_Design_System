import { createClient, SupabaseClient, User } from "npm:@supabase/supabase-js@2";
import type { Database } from "../../../types/supabase/index.ts";

type ProfileRow = Database["public"]["Tables"]["profiles"]["Row"];
type JsonRecord = Record<string, unknown>;

export type ProfileApiDeps = {
    getUserByToken: (token: string) => Promise<{ user: User | null; error: string | null }>;
    updateProfile: (
        token: string,
        userId: string,
        updates: { full_name?: string; avatar_url?: string },
    ) => Promise<{ data: ProfileRow | null; error: string | null }>;
    deleteAccount: (
        token: string,
        userId: string,
    ) => Promise<{ error: string | null }>;
    getStats: (
        token: string,
        userId: string,
    ) => Promise<{ data: { flat_total: number; flat_saved: number; design_3d_total: number; design_3d_saved: number } | null; error: string | null }>;
};

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
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
    deps: ProfileApiDeps,
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

export async function handleProfileApi(req: Request, deps: ProfileApiDeps): Promise<Response> {
    if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

    const { pathname } = new URL(req.url);

    // POST /update — 更新昵称/头像
    if (pathname.endsWith("/update") && req.method === "POST") {
        const { user, token, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const { data: body, error: parseError } = await parseJson(req);
        if (parseError || !body) return jsonResponse({ error: parseError ?? "Invalid payload" }, 400);

        const updates: { full_name?: string; avatar_url?: string } = {};
        if (typeof body.full_name === "string") updates.full_name = body.full_name.trim();
        if (typeof body.avatar_url === "string") updates.avatar_url = body.avatar_url.trim();

        if (Object.keys(updates).length === 0) {
            return jsonResponse({ error: "At least one of full_name or avatar_url is required" }, 400);
        }

        const result = await deps.updateProfile(token, user!.id, updates);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data });
    }

    // DELETE /account — 注销账号
    if (pathname.endsWith("/account") && req.method === "DELETE") {
        const { user, token, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const result = await deps.deleteAccount(token, user!.id);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ message: "Account deleted successfully" });
    }

    // GET /stats — 获取统计信息
    if (pathname.endsWith("/stats") && req.method === "GET") {
        const { user, token, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const result = await deps.getStats(token, user!.id);
        if (result.error) return jsonResponse({ error: result.error }, 500);
        return jsonResponse({ data: result.data });
    }

    return jsonResponse({ error: "Unknown endpoint", supported: ["/update", "/account", "/stats"] }, 404);
}

export function createRuntimeDeps(): ProfileApiDeps {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const tokenClient = (token: string): SupabaseClient<Database> =>
        createClient<Database>(supabaseUrl, supabaseAnonKey, {
            global: { headers: { Authorization: `Bearer ${token}` } },
        });

    // service role client 用于删除 auth.users（需要管理员权限）
    const adminClient = createClient<Database>(supabaseUrl, serviceRoleKey, {
        auth: { autoRefreshToken: false, persistSession: false },
    });

    return {
        async getUserByToken(token) {
            const { data: { user }, error } = await tokenClient(token).auth.getUser();
            return { user, error: error?.message ?? null };
        },
        async updateProfile(token, userId, updates) {
            const { data, error } = await tokenClient(token)
                .from("profiles")
                .update(updates)
                .eq("id", userId)
                .select()
                .single();
            return { data, error: error?.message ?? null };
        },
        async deleteAccount(_token, userId) {
            // 删除 auth.users 会级联删除 profiles 和所有业务数据（ON DELETE CASCADE）
            const { error } = await adminClient.auth.admin.deleteUser(userId);
            return { error: error?.message ?? null };
        },
        async getStats(token, userId) {
            const client = tokenClient(token);

            // 查询平面图统计
            const { count: flatTotal } = await client
                .from("flat_designs")
                .select("*", { count: "exact", head: true })
                .eq("user_id", userId);

            const { count: flatSaved } = await client
                .from("flat_designs")
                .select("*", { count: "exact", head: true })
                .eq("user_id", userId)
                .eq("is_saved", true);

            // 查询立体图统计
            const { count: design3dTotal } = await client
                .from("designs_3d")
                .select("*", { count: "exact", head: true })
                .eq("user_id", userId);

            const { count: design3dSaved } = await client
                .from("designs_3d")
                .select("*", { count: "exact", head: true })
                .eq("user_id", userId)
                .eq("is_saved", true);

            return {
                data: {
                    flat_total: flatTotal ?? 0,
                    flat_saved: flatSaved ?? 0,
                    design_3d_total: design3dTotal ?? 0,
                    design_3d_saved: design3dSaved ?? 0,
                },
                error: null,
            };
        },
    };
}
