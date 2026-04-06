import { handleStorageApi, createRuntimeDeps } from "./handler.ts";

Deno.serve(async (req) => {
    const deps = createRuntimeDeps();
    return await handleStorageApi(req, deps);
});
