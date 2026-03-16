import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from '@modelcontextprotocol/sdk/types.js';

const GATEWAY_BASE_URL =
  process.env.GATEWAY_BASE_URL ?? 'https://ai-agent-gateway.infragistics.com';
const GATEWAY_TOKEN = process.env.GATEWAY_TOKEN ?? '';

if (!GATEWAY_TOKEN) {
  process.stderr.write(
    'WARNING: GATEWAY_TOKEN is not set — all Gateway API calls will fail with 401\n'
  );
}

// ── Types ────────────────────────────────────────────────────────────────────

interface GatewayResponse {
  output: string;
  title: string;
  sessionId: string;
  citations: string[];
  confidenceLevel: number;
}

interface GatewayError {
  error: string;
}

// ── Gateway API client ────────────────────────────────────────────────────────

async function callGateway(
  endpoint: string,
  body: Record<string, string>
): Promise<GatewayResponse> {
  const url = `${GATEWAY_BASE_URL}${endpoint}`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${GATEWAY_TOKEN}`,
    },
    body: JSON.stringify(body),
  });

  if (response.status === 401) {
    throw new Error('Gateway authentication failed — check GATEWAY_TOKEN');
  }
  if (response.status === 403) {
    throw new Error('Gateway authorization failed — token lacks required scope');
  }
  if (response.status === 429) {
    throw new Error('Gateway rate limit exceeded — wait and retry');
  }
  if (response.status === 500) {
    throw new Error('Gateway upstream error — Bedrock invocation failed');
  }
  if (!response.ok) {
    const err = (await response.json().catch(() => ({ error: 'unknown' }))) as GatewayError;
    throw new Error(`Gateway error ${response.status}: ${err.error}`);
  }

  return response.json() as Promise<GatewayResponse>;
}

function formatResponse(result: GatewayResponse): string {
  const lines: string[] = [];

  lines.push(`**${result.title || 'Gateway response'}**`);
  lines.push('');
  lines.push(result.output);

  if (result.confidenceLevel < 60) {
    lines.push('');
    lines.push(
      `> ⚠️ Low confidence (${result.confidenceLevel}%) — treat technical details with caution`
    );
  }

  if (result.citations && result.citations.length > 0) {
    lines.push('');
    lines.push('**Sources:**');
    for (const citation of result.citations) {
      lines.push(`- ${citation}`);
    }
  }

  lines.push('');
  lines.push(`_Session: ${result.sessionId} | Confidence: ${result.confidenceLevel}%_`);

  return lines.join('\n');
}

// ── Tool definitions ──────────────────────────────────────────────────────────

const TOOLS: Tool[] = [
  {
    name: 'invoke_by_product_type',
    description:
      'Query the Infragistics AI Agent Gateway for product-specific information. Routes to the correct Bedrock agent based on productType. Use for questions about specific Ignite UI products, APIs, components, and features. The agent has RAG access to the full Infragistics documentation.',
    inputSchema: {
      type: 'object',
      properties: {
        input: {
          type: 'string',
          description: 'The question or query to send to the agent',
        },
        productType: {
          type: 'string',
          enum: ['igniteui', 'appbuilder', 'reveal', 'ultimate'],
          description:
            'Product to route to: igniteui (Ignite UI Angular/React/WC/Blazor), appbuilder (App Builder), reveal (Reveal BI), ultimate (Ultimate UI)',
        },
        sessionId: {
          type: 'string',
          description:
            'Optional session ID for conversation continuity. Use the same ID across related queries to maintain context.',
        },
      },
      required: ['input', 'productType'],
    },
  },
  {
    name: 'invoke_master_agent',
    description:
      'Query the Infragistics master AI agent directly. Use for cross-product queries, general Infragistics questions, or when the specific product is unknown. The master agent can route internally to product-specific sub-agents.',
    inputSchema: {
      type: 'object',
      properties: {
        input: {
          type: 'string',
          description: 'The question or query to send to the master agent',
        },
        sessionId: {
          type: 'string',
          description:
            'Optional session ID for conversation continuity across related queries.',
        },
      },
      required: ['input'],
    },
  },
  {
    name: 'gateway_health',
    description: 'Check if the Infragistics AI Agent Gateway is reachable and healthy.',
    inputSchema: {
      type: 'object',
      properties: {},
      required: [],
    },
  },
];

// ── Server ────────────────────────────────────────────────────────────────────

const server = new Server(
  {
    name: 'gateway-api',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: TOOLS,
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'invoke_by_product_type': {
        const { input, productType, sessionId } = args as {
          input: string;
          productType: string;
          sessionId?: string;
        };

        const body: Record<string, string> = { input, productType };
        if (sessionId) body.sessionId = sessionId;

        const result = await callGateway('/api/agents/invokeByProductType', body);

        return {
          content: [
            {
              type: 'text',
              text: formatResponse(result),
            },
          ],
        };
      }

      case 'invoke_master_agent': {
        const { input, sessionId } = args as {
          input: string;
          sessionId?: string;
        };

        const body: Record<string, string> = { input };
        if (sessionId) body.sessionId = sessionId;

        const result = await callGateway('/api/agents/invokeMasterAgent', body);

        return {
          content: [
            {
              type: 'text',
              text: formatResponse(result),
            },
          ],
        };
      }

      case 'gateway_health': {
        const url = `${GATEWAY_BASE_URL}/healthz`;
        const response = await fetch(url);
        const healthy = response.ok;

        return {
          content: [
            {
              type: 'text',
              text: healthy
                ? `Gateway is healthy (${GATEWAY_BASE_URL})`
                : `Gateway returned ${response.status} — may be degraded`,
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return {
      content: [
        {
          type: 'text',
          text: `Error: ${message}`,
        },
      ],
      isError: true,
    };
  }
});

// ── Start ─────────────────────────────────────────────────────────────────────

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  process.stderr.write(
    `Gateway API MCP server running — base URL: ${GATEWAY_BASE_URL}\n`
  );
}

main().catch((err) => {
  process.stderr.write(`Fatal: ${err}\n`);
  process.exit(1);
});
