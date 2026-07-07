// Edge Function: Create User (Admin Only)
// Path: supabase/functions/create-user/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

interface CreateUserRequest {
  name: string
  username: string
  password: string
  role: 'user' | 'helpdesk' | 'admin'
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Only allow POST
    if (req.method !== 'POST') {
      return new Response('Method not allowed', { status: 405, headers: corsHeaders })
    }

    console.log('Received request at:', new Date().toISOString())

    // Extract JWT from Authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ error: 'Missing or invalid Authorization header' }),
        { status: 401, headers: corsHeaders }
      )
    }

    const token = authHeader.substring(7) // Remove 'Bearer ' prefix

    // Create Supabase client to verify JWT and get user
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    // Verify JWT and get user
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        { status: 401, headers: corsHeaders }
      )
    }

    // Check if user is ADMIN
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .maybeSingle()

    if (!profile || profile.role !== 'admin') {
      return new Response(
        JSON.stringify({ error: 'Forbidden: Only admin can create users' }),
        { status: 403, headers: corsHeaders }
      )
    }

    // Parse request body
    const { name, username, password, role }: CreateUserRequest = await req.json()

    // Validation
    if (!name || !username || !password || !role) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { status: 400, headers: corsHeaders }
      )
    }

    if (password.length < 6) {
      return new Response(
        JSON.stringify({ error: 'Password must be at least 6 characters' }),
        { status: 400, headers: corsHeaders }
      )
    }

    if (!['user', 'helpdesk', 'admin'].includes(role)) {
      return new Response(
        JSON.stringify({ error: 'Invalid role. Must be: user, helpdesk, or admin' }),
        { status: 400, headers: corsHeaders }
      )
    }

    // Create Supabase client with SERVICE ROLE KEY
    // for user creation operations (bypasses RLS, doesn't affect caller session)
    const supabaseService = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const email = `${username.toLowerCase().trim()}@helpdesk.com`

    // Check if username already exists
    const { data: existingProfile } = await supabaseService
      .from('profiles')
      .select('id')
      .eq('username', username.toLowerCase().trim())
      .maybeSingle()

    if (existingProfile) {
      return new Response(
        JSON.stringify({ error: 'Username already exists' }),
        { status: 409, headers: corsHeaders }
      )
    }

    // Create user with Admin API
    const { data: userData, error: userError } = await supabaseService.auth.admin.createUser({
      email,
      password,
      email_confirm: true, // Auto-confirm email
      user_metadata: {
        name,
        username,
        role
      }
    })

    if (userError) {
      // Handle duplicate email error
      if (userError.message.includes('already been registered')) {
        return new Response(
          JSON.stringify({ error: `Email ${email} already exists. Use a different username.` }),
          { status: 409, headers: corsHeaders }
        )
      }
      return new Response(
        JSON.stringify({ error: `Failed to create user: ${userError.message}` }),
        { status: 400, headers: corsHeaders }
      )
    }

    if (!userData.user) {
      return new Response(
        JSON.stringify({ error: 'Failed to create user: No user data returned' }),
        { status: 500, headers: corsHeaders }
      )
    }

    // Create profile using upsert to handle existing profiles
    const { error: profileError } = await supabaseService
      .from('profiles')
      .upsert({
        id: userData.user.id,
        name,
        username: username.toLowerCase().trim(),
        role
      }, {
        onConflict: 'id' // If profile exists, update it instead of failing
      })

    if (profileError) {
      // Rollback: delete user if profile creation fails
      await supabaseService.auth.admin.deleteUser(userData.user.id)
      return new Response(
        JSON.stringify({ error: `Failed to create profile: ${profileError.message}` }),
        { status: 500, headers: corsHeaders }
      )
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: 'User created successfully',
        user: {
          id: userData.user.id,
          email: userData.user.email,
          name,
          username,
          role
        }
      }),
      { headers: corsHeaders }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: corsHeaders }
    )
  }
})
