{ pkgs, config, lib, ...}:
with lib;
with builtins;

let
    cfg = config.vim.dap;
in {
    options.vim.dap = {
        enable      = mkEnableOption "DAP support";

        go          = mkEnableOption "Go Language Support";
        clang       = mkEnableOption "C/C++ with clang";

        variableDebugPreviews = mkEnableOption "Enable variable previews";
    };

    config = mkIf cfg.enable {
        vim.startPlugins = with pkgs.neovimPlugins; [ 
            nvim-which-key

            nvim-dap
            nvim-telescope
            nvim-telescope-dap

            nvim-dap-ui
        ] ++ lib.optionals cfg.go [
            nvim-dap-go
        ] ++ lib.optionals cfg.variableDebugPreviews [
            nvim-dap-virtual-text
        ];

        vim.globals = {};

        vim.luaConfigRC = ''
            ${builtins.readFile ./dap.lua}

            ${if cfg.variableDebugPreviews then ''
            require("nvim-dap-virtual-text").setup({
                enabled                     = true,     -- enable this plugin (the default)
                enabled_commands            = true,     -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
                highlight_changed_variables = true,     -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
                highlight_new_as_changed    = true,     -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
                show_stop_reason            = true,     -- show stop reason when stopped for exceptions
                commented                   = true,     -- prefix virtual text with comment string

                -- experimental features:
                virt_text_pos               = 'eol',    -- position of virtual text, see `:h nvim_buf_set_extmark()`
                all_frames                  = false,    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
                virt_lines                  = false,    -- show virtual lines instead of virtual text (will flicker!)
                virt_text_win_col           = 80,       -- position the virtual text at a fixed window column (starting from the first text column) ,
                                                        -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
            })
            '' else ""}

            ${if cfg.go then ''
            lua require('dap-go').setup({
                delve = {
                    -- port = "38697",
                    port = "40000",
                },

                dap_configurations = {
                    {
                        -- Must be "go" or it will be ignored by the plugin
                        type        = "go",

                        name        = "Attach remote",
                        mode        = "remote",
                        request     = "attach",
                    },
                },
            })
            '' else ""}

            ${if cfg.clang then ''
                dap.adapters.lldb = {
                    type    = 'executable',
                    command = 'lldb-vscode',
                    name    = "lldb"
                }
                dap.adapters.c   = dap.adapters.lldb
                dap.adapters.cpp = dap.adapters.lldb

                dap.configurations.c = {
                    {
                        name = 'Attach to process',
                        type = 'c',
                        request = 'attach',
                        pid = require('dap.utils').pick_process,
                        args = {}
                    },
                    {
                        name = 'Launch',
                        type = 'c',
                        request = 'launch',
                        program = function()
                            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                        end,
                        cwd = "''${workspaceFolder}",
                        stopOnEntry = false,
                        args = {},
                        runInTerminal = false,
                    },
                }

                -- An example .vscode/launch.json
                -- {
                --  "version": "0.2.0",
                --  "configurations": [{
                --      "name": "checkgrant",
                -- 
                --      "type": "c",
                --      "request": "launch",
                --      "program": "''${input:bin}",
                --      "args": [ "checkgrant" ]
                --  }],
                --  "inputs": [{
                --      "id": "bin",
                --      "type": "promptString",
                --      "description": "Program to run: ",
                --      "default": "../../bin/pkcs11config"
                --  } ]
                -- }

                -- This can be used for cpp and rust as well
                dap.configurations.cpp  = dap.configurations.c
                dap.configurations.objc = dap.configurations.c
                dap.configurations.rust = dap.configurations.c
            '' else ""}
        '';
    };
}

