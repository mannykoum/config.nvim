# Required Dependencies

- **Neovim (v0.12 or later)**
  - Required by the `vim.pack` based plugin setup (see `lua/pack.lua`).
  - Download and install from the [Neovim releases page](https://github.com/neovim/neovim/releases).

- **Git**
  - Used for cloning and managing plugins.
  - Install via your system package manager (e.g., `sudo apt-get install git` on Ubuntu or `brew install git` on macOS).

- **Node.js and npm**
  - Required for tools such as `markdownlint-cli2` and other Node-based utilities.
  - **macOS:** Install via [Homebrew](https://brew.sh/):
    ```bash
    brew install node
    ```
  - **Ubuntu:** Install via:
    ```bash
    sudo apt-get install nodejs npm
    ```

- **markdownlint-cli2**
  - Lints Markdown files. This is used by the autocommand that runs on file save.
  - Install globally using npm:
    ```bash
    npm install -g markdownlint-cli2
    ```
  - Make sure the installation path (e.g., `~/.npm-global/bin`) is included in your PATH.

- **make**
  - Required to build some plugins (like `telescope-fzf-native.nvim` and support for regex in LuaSnip).
  - **macOS:** Typically available via Xcode Command Line Tools:
    ```bash
    xcode-select --install
    ```
  - **Ubuntu:** Install via:
    ```bash
    sudo apt-get install build-essential
    ```

- **Stylua**
  - A code formatter for Lua, used by the configuration.
  - Download a prebuilt binary from the [StyLua GitHub Releases](https://github.com/JohnnyMorganz/StyLua/releases) or install via Cargo if you have Rust installed:
    ```bash
    cargo install stylua
    ```

- **curl**
  - Used by `codecompanion.nvim` (see below). Ships with most systems; install via your package manager otherwise.

# CLI Coding Agents

`lua/custom/plugins/agents.lua` wires [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim)
to whichever agent CLI you already use. The plugin runs the CLI in a Neovim
terminal and hands it context from your buffers, so **each agent authenticates
itself** — through its own `login` flow or the environment it already reads. No
API keys or secrets belong in this config.

Install at least one of the following and make sure it is on your `PATH`:

| Agent | Executable | Launched as | Install |
| --- | --- | --- | --- |
| Claude Code | `claude` | `claude` | [docs](https://docs.claude.com/en/docs/claude-code/overview) |
| OpenAI Codex | `codex` | `codex` | [docs](https://github.com/openai/codex) |
| Hermes Agent | `hermes` | `hermes --cli` | [repo](https://github.com/NousResearch/hermes-agent) · [docs](https://hermes-agent.nousresearch.com/docs/) |

Availability is detected at startup: only the agents found on `PATH` are
exposed, and the first one in the table above that is installed becomes the
default. If none are installed you get a warning on startup and the plugin is
skipped entirely.

## Usage

| Key / command | Action |
| --- | --- |
| `<leader>aa` | Toggle the last agent terminal |
| `<leader>ap` | Pick an agent (`vim.ui.select`) |
| `<leader>ak` | Ask the agent — opens a prompt buffer |
| `<leader>as` | Send context: visual selection, or whole buffer in normal mode |
| `<leader>ad` | Send the buffer's diagnostics and ask for a fix |
| `:Agent [name]` | Toggle the last agent, or open one by name (tab-completes) |
| `:AgentSelect` | The `<leader>ap` picker |

Inside a prompt you can reference editor context with `#{buffer}`,
`#{buffers}`, `#{diagnostics}`, `#{selection}`, `#{terminal}` and friends, and
insert file references with the `/file` and `/buffer` slash commands. `{` and
`}` cycle between open agent terminals. Run `:checkhealth codecompanion` to
verify the setup.

### File references are not portable across agents

CodeCompanion expands a file reference — `#{buffer}`, `/file`, `/buffer`, and
`#{this}` in normal mode — to a bare `@path` token. Claude Code and Codex read
that as a file reference. **Hermes does not.** Its parser only matches
`@file:`, `@folder:`, `@git:`, `@url:`, `@diff` and `@staged`, so a bare
`@path` reaches it as ordinary prose and the file is never attached.

`agents.lua` works around this for `<leader>as` only: when Hermes is the active
agent, sending a whole buffer in normal mode emits `@file:<absolute path>`
instead. Visual selections are unaffected — CodeCompanion inlines the selected
text verbatim, which every agent reads — and so are `<leader>ad` diagnostics.

Everywhere else the token is CodeCompanion's to write and there is no per-agent
hook to rewrite it, so **when you are talking to Hermes, type `@file:path` or
`@folder:path` yourself** rather than reaching for `/file`, `/buffer` or
`#{buffer}`. Two Hermes details worth knowing when you do:

- Quote a path containing spaces or brackets (`` @file:`src/my notes.md` ``) —
  an unquoted reference stops at the first space.
- `@file:` reads the file **from disk**, so save the buffer first if you want
  Hermes to see unsaved edits. `<leader>as` refuses outright on a buffer with
  nothing on disk and tells you to write it or select the lines instead.

`plenary.nvim` and the `markdown`/`markdown_inline` Treesitter parsers that
CodeCompanion needs are already installed by `telescope` and `treesitter`.

> **Migrating from Copilot:** the old `copilot.lua` / `blink-copilot` setup was
> removed. `vim.pack` leaves unused plugins on disk, so clean them up with:
>
> ```vim
> :lua vim.pack.del { 'copilot.lua', 'blink-copilot' }
> ```
