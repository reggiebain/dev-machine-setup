// Continue.dev Configuration
// For: HBP ML Scientist - Privacy-Preserving AI Coding
// 
// This config uses LOCAL Ollama models for code assistance.
// No code is sent to external servers - safe for HBP data.

export function modifyConfig(config: Config): Config {
  return {
    models: [
      // Primary coding model - larger context window
      {
        title: "DeepSeek Coder (Local - HBP Safe)",
        provider: "ollama",
        model: "deepseek-coder:6.7b",
        apiBase: "http://localhost:11434",
        contextLength: 16384,
      },
      // Alternative coding model
      {
        title: "Qwen 2.5 Coder (Local)",
        provider: "ollama",
        model: "qwen2.5-coder:7b",
        apiBase: "http://localhost:11434",
        contextLength: 8192,
      },
    ],
    
    // Model for tab autocomplete (appears as you type)
    tabAutocompleteModel: {
      title: "DeepSeek Autocomplete",
      provider: "ollama",
      model: "deepseek-coder:6.7b",
      apiBase: "http://localhost:11434",
    },
    
    // Context providers - what the model can access
    contextProviders: [
      {
        name: "code",
        params: {},
      },
      {
        name: "docs",
        params: {},
      },
      {
        name: "diff",
        params: {},
      },
      {
        name: "terminal",
        params: {},
      },
      {
        name: "problems",
        params: {},
      },
      {
        name: "folder",
        params: {},
      },
      {
        name: "codebase",
        params: {},
      },
    ],
    
    // Slash commands for quick actions
    slashCommands: [
      {
        name: "edit",
        description: "Edit selected code",
      },
      {
        name: "comment",
        description: "Write comments for the selected code",
      },
      {
        name: "share",
        description: "Export this session to markdown",
      },
      {
        name: "cmd",
        description: "Generate a shell command",
      },
    ],
    
    // Privacy settings
    allowAnonymousTelemetry: false,
  };
}
