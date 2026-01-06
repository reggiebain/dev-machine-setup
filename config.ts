// Continue.dev Configuration
// For: HBP ML Scientist - Privacy-Preserving AI Coding
// 
// This config uses LOCAL Ollama models for code assistance.
// No code is sent to external servers - safe for HBP data.

export function modifyConfig(config: Config): Config {
  return {
    models: [
      // DeepSeek for coding (primary on work laptop)
      {
        title: "DeepSeek Coder (Code)",
        provider: "ollama",
        model: "deepseek-coder:6.7b",
        apiBase: "http://localhost:11434",
      },
      // Llama for general questions
      {
        title: "Llama 3.2 3B (Chat)",
        provider: "ollama",
        model: "llama3.2:3b",
        apiBase: "http://localhost:11434",
      },
      // Your Llama 3.1 from personal laptop (if you want it)
      {
        title: "Llama 3.1 8B (Local)",
        provider: "ollama",
        model: "llama3.1:8b",
        apiBase: "http://localhost:11434",
      },
    ],
    
    // Use DeepSeek for autocomplete (best for code)
    tabAutocompleteModel: {
      title: "DeepSeek Autocomplete",
      provider: "ollama",
      model: "deepseek-coder:6.7b",
      apiBase: "http://localhost:11434",
    },
    
    // For semantic code search
    embeddingsProvider: {
      provider: "ollama",
      model: "nomic-embed-text",
      apiBase: "http://localhost:11434",
    },
    
    // What context the model can access
    contextProviders: [
      {
        name: "code",
        params: {},
      },
      {
        name: "diff",
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
      {
        name: "terminal",
        params: {},
      },
      {
        name: "problems",
        params: {},
      },
      {
        name: "docs",
        params: {},
      },
    ],
    
    // Helpful commands you can use with /
    slashCommands: [
      {
        name: "edit",
        description: "Edit selected code",
      },
      {
        name: "comment",
        description: "Write comments for code",
      },
      {
        name: "share",
        description: "Export chat to markdown",
      },
      {
        name: "cmd",
        description: "Generate a shell command",
      },
      {
        name: "commit",
        description: "Generate git commit message",
      },
    ],
    
    // Custom slash commands for HBP work
    customCommands: [
      {
        name: "test",
        prompt: "Write comprehensive unit tests for the selected code using pytest. Include edge cases and docstrings.",
        description: "Generate unit tests",
      },
      {
        name: "docstring",
        prompt: "Add a Google-style docstring to this function/class with Args, Returns, and Examples sections.",
        description: "Add docstring",
      },
      {
        name: "optimize",
        prompt: "Analyze this code for performance issues and suggest optimizations. Consider time complexity, space complexity, and Python best practices.",
        description: "Optimize code",
      },
      {
        name: "explain",
        prompt: "Explain what this code does in detail, including algorithms, data structures, and design patterns used.",
        description: "Explain code",
      },
      {
        name: "snowflake",
        prompt: "Convert this code to work with Snowflake using snowflake-ml-python or snowflake-connector-python.",
        description: "Snowflake integration",
      },
    ],
    
    // Don't send telemetry
    allowAnonymousTelemetry: false,
    
    // Documentation sites for context
    docs: [
      "https://docs.snowflake.com/",
      "https://scikit-learn.org/stable/",
      "https://fastapi.tiangolo.com/",
      "https://pandas.pydata.org/docs/",
    ],
  };
}