{config, lib, pkgs, ...}:
{
	imports = [
		./core
		./basic
		./themes
		./dashboard
		./statusline
		./lsp
		./dap
		./fuzzyfind
		./git
		./formatting
		./editor
		./test
		./terminal
	];
}
