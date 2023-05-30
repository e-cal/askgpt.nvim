# AskGPT

A minimal neovim plugin to ask ChatGPT about your code.

## Installation

Install with your favourite plugin manager.

> Requires `plenary` and `nui`

E.g. using `packer`:

```lua
use({
    "e-cal/askgpt",
    config = function()
        require("askgpt").setup()
    end,
    requires = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    }
})
```

## Configuration

Default config:

```lua
{
    -- API request params. See https://platform.openai.com/docs/api-reference/chat/create
    params = {
        model = "gpt-3.5-turbo",
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 300,
        temperature = 0,
        top_p = 1,
        n = 1,
    },
    binds = {
        submit = "<C-d>",
        close = "q",
    },
}
```

## Usage

You will need an OpenAI API key to use this plugin, which you can get [here](https://platform.openai.com/account/api-keys).

Once you have a key, either set it as the environment variable `OPENAI_API_KEY`, or you will be prompted to enter it when starting neovim with the plugin installed.

The plugin adds the `Ask` command, which can be bound to a keymapping for in both normal and visual mode.

Example mapping `Ask` to `?`:

```lua
vim.keymap.set("n", "?", "<cmd>Ask<CR>")
vim.keymap.set("v", "?", "<cmd>Ask<CR>")
```

This command will open a popup window with some text in it.

- Visual mode: the text will be whatever was selected, wrapped in ` ```<lang> ``` ` (markdown formatting for code with the language indicated).
- Normal mode: the text will be the hover text from your LSP for the symbol under your cursor

## Why?

- I'm always copy-pasting code into ChatGPT or GPT-4, asking it to explain or how to use a function from some library I'm not familiar with
- This speeds up the process a ton and keeps me in my workflow
