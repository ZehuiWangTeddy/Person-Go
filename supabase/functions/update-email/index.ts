import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    },
  );

  const token = req.headers.get("cookie")?.split(";").find(c => c.trim().startsWith("sb-access-token"))?.split("=")[1];

  if (!token) {
    return new Response("Missing 'access_token'", { status: 401 });
  }

  const userId = (await supabaseClient.auth.getUser(token)).data.user?.id;

  const { email } = await req.json();

  const { data: user, error } = await supabaseClient.auth.admin.updateUserById(
    userId,
    { email: email }
  )

  return new Response(
    JSON.stringify({user, error}),
    { headers: { "Content-Type": "application/json" } },
  )
})
