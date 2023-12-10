{ pkgs, config, lib, ...}:
with lib;
with builtins;

let
	cfg = config.vim.terminal.flatten;
in {
	options.vim.terminal.flatten = {
		enable = mkEnableOption "flatten";
	};

	config = mkIf (cfg.enable) ({
		vim.startPlugins = with pkgs.neovimPlugins; [
			flatten
		];

		vim.luaConfigRC = ''
			-- Open man pages in neovim splits as well
			vim.cmd('let $MANPAGER="nvim +Man!"')  

            require("flatten").setup({
            	window = {
					-- I prefer using 'alternate' but then closing the opened
					-- window causes the whole tab to close...
					--
					-- Restore this option once I figure out a way to prevent
					-- that happening...
            		-- open = "alternate",

            		open = "vsplit",
            		focus = "first",
            	},
            })
            '';
	});
}



