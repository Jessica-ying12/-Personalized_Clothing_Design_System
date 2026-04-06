import { createClient, SupabaseClient, User } from "npm:@supabase/supabase-js@2";
import type { Database } from "../../../types/supabase/index.ts";

type JsonRecord = Record<string, unknown>;

export type StorageApiDeps = {
    getUserByToken: (token: string) => Promise<{ user: User | null; error: string | null }>;
    uploadFile: (
        token: string,
        file: Uint8Array,
        fileName: string,
        folder: string,
    ) => Promise<{ url: string | null; path: string | null; error: string | null }>;
    getSignedUrl: (
        token: string,
        path: string,
    ) => Promise<{ url: string | null; expiresAt: string | null; error: string | null }>;
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

async function getAuthUser(
    req: Request,
    deps: StorageApiDeps,
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

export async function handleStorageApi(req: Request, deps: StorageApiDeps): Promise<Response> {
    if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

    const { pathname } = new URL(req.url);

    // POST /upload — 上传图片
    if (pathname.endsWith("/upload") && req.method === "POST") {
        const { user, token, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const contentType = req.headers.get("Content-Type") ?? "";
        if (!contentType.includes("multipart/form-data")) {
            return jsonResponse({ error: "Content-Type must be multipart/form-data" }, 400);
        }

        let formData: FormData;
        try {
            formData = await req.formData();
        } catch {
            return jsonResponse({ error: "Failed to parse form data" }, 400);
        }

        const file = formData.get("file");
        if (!file || !(file instanceof File)) {
            return jsonResponse({ error: "file field is required and must be a file" }, 400);
        }

        const folder = (formData.get("folder") as string) ?? "flat";
        if (!["flat", "3d"].includes(folder)) {
            return jsonResponse({ error: "folder must be 'flat' or '3d'" }, 400);
        }

        const fileBytes = new Uint8Array(await file.arrayBuffer());
        const fileName = file.name || `upload-${Date.now()}.png`;

        const result = await deps.uploadFile(token, fileBytes, fileName, folder);
        if (result.error) return jsonResponse({ error: result.error }, 500);

        return jsonResponse({ url: result.url, path: result.path }, 201);
    }

    // GET /download?path=xxx — 获取签名下载链接
    if (pathname.endsWith("/download") && req.method === "GET") {
        const { user, token, error: authError } = await getAuthUser(req, deps);
        if (authError) return authError;

        const path = new URL(req.url).searchParams.get("path") ?? "";
        if (!path) return jsonResponse({ error: "path is required" }, 400);

        const result = await deps.getSignedUrl(token, path);
        if (result.error) return jsonResponse({ error: result.error }, 500);

        return jsonResponse({ url: result.url, expires_at: result.expiresAt });
    }

    return jsonResponse({ error: "Unknown endpoint", supported: ["/upload", "/download"] }, 404);
}

export function createRuntimeDeps(): StorageApiDeps {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const bucketName = "designs";

    const tokenClient = (token: string): SupabaseClient<Database> =>
        createClient<Database>(supabaseUrl, supabaseAnonKey, {
            global: { headers: { Authorization: `Bearer ${token}` } },
        });

    return {
        async getUserByToken(token) {
            const { data: { user }, error } = await tokenClient(token).auth.getUser();
            return { user, error: error?.message ?? null };
        },
        async uploadFile(token, fileBytes, fileName, folder) {
            const client = tokenClient(token);
            const filePath = `${folder}/${Date.now()}-${fileName}`;
            const { data, error } = await client.storage
                .from(bucketName)
                .upload(filePath, fileBytes, {
                    contentType: "image/png",
                    upsert: false,
                });

            if (error) return { url: null, path: null, error: error.message };

            const { data: publicUrlData } = client.storage.from(bucketName).getPublicUrl(data.path);
            return { url: publicUrlData.publicUrl, path: data.path, error: null };
        },
        async getSignedUrl(token, path) {
            const client = tokenClient(token);
            const { data, error } = await client.storage
                .from(bucketName)
                .createSignedUrl(path, 3600); // 1 hour

            if (error) return { url: null, expiresAt: null, error: error.message };

            const expiresAt = new Date(Date.now() + 3600 * 1000).toISOString();
            return { url: data.signedUrl, expiresAt, error: null };
        },
    };
}
