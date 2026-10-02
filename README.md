# Bestie AI V4 — Real AI Texting Helper

This version connects the Texting Helper to a Supabase Edge Function, which calls OpenAI server-side. The OpenAI key is never placed in browser code.

## Setup in Supabase Dashboard (phone-friendly)

1. Open your Bestie AI Supabase project.
2. Run the existing `supabase_schema.sql` from the previous package if you have not already.
3. In **Edge Functions**, create a function named `bestie-reply`.
4. Paste the contents of `supabase/functions/bestie-reply/index.ts` into the function editor and deploy it.
5. In **Edge Function Secrets**, create:
   `OPENAI_API_KEY` = your OpenAI API key.
6. Do NOT put the OpenAI key in `config.js`, GitHub, Netlify, or browser JavaScript.
7. Put your Supabase project URL and public anon/publishable key in `config.js`.
8. Make sure users are signed in through Supabase Auth before calling Texting Helper.
9. Open `ai.html` and test a message.

Supabase documents Edge Functions as a place for server-side AI integrations and recommends storing third-party credentials as function secrets. OpenAI likewise says API keys must remain secret and not be exposed in client-side code.

For production, add rate limits, usage tracking, abuse controls, and billing safeguards before opening the AI endpoint widely.

## Brain Boost V5
The new `brain.html` uses the `brain-boost` Supabase Edge Function to generate fresh educational challenges dynamically. It supports Logic, Memory, Numbers, Words and General categories plus Easy/Medium/Hard difficulty.

Deploy `supabase/functions/brain-boost/index.ts` as an Edge Function and reuse the `OPENAI_API_KEY` secret already configured for the texting helper. Do not put the secret in browser code.

## V6 Persistent Progress
Progress is now stored in Supabase:
- XP
- level derived from XP
- streak
- challenge attempts
- achievements
- owner-visible progress data

The `record_challenge_result` database function performs the XP update server-side with a bounded XP value, so the browser cannot simply submit an unlimited XP amount.

IMPORTANT: For production, use the real challenge ID returned by the brain generator or persist generated questions before recording attempts. This starter currently uses the placeholder challenge ID `0` and therefore requires one final schema adjustment before challenge history is fully relational.

## V7: Real challenge IDs + leaderboard
Generated Brain Boost questions are now saved in `challenges` before the user answers, and the result RPC validates the challenge ID and reads XP from the database instead of trusting the browser. A leaderboard page reads profile XP/streak data and shows the top 25 users.

For production, consider privacy controls (display names, opt-out, blocking/reporting) before enabling a public leaderboard.

V9 adds the secure payment architecture:
- Stripe Checkout creation through a Supabase Edge Function
- 3-day subscription trial
- US$5 recurring price supplied through a Stripe Price ID
- Success/cancel return URLs
- Server-side payment secrets
- Webhook endpoint placeholder that refuses unverified events

Do not accept live payments until the Stripe webhook signature verification and subscription-state updates are implemented and tested in Stripe test mode.
