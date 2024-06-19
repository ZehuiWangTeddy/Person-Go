import "https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts"

Deno.serve(async (req) => {
  return new Response('Your account has been successfully created. Welcome aboard!', {headers: {"Content-Type": "text/plain"}});
})
