import { handleFlatDesignApi, createRuntimeDeps } from "./handler.ts";

Deno.serve(async (req: Request) => {
    return handleFlatDesignApi(req, createRuntimeDeps());
});
