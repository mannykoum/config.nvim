# Required Dependencies

- **Neovim (v0.12 or later)**
  - Required by the `vim.pack` based plugin setup (see `lua/pack.lua`).
  - Download and install from the [Neovim releases page](https://github.com/neovim/neovim/releases).

- **Git**
  - Used for cloning and managing plugins.
  - Install via your system package manager (e.g., `sudo apt-get install git` on Ubuntu or `brew install git` on macOS).

- **Node.js and npm**
  - Required for tools such as `markdownlint-cli` and other Node-based utilities.
  - **macOS:** Install via [Homebrew](https://brew.sh/):
    ```bash
    brew install node
    ```
  - **Ubuntu:** Install via:
    ```bash
    sudo apt-get install nodejs npm
    ```

- **markdownlint-cli**
  - Lints Markdown files. This is used by the autocommand that runs on file save.
  - Install globally using npm:
    ```bash
    npm install -g markdownlint-cli
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
