import { handleDesignOptionsApi, createRuntimeDeps } from "./handler.ts";

Deno.serve(async (req: Request) => {
    return handleDesignOptionsApi(req, createRuntimeDeps());
});
