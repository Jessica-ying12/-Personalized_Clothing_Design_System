import { handleProfileApi, createRuntimeDeps } from "./handler.ts";

Deno.serve(async (req: Request) => {
    return handleProfileApi(req, createRuntimeDeps());
});
