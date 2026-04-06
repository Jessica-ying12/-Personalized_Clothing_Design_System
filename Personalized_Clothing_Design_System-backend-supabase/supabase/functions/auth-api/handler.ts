import { createClient, SupabaseClient, User } from "npm:@supabase/supabase-js@2";
import type { Database } from "../../../types/supabase/index.ts";

type JsonRecord = Record<string, unknown>;
type ProfileRow = Database["public"]["Tables"]["profiles"]["Row"];

export type AuthApiDeps = {
  signUp: (input: {
    email: string;
    password: string;
    fullName?: string;
    avatarUrl?: string;
  }) => Promise<{ user: User | null; session: unknown; error: string | null }>;
  signIn: (input: {
    email: string;
    password: string;
  }) => Promise<{ user: User | null; session: unknown; error: string | null }>;
  signInWithMagicLink: (email: string) => Promise<{ error: string | null }>;
  changePassword: (token: string, newPassword: string) => Promise<{ error: string | null }>;
  resetPassword: (email: string) => Promise<{ error: string | null }>;
  getUserByToken: (token: string) => Promise<{ user: User | null; error: string | null }>;
  getProfileByUserId: (token: string, userId: string) => Promise<{ profile: ProfileRow | null; error: string | null }>;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

function jsonResponse(body: JsonRecord, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

async function parseJson(req: Request): Promise<{ data: JsonRecord | null; error: string | null }> {
  try {
    const data = (await req.json()) as JsonRecord;
    return { data, error: null };
  } catch {
    return { data: null, error: "Invalid JSON payload" };
  }
}

async function handleRegister(req: Request, deps: AuthApiDeps): Promise<Response> {
  const payloadResult = await parseJson(req);
  if (payloadResult.error || !payloadResult.data) {
    return jsonResponse({ error: payloadResult.error ?? "Invalid payload" }, 400);
  }

  const email = typeof payloadResult.data.email === "string" ? payloadResult.data.email.trim() : "";
  const password = typeof payloadResult.data.password === "string" ? payloadResult.data.password : "";
  const fullName = typeof payloadResult.data.full_name === "string" ? payloadResult.data.full_name.trim() : undefined;
  const avatarUrl = typeof payloadResult.data.avatar_url === "string" ? payloadResult.data.avatar_url.trim() : undefined;

  if (!email || !password) {
    return jsonResponse({ error: "email and password are required" }, 400);
  }

  const result = await deps.signUp({ email, password, fullName, avatarUrl });
  if (result.error) {
    return jsonResponse({ error: "Register failed", detail: result.error }, 400);
  }

  return jsonResponse(
    {
      user: result.user,
      session: result.session,
      message: result.session ? "registered" : "check email to confirm",
    },
    200,
  );
}

async function handleLogin(req: Request, deps: AuthApiDeps): Promise<Response> {
  const payloadResult = await parseJson(req);
  if (payloadResult.error || !payloadResult.data) {
    return jsonResponse({ error: payloadResult.error ?? "Invalid payload" }, 400);
  }

  const email = typeof payloadResult.data.email === "string" ? payloadResult.data.email.trim() : "";
  const password = typeof payloadResult.data.password === "string" ? payloadResult.data.password : "";

  if (!email || !password) {
    return jsonResponse({ error: "email and password are required" }, 400);
  }

  const result = await deps.signIn({ email, password });
  if (result.error) {
    return jsonResponse({ error: "Login failed", detail: result.error }, 401);
  }

  return jsonResponse({ user: result.user, session: result.session }, 200);
}

async function handleMe(req: Request, deps: AuthApiDeps): Promise<Response> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return jsonResponse({ error: "Missing or invalid Authorization header" }, 401);
  }

  const token = authHeader.slice("Bearer ".length).trim();
  if (!token) {
    return jsonResponse({ error: "Missing bearer token" }, 401);
  }

  const userResult = await deps.getUserByToken(token);
  if (userResult.error || !userResult.user) {
    return jsonResponse({ error: "Unauthorized", detail: userResult.error ?? "Unknown auth error" }, 401);
  }

  const profileResult = await deps.getProfileByUserId(token, userResult.user.id);
  if (profileResult.error) {
    return jsonResponse({ error: "Failed to fetch profile", detail: profileResult.error }, 500);
  }

  return jsonResponse(
    {
      user: {
        id: userResult.user.id,
        email: userResult.user.email,
      },
      profile: profileResult.profile,
    },
    200,
  );
}

async function handleMagicLink(req: Request, deps: AuthApiDeps): Promise<Response> {
  const payloadResult = await parseJson(req);
  if (payloadResult.error || !payloadResult.data) {
    return jsonResponse({ error: payloadResult.error ?? "Invalid payload" }, 400);
  }

  const email = typeof payloadResult.data.email === "string" ? payloadResult.data.email.trim() : "";
  if (!email) {
    return jsonResponse({ error: "email is required" }, 400);
  }

  const result = await deps.signInWithMagicLink(email);
  if (result.error) {
    return jsonResponse({ error: "Failed to send magic link", detail: result.error }, 400);
  }

  return jsonResponse({ message: "Check your email for login link" }, 200);
}

