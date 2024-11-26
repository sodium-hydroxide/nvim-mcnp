--[[
 * @brief Manages syntax highlighting for MCNP input files
 * @module nvim-mcnp.syntax
 *
 * This module provides comprehensive syntax highlighting for MCNP files,
 * covering all major components:
 * - Cell cards (geometry definitions)
 * - Surface cards (surface definitions)
 * - Data cards (materials, tallies, etc.)
 * - Comments and special formatting
 *
 * The highlighting is column-aware, which is important for MCNP's
 * fixed-format style.
--]]
local M = {}

--[[
 * @brief Core syntax patterns for MCNP
 * @local
--]]
local syntax_patterns = {
    -- Cell cards (columns 1-80)
    cell_patterns = {
        -- Cell number (columns 1-5)
        "^\\s*\\d\\+\\s",
        -- Material number (columns 6-10)
        "\\s\\+\\d\\+\\s",
        -- Density (columns 11-20)
        "\\s\\+-\\?\\d\\+\\.\\?\\d*\\(E[-+]\\?\\d\\+\\)\\?\\s",
    },

    -- Surface cards
    surface_patterns = {
        -- Basic surfaces
        "\\<\\(px\\|py\\|pz\\|p\\|so\\|s\\|sx\\|sy\\|sz\\)\\>",
        -- Special surfaces
        "\\<\\(c/[xyz]\\|k[xyz]\\|sq\\|gq\\|tx\\|ty\\|tz\\)\\>",
    },

    -- Data cards
    data_patterns = {
        -- Material definitions
        "^\\s*m\\d\\+",
        -- Importance cards
        "^\\s*imp:\\(n\\|p\\|e\\)\\>",
        -- Source definitions
        "^\\s*sdef\\>",
        -- Tally specifications
        "^\\s*f\\d\\+",
        -- Energy/time bins
        "^\\s*[et]\\d\\+",
    },

    -- Operators and special characters
    operators = {
        ":", "#", "(", ")", "+", "-", "*", ":", "/", "=", "<", ">",
    },

    -- Comments
    comments = {
        "^c\\s.*$",          -- Full line comments
        "^C\\s.*$",          -- Alternate full line comments
        "\\$\\s.*$",         -- End of line comments
    }
}

--[[
 * @brief Sets up MCNP-specific syntax highlighting
 * @param opts table Configuration options from main setup
--]]
M.setup = function(opts)
    local cmd = vim.cmd

    -- Clear existing syntax
    cmd("syntax clear")

    -- Set up basic syntax elements
    cmd("syntax case match")
    cmd("syntax sync minlines=50")

    -- Comments
    cmd("syntax match mcnpComment /^c\\s.*$/")
    cmd("syntax match mcnpComment /^C\\s.*$/")
    cmd("syntax match mcnpComment /\\$\\s.*$/")

    -- Cell cards
    for _, pattern in ipairs(syntax_patterns.cell_patterns) do
        cmd("syntax match mcnpCell /" .. pattern .. "/")
    end

    -- Surface cards
    for _, pattern in ipairs(syntax_patterns.surface_patterns) do
        cmd("syntax match mcnpSurface /" .. pattern .. "/")
    end

    -- Data cards
    for _, pattern in ipairs(syntax_patterns.data_patterns) do
        cmd("syntax match mcnpData /" .. pattern .. "/")
    end

    -- Numbers with optional scientific notation
    cmd("syntax match mcnpNumber /\\<\\d\\+\\>\\|\\.\\d\\+\\|\\<\\d\\+\\.\\d*\\|\\<\\d*\\.\\d\\+\\>/")
    cmd("syntax match mcnpNumber /[-+]\\?\\d*\\.\\?\\d\\+[eE][-+]\\?\\d\\+/")

    -- Operators
    cmd("syntax match mcnpOperator \"[:#()\\+\\-\\*/:=<>]\"")

    -- Special regions
    cmd("syntax region mcnpString start=/\"/ end=/\"/")
    cmd("syntax region mcnpContinuation start=/&/ end=/$/")

    -- Link highlight groups to standard groups or user overrides
    for group, default in pairs(opts.highlights) do
        cmd("highlight link " .. group .. " " .. default)
    end

    -- Set up column markers for MCNP's fixed format
    if opts.features.column_hints then
        -- Create subtle markers for important column positions
        cmd("highlight mcnpColumn ctermfg=237 guifg=#3a3a3a")
        cmd("syntax match mcnpColumn /\\%5v/")  -- End of cell numbers
        cmd("syntax match mcnpColumn /\\%80v/") -- Standard line length
    end
end

--[[
 * @brief Adds highlighting for MCNP output files
 * @param bufnr number Buffer number to configure
 * @local
--]]
local function setup_output_highlighting(bufnr)
    local cmd = vim.cmd

    -- Highlight common output patterns
    cmd("syntax match mcnpWarning /warning/i")
    cmd("syntax match mcnpError /error/i")
    cmd("syntax match mcnpResult /^\\s*tally/i")

    -- Highlight numerical results
    cmd("syntax match mcnpNumber /\\<\\d\\+\\>\\|\\.\\d\\+\\|\\<\\d\\+\\.\\d*\\|\\<\\d*\\.\\d\\+\\>/")
    cmd("syntax match mcnpNumber /[-+]\\?\\d*\\.\\?\\d\\+[eE][-+]\\?\\d\\+/")

    -- Set up special highlighting for tally results
    cmd("syntax region mcnpTallyResult start=/^\\s*tally/i end=/^\\s*$/ contains=mcnpNumber,mcnpResult")
end

return M
