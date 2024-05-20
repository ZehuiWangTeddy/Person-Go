import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

function generatePassword(length: number): string {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
}

Deno.serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
  );

  const token = req.headers.get("cookie")?.split(";").find(c => c.trim().startsWith("sb-access-token"))?.split("=")[1];

  if (!token) {
    return new Response("Missing 'access_token'", { status: 401 });
  }

  const userId = (await supabaseClient.auth.getUser(token)).data.user?.id;

  const newPassword = generatePassword(12);

  try {
    await supabaseClient.auth.updateUser(userId, { password: newPassword });
    return new Response(`Password reset successfully! You new password is: ${newPassword}`, {headers: {"Content-Type": "text/plain"}});
  } catch (error) {
    console.log("Error updating user", error);
    return new Response('Failed to update password', {status: 500, headers: {"Content-Type": "text/plain"}});
  }
})
