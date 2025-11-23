{ config, ... }:
{
  home.file."./.config/shell_gpt/.sgptrc".enable = true;
  home.file."./.config/shell_gpt/.sgptrc".text = ''
    DEFAULT_MODEL=ollama/deepseek-coder
    USE_LITELLM=true

    CHAT_CACHE_PATH=/tmp/chat_cache
    CACHE_PATH=/tmp/cache
    CHAT_CACHE_LENGTH=100
    CACHE_LENGTH=100
    REQUEST_TIMEOUT=60
    DEFAULT_COLOR=magenta
    ROLE_STORAGE_PATH=${config.home.homeDirectory}/.config/shell_gpt/roles
    DEFAULT_EXECUTE_SHELL_CMD=false
    DISABLE_STREAMING=false
    CODE_THEME=dracula
    OPENAI_FUNCTIONS_PATH=${config.home.homeDirectory}/.config/shell_gpt/functions
    OPENAI_USE_FUNCTIONS=true
    SHOW_FUNCTIONS_OUTPUT=false
    API_BASE_URL=default
    PRETTIFY_MARKDOWN=true
    SHELL_INTERACTION=true
    OS_NAME=auto
    SHELL_NAME=auto
    OPENAI_API_KEY=ollama
  '';
}
