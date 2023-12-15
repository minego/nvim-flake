{ pkgs, config, lib, ...}:
with lib;
with builtins;

let
    cfg = config.vim.lsp;
in {
    options.vim.lsp = {
        enable      = mkEnableOption "LSP support";

        bash        = mkEnableOption "Bash Language Support";
        go          = mkEnableOption "Go Language Support";
        nix         = mkEnableOption "NIX Language Support";
        python      = mkEnableOption "Python Support";
        ruby        = mkEnableOption "Ruby Support";
        rust        = mkEnableOption "Rust Support";
        terraform   = mkEnableOption "Terraform Support";
        typescript  = mkEnableOption "Typescript/Javascript Support";
        vimscript   = mkEnableOption "Vim Script Support";
        yaml        = mkEnableOption "yaml support";
        docker      = mkEnableOption "docker support";
        tex         = mkEnableOption "tex support";
        css         = mkEnableOption "css support";
        html        = mkEnableOption "html support";
        clang       = mkEnableOption "C/C++ with clang";
        json        = mkEnableOption "JSON";
        graphql     = mkEnableOption "GraphQL";

        lightbulb   = mkEnableOption "Light Bulb";
        codespell	= mkEnableOption "Code Spell";
    };

    config = mkIf cfg.enable {
        vim.startPlugins = with pkgs.neovimPlugins; [ 
            nvim-lspconfig
            nvim-lsp-smag
            lsp_signature
			null-ls
			gitsigns

            pkgs.vimPlugins.nvim-treesitter.withAllGrammars
            nvim-treesitter-context
            nvim-treesitter-textobjects
		] ++ lib.optionals cfg.nix [
			vim-nix
		] ++ lib.optionals cfg.lightbulb [
			nvim-lightbulb
		];

        vim.configRC = ''
            set completeopt=menuone,longest,noselect,preview
            '';

        vim.globals = {
        };

        vim.luaConfigRC = ''
            ${builtins.readFile ./lsp.lua}

			local null_ls	= require("null-ls")

			null_ls.setup({
				sources = {
					null_ls.builtins.code_actions.gitsigns,
					null_ls.builtins.code_actions.gomodifytags,

					null_ls.builtins.code_actions.shellcheck,               -- https://www.shellcheck.net/

            ${if cfg.codespell then ''
					null_ls.builtins.diagnostics.codespell.with({
						command = "${pkgs.codespell}/bin/codespell",
						extra_args = {
							"-I",
							vim.fn.expand("${./codespell-ignore}"),
						},
					}),
            '' else ""}

					null_ls.builtins.diagnostics.staticcheck,				-- https://github.com/dominikh/go-tools
					null_ls.builtins.formatting.fixjson,                    -- https://github.com/rhysd/fixjson
					null_ls.builtins.formatting.goimports_reviser,          -- https://pkg.go.dev/github.com/incu6us/goimports-reviser
					null_ls.builtins.formatting.markdown_toc,               -- https://github.com/jonschlinkert/markdown-toc
					null_ls.builtins.formatting.mdformat,                   -- https://github.com/executablebooks/mdformat
					null_ls.builtins.formatting.shfmt,                      -- https://github.com/mvdan/sh
					null_ls.builtins.formatting.yamlfmt                     -- https://github.com/google/yamlfmt
				}
			})

            ${if cfg.lightbulb then ''
            require'nvim-lightbulb'.update_lightbulb {
                sign = {
                    enabled                 = true,
                    priority                = 10,
                },
                float = {
                    enabled                 = false,
                    text                    = "💡",
                    win_opts                = {},
                },
                virtual_text = {
                    enable                  = false,
                    text                    = "💡",
                },
                status_text = {
                    enabled                 = false,
                    text                    = "💡",
                    text_unavailable        = ""           
                }
            }
            '' else ""}

            ${if cfg.bash then ''
            lspconfig.bashls.setup {
                cmd = {
                    "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server",
                    "start"
                }
            }
            '' else ""}

            ${if cfg.go then ''
            lspconfig.gopls.setup {
                cmd = {
                    "${pkgs.gopls}/bin/gopls"
                }
            } 
            '' else ""}

            ${if cfg.nix then ''
            lspconfig.rnix.setup{
                cmd             = { "${pkgs.rnix-lsp}/bin/rnix-lsp" }
            }
            '' else ""}

            ${if cfg.ruby then ''
            lspconfig.solargraph.setup{
                cmd             = {'${pkgs.solargraph}/bin/solargraph', 'stdio' }
            }
            '' else ""}

            ${if cfg.rust then ''
            lspconfig.rust_analyzer.setup{
                cmd             = {'${pkgs.rust-analyzer}/bin/rust-analyzer'}
            }
            '' else ""}

            ${if cfg.terraform then ''
            lspconfig.terraformls.setup{
                cmd             = {'${pkgs.terraform-ls}/bin/terraform-ls', 'serve' }
            }
            '' else ""}

            ${if cfg.typescript then ''
            lspconfig.tsserver.setup{
                cmd             = {'${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server', '--stdio' }
            }
            '' else ""}

            ${if cfg.vimscript then ''
            lspconfig.vimls.setup{
                cmd             = {'${pkgs.nodePackages.vim-language-server}/bin/vim-language-server', '--stdio' }
            }
            '' else ""}

            ${if cfg.yaml then ''
            lspconfig.vimls.setup{
                cmd             = {'${pkgs.nodePackages.yaml-language-server}/bin/yaml-language-server', '--stdio' }
            }
            '' else ""}

            ${if cfg.docker then ''
            lspconfig.dockerls.setup{
                cmd             = {'${pkgs.nodePackages.dockerfile-language-server-nodejs}/bin/docker-language-server', '--stdio' }
            }
            '' else ""}

            ${if cfg.css then ''
            lspconfig.cssls.setup{
                cmd             = {'${pkgs.nodePackages.vscode-css-languageserver-bin}/bin/css-languageserver', '--stdio' };
                filetypes       = { "css", "scss", "less" }; 
            }
            '' else ""}

            ${if cfg.html then ''
            lspconfig.html.setup{
                cmd             = {'${pkgs.nodePackages.vscode-html-languageserver-bin}/bin/html-languageserver', '--stdio' };
                filetypes       = { "html", "css", "javascript" }; 
            }
            '' else ""}

            ${if cfg.json then ''
            lspconfig.jsonls.setup{
                cmd             = {'${pkgs.nodePackages.vscode-json-languageserver-bin}/bin/json-languageserver', '--stdio' };
                filetypes       = { "html", "css", "javascript" }; 
            }
            '' else ""}

            ${if cfg.graphql then ''
            lspconfig.graphql.setup{
                cmd             = {'${nodePackages_latest.graphql-language-service-cli}/bin/graphql-lsp', 'server', '-m', 'stream' };
                filetypes       = { "html", "css", "javascript" }; 
            }
            '' else ""}


            ${if cfg.tex then ''
            lspconfig.texlab.setup{
                cmd             = {'${pkgs.texlab}/bin/texlab'}
            }
            '' else ""}

            ${if cfg.clang then ''
            -- This avoids conflicts with null-ls
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.offsetEncoding = { "utf-16" }

            lspconfig.clangd.setup{
                cmd             = {'${pkgs.clang-tools}/bin/clangd', '--background-index', '--limit-results=0'};
                capabilities    = capabilities;
                filetypes       = { "c", "cpp", "objc", "objcpp", "m" };

                on_new_config	= function(new_config, new_cwd)
                	local status, cmake = pcall(require, "cmake-tools")
                	if status then
                		cmake.clangd_on_new_config(new_config)
                	end
                end,
            }
            '' else ""}

            ${if cfg.python then ''
            lspconfig.pyright.setup{
                cmd             = {"${pkgs.nodePackages.pyright}/bin/pyright-langserver", "--stdio"}
            }
            '' else ""}
            '';
    };
}
