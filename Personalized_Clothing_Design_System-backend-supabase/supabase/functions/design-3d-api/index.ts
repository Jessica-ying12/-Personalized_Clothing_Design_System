import { handleDesign3dApi, createRuntimeDeps } from "./handler.ts";

Deno.serve(async (req: Request) => {
    return handleDesign3dApi(req, createRuntimeDeps());
});
