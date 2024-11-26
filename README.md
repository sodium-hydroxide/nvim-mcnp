# nvim-mcnp

A Neovim plugin for MCNP (Monte Carlo N-Particle) input file development. This plugin provides syntax highlighting, snippets, and basic completions for MCNP input files. It's designed to make working with MCNP's column-sensitive format easier and more intuitive.

## Features

- Column-aware syntax highlighting for:
  - Cell cards
  - Surface cards
  - Data cards (materials, tallies, etc.)
  - Comments and continuations
- Visual guides for MCNP's column-sensitive format
- Snippets for common MCNP structures
- Basic completion for MCNP keywords and parameters
- Special handling for MCNP file types (*.i, *.o, *.m, *.r)
- Integration with MCNP executables when available

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "sodium-hydroxide/nvim-mcnp",
    dependencies = {
        -- Required for snippets and completion
        "L3MON4D3/LuaSnip",
        "hrsh7th/nvim-cmp",
        -- Required for tree-sitter (optional but recommended)
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("nvim-mcnp").setup({
            -- Optional: path to MCNP executable for integration
            mcnp_path = nil,
            -- Show column marker at position 80
            column_ruler = true,
            -- Enable/disable features
            features = {
                syntax = true,       -- Syntax highlighting
                snippets = true,     -- MCNP snippets
                completion = true,   -- Basic completion
                column_hints = true, -- Show column position hints
                folding = true,     -- Section folding
            }
        })
    end,
    ft = { "mcnp" },  -- Load only for MCNP files
}
```

## Future Development

This plugin currently provides basic support for MCNP development. Future plans include:

- Full language server implementation for MCNP
  - Intelligent error detection
  - Cross-references between cells and surfaces
  - Hover documentation for MCNP cards
  - Advanced completion with parameter validation
- Integration with MCNP visualization tools
- Advanced diagnostics for geometry and physics validation
- Support for MCNP output file analysis

## Contributing

Contributions are welcome! Areas where help would be particularly appreciated:

1. Language server development for MCNP
2. Additional snippets for common MCNP patterns
3. Integration with visualization tools
4. Enhanced error detection and validation

## License

MIT License - See LICENSE for details
