import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type JsonObject = Record<string, unknown>;

function isObject(value: unknown): value is JsonObject {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function cloneWithoutReasoning(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(cloneWithoutReasoning);
  }

  if (!isObject(value)) {
    return value;
  }

  const copy: JsonObject = {};
  for (const [key, child] of Object.entries(value)) {
    if (key === "reasoning") continue;
    copy[key] = cloneWithoutReasoning(child);
  }
  return copy;
}

function messageHasReasoning(value: unknown): boolean {
  if (!isObject(value)) return false;
  return Object.prototype.hasOwnProperty.call(value, "reasoning");
}

export default function (pi: ExtensionAPI) {
  pi.on("before_provider_request", (event, ctx) => {
    const model = ctx.model;
    const modelKey = `${model?.provider ?? ""}/${model?.id ?? ""}`.toLowerCase();

    // Kimi K2.6 via opencode-go rejects non-standard `reasoning` fields on
    // input messages with: "Extra inputs are not permitted". Pi may preserve
    // prior assistant reasoning in conversation history, so strip it just before
    // the provider request. Keep this narrowly scoped to Kimi/opencode-go.
    if (!modelKey.includes("opencode-go/kimi-k2.6")) return;

    const payload = event.payload;
    if (!isObject(payload) || !Array.isArray(payload.messages)) return;
    if (!payload.messages.some(messageHasReasoning)) return;

    return {
      ...payload,
      messages: cloneWithoutReasoning(payload.messages),
    };
  });
}
