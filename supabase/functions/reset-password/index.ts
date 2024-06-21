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
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    },
  );

  const url = new URL(req.url);
  const tokenHash = url.searchParams.get("token_hash");
  let userId = null;

  if (tokenHash) {
    const { data, error } = await supabaseClient.auth.verifyOtp({
      token_hash: tokenHash,
      type: 'email'
    });

    if (error || !data) {
      console.error("Error verifying OTP", error);
      return new Response('Email link is invalid or has expired', {status: 500, headers: {"Content-Type": "text/plain"}});
    }

    userId = data.user.id;
  } else {
    const token = req.headers.get("cookie")?.split(";").find(c => c.trim().startsWith("sb-access-token"))?.split("=")[1];

    if (token) {
      userId = (await supabaseClient.auth.getUser(token)).data.user?.id;
    } else {
      return new Response("Missing 'access_token'", { status: 401 });
    }
  }

  const newPassword = generatePassword(12);

  const { data: updatedUser, error } = await supabaseClient.auth.admin.updateUserById(
    userId,
    { password: newPassword }
  )

  if (error) {
    console.error("Error updating user", error);
    return new Response('Failed to update password', {status: 500, headers: {"Content-Type": "text/plain"}});
  }

  return new Response(`Password updated! You new password is: ${newPassword}`, {headers: {"Content-Type": "text/plain"}});
})
