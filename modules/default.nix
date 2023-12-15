{config, lib, pkgs, ...}:
{
	imports = [
		./core
		./basic
		./themes
		./dashboard
		./build
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
