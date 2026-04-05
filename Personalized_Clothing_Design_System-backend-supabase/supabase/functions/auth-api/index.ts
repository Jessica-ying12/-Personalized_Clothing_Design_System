import { createRuntimeDeps, handleAuthApi } from "./handler.ts";

const deps = createRuntimeDeps();

Deno.serve(async (req: Request): Promise<Response> => {
  return handleAuthApi(req, deps);
});
