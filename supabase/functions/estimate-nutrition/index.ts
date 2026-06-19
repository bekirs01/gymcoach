import {
  FALLBACK_NUTRITION_AI_MODEL,
  NUTRITION_RESPONSE_JSON_SCHEMA,
  NUTRITION_SYSTEM_PROMPT,
  isModelUnavailableError,
  resolveNutritionModel,
} from "./nutrition_config.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type EstimateRequest = {
  message: string;
  locale: string;
  userProfile: Record<string, unknown>;
  todaySummary: Record<string, unknown>;
};

type LocaleKey = "en" | "tr" | "ru";

const MESSAGES: Record<
  LocaleKey,
  {
    emptyInput: string;
    calculateFailed: string;
    setupMissing: string;
    rejected: string;
  }
> = {
  en: {
    emptyInput: "Please describe what you ate.",
    calculateFailed: "Could not calculate this meal. Check your connection and try again.",
    setupMissing: "Nutrition AI is not ready yet. Please contact support or try again later.",
    rejected: "I can only help with food, calories, and nutrition tracking.",
  },
  tr: {
    emptyInput: "Lütfen ne yediğini yaz.",
    calculateFailed: "Bu öğün hesaplanamadı. Bağlantını kontrol edip tekrar dene.",
    setupMissing: "Beslenme yapay zekası henüz hazır değil. Lütfen daha sonra tekrar dene.",
    rejected: "Sadece yemek, kalori ve makro takibi konusunda yardımcı olabilirim.",
  },
  ru: {
    emptyInput: "Напишите, что вы ели.",
    calculateFailed: "Не удалось рассчитать этот приём пищи. Проверьте подключение и попробуйте снова.",
    setupMissing: "Nutrition AI пока недоступен. Попробуйте позже.",
    rejected: "Я могу помочь только с питанием, калориями и макросами.",
  },
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function normalizeLocale(value: unknown): LocaleKey {
  if (typeof value !== "string") return "en";
  const code = value.trim().toLowerCase().split("-")[0];
  if (code === "tr" || code === "ru") return code;
  return "en";
}

function errorBody(message: string, locale: LocaleKey = "en") {
  return {
    status: "error",
    language: locale,
    user_message_summary: "",
    clarifying_question: null,
    rejection_message: null,
    meal_name: "",
    meal_type: "unknown",
    items: [],
    totals: {
      calories: 0,
      protein_g: 0,
      carbs_g: 0,
      fat_g: 0,
    },
    user_facing_message: message,
  };
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function readMessage(raw: Record<string, unknown>): string {
  if (typeof raw.message === "string") return raw.message.trim();
  if (typeof raw.userMessage === "string") return raw.userMessage.trim();
  return "";
}

function normalizeProfile(raw: Record<string, unknown>): Record<string, unknown> {
  const profile = isObject(raw.userProfile) ? { ...raw.userProfile } : {};
  if (profile.goal == null && typeof profile.fitnessGoal === "string") {
    profile.goal = profile.fitnessGoal;
  }
  return profile;
}

function validateRequest(raw: unknown): EstimateRequest | null {
  if (!isObject(raw)) return null;
  const message = readMessage(raw);
  if (message.length === 0 || message.length > 2000) return null;
  return {
    message,
    locale: normalizeLocale(raw.locale),
    userProfile: normalizeProfile(raw),
    todaySummary: isObject(raw.todaySummary) ? raw.todaySummary : {},
  };
}

function buildInput(request: EstimateRequest): Array<{ role: string; content: string }> {
  return [
    { role: "system", content: NUTRITION_SYSTEM_PROMPT },
    {
      role: "user",
      content: JSON.stringify({
        message: request.message,
        locale: request.locale,
        userProfile: request.userProfile,
        todaySummary: request.todaySummary,
      }),
    },
  ];
}

function extractText(payload: Record<string, unknown>): string | null {
  const output = payload.output;
  if (!Array.isArray(output)) return null;
  for (const item of output) {
    if (!isObject(item) || item.type !== "message" || !Array.isArray(item.content)) continue;
    for (const part of item.content) {
      if (isObject(part) && part.type === "output_text" && typeof part.text === "string") {
        return part.text.trim();
      }
    }
  }
  return null;
}

async function callOpenAI(
  apiKey: string,
  model: string,
  request: EstimateRequest,
): Promise<{ text: string | null; error: string | null }> {
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      input: buildInput(request),
      text: {
        format: {
          type: "json_schema",
          name: "nutrition_estimate",
          strict: true,
          schema: NUTRITION_RESPONSE_JSON_SCHEMA,
        },
      },
    }),
  });

  const payload = await response.json() as Record<string, unknown>;
  if (!response.ok) {
    const error = isObject(payload.error) && typeof payload.error.message === "string"
      ? payload.error.message
      : `OpenAI request failed (${response.status})`;
    return { text: null, error };
  }
  return { text: extractText(payload), error: null };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse(errorBody("Method not allowed"), 405);
  }

  let locale: LocaleKey = "en";
  let body: unknown;
  try {
    body = await req.json();
    if (isObject(body)) {
      locale = normalizeLocale(body.locale);
    }
  } catch (error) {
    console.error(`[estimate-nutrition] Invalid request JSON: ${error}`);
    return jsonResponse(errorBody(MESSAGES.en.emptyInput, locale), 200);
  }

  const apiKey = Deno.env.get("OPENAI_API_KEY")?.trim();
  if (!apiKey) {
    console.error("[estimate-nutrition] OPENAI_API_KEY is not configured");
    return jsonResponse(errorBody(MESSAGES[locale].setupMissing, locale), 200);
  }

  const request = validateRequest(body);
  if (!request) {
    return jsonResponse(errorBody(MESSAGES[locale].emptyInput, locale), 200);
  }

  locale = request.locale;

  try {
    let model = resolveNutritionModel();
    let result = await callOpenAI(apiKey, model, request);
    if (result.error && isModelUnavailableError(result.error)) {
      model = FALLBACK_NUTRITION_AI_MODEL;
      result = await callOpenAI(apiKey, model, request);
    }
    if (result.error || !result.text) {
      console.error(`[estimate-nutrition] OpenAI failed: ${result.error ?? "empty output"}`);
      return jsonResponse(errorBody(MESSAGES[locale].calculateFailed, locale), 200);
    }
    const parsed = JSON.parse(result.text) as Record<string, unknown>;
    if (parsed.status === "rejected" && !parsed.rejection_message) {
      parsed.rejection_message = MESSAGES[locale].rejected;
    }
    if (parsed.status === "rejected" && !parsed.user_facing_message) {
      parsed.user_facing_message = MESSAGES[locale].rejected;
    }
    return jsonResponse(parsed, 200);
  } catch (error) {
    console.error(`[estimate-nutrition] Unexpected error: ${error}`);
    return jsonResponse(errorBody(MESSAGES[locale].calculateFailed, locale), 200);
  }
});
