--[[
 * @brief Main configuration module for MCNP development in Neovim
 * @module nvim-mcnp
 *
 * This module provides a specialized environment for working with MCNP input
 * files. While MCNP doesn't have traditional language servers or formatters,
 * we can provide helpful features through custom implementations:
 *
 * - Syntax highlighting for cell, surface, and data cards
 * - Snippets for common MCNP structures
 * - Basic completion for MCNP keywords and parameters
 * - Special handling for MCNP's column-sensitive format
 * - Integration with MCNP tools when available
--]]
local M = {}

--[[
 * @brief Default configuration options for MCNP support
 * @field mcnp_path Path to MCNP executable (optional)
 * @field column_ruler Show column ruler at position 80
 * @field features Table of feature flags
--]]
M.options = {
    -- Path to MCNP executable (used for integration if available)
    mcnp_path = nil,

    -- Display options
    column_ruler = true,  -- Show column marker at position 80

    -- Feature flags
    features = {
        syntax = true,          -- Enable syntax highlighting
        snippets = true,        -- Enable MCNP snippets
        completion = true,      -- Enable basic completion
        column_hints = true,    -- Show column position hints
        folding = true,        -- Enable section folding
    },

    -- Highlighting groups (can be overridden)
    highlights = {
        mcnpCell = "Statement",
        mcnpSurface = "Type",
        mcnpData = "Special",
        mcnpComment = "Comment",
        mcnpNumber = "Number",
        mcnpOperator = "Operator",
        mcnpError = "Error",
    }
}

--[[
 * @brief Detects MCNP installation and tools
 * @return table Table indicating which MCNP tools are available
 * @local
--]]
local function detect_mcnp_installation()
    return {
        mcnp = vim.fn.executable("mcnp6") == 1 or
               vim.fn.executable("mcnp5") == 1,
        meshtal = vim.fn.executable("gridconv") == 1,
        -- Add other MCNP-related tool checks
    }
end

--[[
 * @brief Sets up file type detection for MCNP files
 * @local
--]]
local function setup_filetype_detection()
    -- Define autocmd for MCNP file detection
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = {
            "*.i",      -- Input files
            "*.mcnp",   -- Alternative input extension
            "*.o",      -- Output files
            "*.m",      -- MCTAL files
            "*.r",      -- RUNTPE files
            "*.in",
        },
        callback = function(args)
            -- Set filetype to mcnp
            vim.bo[args.buf].filetype = "mcnp"

            -- Set up MCNP-specific options
            if M.options.column_ruler then
                vim.wo.colorcolumn = "80"
            end

            -- Use fixed-width font if available
            vim.wo.list = true
            vim.wo.listchars = "tab:> ,trail:-,extends:>,precedes:<"

            -- Set up indentation (MCNP is column-sensitive)
            vim.bo.expandtab = false
            vim.bo.tabstop = 8
            vim.bo.shiftwidth = 8

            -- Enable completion if requested
            if M.options.features.completion then
                require("nvim-mcnp.completion").setup(args.buf, M.options)
            end

            -- Set up column hints if enabled
            if M.options.features.column_hints then
                require("nvim-mcnp.columns").setup(args.buf)
            end
        end
    })
end

--[[
 * @brief Main setup function for MCNP support
 * @param opts table Optional configuration overrides
--]]
M.setup = function(opts)
    -- Merge user options with defaults
    M.options = vim.tbl_deep_extend("force", M.options, opts or {})

    -- Set up filetype detection
    setup_filetype_detection()

    -- Check for MCNP installation
    local mcnp_tools = detect_mcnp_installation()
    if mcnp_tools.mcnp then
        -- Add MCNP executable to path if provided
        if M.options.mcnp_path then
            vim.env.PATH = M.options.mcnp_path .. ":" .. vim.env.PATH
        end
    end

    -- Load syntax highlighting if enabled
    if M.options.features.syntax then
        require("nvim-mcnp.syntax").setup(M.options)
    end

    -- Set up snippets if enabled
    if M.options.features.snippets then
        require("nvim-mcnp.snippets").setup(M.options)
    end
end

return M
