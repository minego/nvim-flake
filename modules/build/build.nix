{ pkgs, config, lib, ...}:
with lib;
with builtins;

let
    cfg = config.vim.buildtools;
in {
    options.vim.buildtools = {
		cmake = {
			enable									= mkEnableOption "CMake Tools";
		};
	};

    config = mkIf cfg.cmake.enable {
        vim.startPlugins = with pkgs.neovimPlugins; [ 
			cmake-tools
			nvim-notify
		];

        vim.luaConfigRC = ''
			require("notify").setup({
				background_colour = "#000000",
			})

            require("cmake-tools").setup {
            	cmake_regenerate_on_save			= false,
            
            	cmake_generate_options				= { "-G", "Ninja", "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
            	cmake_build_options					= {},
            
            	-- cmake_build_directory				= "build/''${variant:buildType}",
            	cmake_build_directory				= "build",
            
            	cmake_soft_link_compile_commands	= false,
            	cmake_compile_commands_from_lsp		= true,
            
            	cmake_dap_configuration = {
            		name							= "c",
            		type							= "lldb",
            		request							= "launch",
            		stopOnEntry						= false,
            		runInTerminal					= true,
            		console							= "integratedTerminal",
            	},
            
            	cmake_executor = {
            		name							= "quickfix",
            		opts = {
            			show						= "always",
            			-- show						= "only_on_error",
						auto_close_when_success		= true,

            			position					= "bot",
            			size						= 40,
            			encoding					= "utf-8",
            		},
            	},
            	cmake_terminal = {
            		name							= "terminal",
            		opts = {
            			name						= "CMake Terminal",
            			prefix_name					= "[CMakeTools] ",
            			split_direction				= "horizontal",
            			split_size					= 40,
            
            			-- Window handling
            			single_terminal_per_instance= true,
            			single_terminal_per_tab		= true,
            			keep_terminal_static_location= true,
            
            			-- Running Tasks
            			start_insert_in_launch_task	= true,
            			start_insert_in_other_tasks	= false,
            			focus_on_launch_terminal	= true,

						do_not_add_newline			= true,
            		},
            	},
            	cmake_notifications = {
            		enabled							= true,
            		spinner							= { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
            		refresh_rate_ms					= 100,
            	},
            }
            '';
    };
}

