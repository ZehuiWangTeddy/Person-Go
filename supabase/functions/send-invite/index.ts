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

  const { userEmail } = await req.json();

  const { data, error } = await supabaseClient.auth.admin.inviteUserByEmail(userEmail);

  return new Response(
    JSON.stringify({data, error}),
    { headers: { "Content-Type": "application/json" } },
  )
})
