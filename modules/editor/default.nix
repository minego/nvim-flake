{ pkgs, config, lib, ...}:
with lib;
with builtins;

let
    cfg = config.vim.editor;
in {
    options.vim = {
		editor = {
			indentGuide             = mkEnableOption "Enable indent guides";
			underlineCurrentWord    = mkEnableOption "Underline the word under the cursor";

			colourPreview = mkOption {
				description         = "Enable colour previews";
				type                = types.bool;
				default             = true;
			};
		};

		useOsc52Clipboard = mkOption {
			default         = true;
			description     = "Make use of the clipboard for default yank and paste operations. Don't use * and +";
			type            = types.bool;
		};
	};

    config = {
        vim.startPlugins = with pkgs.neovimPlugins; [
            nvim-which-key
            nvim-osc52
		] ++ lib.optionals cfg.indentGuide [
            indent-blankline-nvim
		] ++ lib.optionals cfg.underlineCurrentWord [
            vim-cursorword
        ];

        vim.nnoremap = {
            "<leader>wc" = "<cmd>close<cr>";
            "<leader>wh" = "<cmd>split<cr>";
            "<leader>wv" = "<cmd>vsplit<cr>";
        };

        vim.luaConfigRC = ''
            local wk = require("which-key")
            
            wk.register({
                w = {
                    name    = "window",
                    c       = { "Close Window" },
                    h       = { "Split Horizontal" },
                    v       = { "Split Vertical" },
                },
            }, { prefix = "<leader>" })
            
            ${if config.vim.useOsc52Clipboard then ''
                local osc52 = require('osc52')
                
                osc52.setup({
                	max_length = 0,		-- Maximum length of selection (0 for no limit)
                	silent     = false,	-- Disable message on successful copy
                	trim       = true,	-- Trim surrounding whitespaces before copy
                })
                
                local function copy(lines, _)
                	osc52.copy(table.concat(lines, '\n'))
                end
                
                local function paste()
                	return {vim.fn.split(vim.fn.getreg(""), '\n'), vim.fn.getregtype("")}
                end
                
                -- Now the '+' register will copy to system clipboard using OSC52
                vim.g.clipboard = {
                	name		= 'osc52',
                	copy = {
                		['+']	= copy,
                		['*']	= copy
                	},
                	paste = {
                		['+']	= paste,
                		['*']	= paste
                	},
                }
                '' else ""}
            '';
    };
}