async function handleChangePassword(req: Request, deps: AuthApiDeps): Promise<Response> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return jsonResponse({ error: "Missing or invalid Authorization header" }, 401);
  }

  const token = authHeader.slice("Bearer ".length).trim();
  if (!token) {
    return jsonResponse({ error: "Missing bearer token" }, 401);
  }

  const payloadResult = await parseJson(req);
  if (payloadResult.error || !payloadResult.data) {
    return jsonResponse({ error: payloadResult.error ?? "Invalid payload" }, 400);
  }

  const newPassword = typeof payloadResult.data.new_password === "string" ? payloadResult.data.new_password : "";
  if (!newPassword || newPassword.length < 6) {
    return jsonResponse({ error: "new_password is required and must be at least 6 characters" }, 400);
  }

  const result = await deps.changePassword(token, newPassword);
  if (result.error) {
    return jsonResponse({ error: "Failed to change password", detail: result.error }, 400);
  }

  return jsonResponse({ message: "Password changed successfully" }, 200);
}

async function handleResetPassword(req: Request, deps: AuthApiDeps): Promise<Response> {
  const payloadResult = await parseJson(req);
  if (payloadResult.error || !payloadResult.data) {
    return jsonResponse({ error: payloadResult.error ?? "Invalid payload" }, 400);
  }

  const email = typeof payloadResult.data.email === "string" ? payloadResult.data.email.trim() : "";
  if (!email) {
    return jsonResponse({ error: "email is required" }, 400);
  }

  const result = await deps.resetPassword(email);
  if (result.error) {
    return jsonResponse({ error: "Failed to send reset link", detail: result.error }, 400);
  }

  return jsonResponse({ message: "Check your email for password reset link" }, 200);
}

export async function handleAuthApi(req: Request, deps: AuthApiDeps): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const { pathname } = new URL(req.url);

  if (pathname.endsWith("/register")) {
    if (req.method !== "POST") {
      return jsonResponse({ error: "Method Not Allowed" }, 405);
    }
    return handleRegister(req, deps);
  }

  if (pathname.endsWith("/login")) {
    if (req.method !== "POST") {
      return jsonResponse({ error: "Method Not Allowed" }, 405);
    }
    return handleLogin(req, deps);
  }

  if (pathname.endsWith("/me")) {
    if (req.method !== "GET") {
      return jsonResponse({ error: "Method Not Allowed" }, 405);
    }
    return handleMe(req, deps);
  }

  if (pathname.endsWith("/login-magic-link")) {
    if (req.method !== "POST") {
      return jsonResponse({ error: "Method Not Allowed" }, 405);
    }
    return handleMagicLink(req, deps);
  }

  if (pathname.endsWith("/change-password")) {
    if (req.method !== "POST") {
      return jsonResponse({ error: "Method Not Allowed" }, 405);
    }
    return handleChangePassword(req, deps);
  }

  if (pathname.endsWith("/reset-password")) {
    if (req.method !== "POST") {
      return jsonResponse({ error: "Method Not Allowed" }, 405);
    }
    return handleResetPassword(req, deps);
  }

  return jsonResponse({ error: "Unknown endpoint", supported: ["/register", "/login", "/login-magic-link", "/change-password", "/reset-password", "/me"] }, 404);
}

export function createRuntimeDeps(): AuthApiDeps {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");

  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error("Missing SUPABASE_URL or SUPABASE_ANON_KEY");
  }

  const anonClient = createClient<Database>(supabaseUrl, supabaseAnonKey);

  const createTokenClient = (token: string): SupabaseClient<Database> =>
    createClient<Database>(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: `Bearer ${token}` } },
    });

  return {
    async signUp(input) {
      const { data, error } = await anonClient.auth.signUp({
        email: input.email,
        password: input.password,
        options: {
          data: {
            full_name: input.fullName,
            avatar_url: input.avatarUrl,
          },
        },
      });
      return { user: data.user, session: data.session, error: error?.message ?? null };
    },
    async signIn(input) {
      const { data, error } = await anonClient.auth.signInWithPassword({
        email: input.email,
        password: input.password,
      });
      return { user: data.user, session: data.session, error: error?.message ?? null };
    },
    async signInWithMagicLink(email) {
      const { error } = await anonClient.auth.signInWithOtp({
        email,
        options: {
          emailRedirectTo: `${Deno.env.get("SITE_URL") ?? "http://localhost:3000"}/auth/callback`,
        },
      });
      return { error: error?.message ?? null };
    },
    async changePassword(token, newPassword) {
      const client = createTokenClient(token);
      const { error } = await client.auth.updateUser({
        password: newPassword,
      });
      return { error: error?.message ?? null };
    },
    async resetPassword(email) {
      const { error } = await anonClient.auth.resetPasswordForEmail(email, {
        redirectTo: `${Deno.env.get("SITE_URL") ?? "http://localhost:3000"}/auth/reset-password`,
      });
      return { error: error?.message ?? null };
    },
    async getUserByToken(token) {
      const client = createTokenClient(token);
      const {
        data: { user },
        error,
      } = await client.auth.getUser();
      return { user, error: error?.message ?? null };
    },
    async getProfileByUserId(token, userId) {
      const client = createTokenClient(token);
      const { data, error } = await client
        .from("profiles")
        .select("id, full_name, avatar_url, created_at, updated_at")
        .eq("id", userId)
        .maybeSingle();
      return { profile: data ?? null, error: error?.message ?? null };
    },
  };
}
