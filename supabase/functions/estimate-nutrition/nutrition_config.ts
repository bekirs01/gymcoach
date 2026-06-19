export const DEFAULT_NUTRITION_AI_MODEL = "gpt-4o-mini";
export const FALLBACK_NUTRITION_AI_MODEL = "gpt-4o-mini";

export function resolveNutritionModel(): string {
  const model = Deno.env.get("NUTRITION_AI_MODEL")?.trim();
  return model && model.length > 0 ? model : DEFAULT_NUTRITION_AI_MODEL;
}

export function isModelUnavailableError(message: string): boolean {
  const value = message.toLowerCase();
  return value.includes("model") &&
    (value.includes("not found") ||
      value.includes("does not exist") ||
      value.includes("unsupported") ||
      value.includes("invalid"));
}

export const NUTRITION_SYSTEM_PROMPT = `You are GymCoach Nutrition AI inside a fitness app.

You only handle food, meals, calories, macros, portion sizes, hydration, and fitness-related eating.
Reject unrelated questions politely in the same language as the user.
Answer in the same language as the user: English, Turkish, or Russian.
If portion size is missing for a vague food item, return status needs_clarification with a clarifying question.
Never claim exact precision. Use realistic estimates.
Never give medical diagnosis or dangerous diet advice.
Return JSON only matching the schema.`;

export const NUTRITION_RESPONSE_JSON_SCHEMA = {
  type: "object",
  additionalProperties: false,
  properties: {
    status: { type: "string", enum: ["estimated", "needs_clarification", "rejected", "error"] },
    language: { type: "string", enum: ["en", "tr", "ru", "other"] },
    user_message_summary: { type: "string" },
    clarifying_question: { type: ["string", "null"] },
    rejection_message: { type: ["string", "null"] },
    meal_name: { type: "string" },
    meal_type: { type: "string", enum: ["breakfast", "lunch", "dinner", "snack", "unknown"] },
    items: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        properties: {
          name: { type: "string" },
          original_text: { type: "string" },
          amount: { type: "number" },
          unit: { type: "string", enum: ["g", "ml", "piece", "plate", "cup", "tbsp", "tsp", "serving", "unknown"] },
          estimated_grams: { type: "number" },
          calories: { type: "number" },
          protein_g: { type: "number" },
          carbs_g: { type: "number" },
          fat_g: { type: "number" },
          confidence: { type: "string", enum: ["low", "medium", "high"] },
          notes: { type: ["string", "null"] },
        },
        required: [
          "name",
          "original_text",
          "amount",
          "unit",
          "estimated_grams",
          "calories",
          "protein_g",
          "carbs_g",
          "fat_g",
          "confidence",
          "notes",
        ],
      },
    },
    totals: {
      type: "object",
      additionalProperties: false,
      properties: {
        calories: { type: "number" },
        protein_g: { type: "number" },
        carbs_g: { type: "number" },
        fat_g: { type: "number" },
      },
      required: ["calories", "protein_g", "carbs_g", "fat_g"],
    },
    user_facing_message: { type: "string" },
  },
  required: [
    "status",
    "language",
    "user_message_summary",
    "clarifying_question",
    "rejection_message",
    "meal_name",
    "meal_type",
    "items",
    "totals",
    "user_facing_message",
  ],
};
