local wk		= require("which-key")
local dap		= require('dap')
local dapui		= require('dapui')
local telescope	= require('telescope')

-- DAP bindings to try to match other debuggers

-- <F5> Start/Continue
local function f5()
	require'dap.ext.vscode'.load_launchjs()
	require'dap'.continue()
end

-- <S-F5> Terminate
local function f17()
	require'dap'.terminate()
	require'dap'.close()
	require'nvim-dap-virtual-text'.refresh()

	require('dap').repl.close()	
	require('dapui').close()
end

-- <F9> Toggle breakpoint
local function f9()
	require'dap'.toggle_breakpoint()
end

-- <F10> Step over
local function f10()
	require'dap'.step_over()
end

-- <F11> Step into
local function f11()
	require'dap'.step_into()
end

-- <S-F11> / <S-F12> Step out
local function f12()
	require'dap'.step_out()
end


wk.register({ ["<F5>" ] = { f5, "Debugger: Continue"			} }, { mode = "n", silent = true })
wk.register({ ["<F5>" ] = { f5, "Debugger: Continue"			} }, { mode = "i", silent = true })

-- <S-F5> Shift adds 12 to the number for function keys
wk.register({ ["<F17>"]	= { f17, "Debugger: Terminate"			} }, { mode = "n", silent = true })
wk.register({ ["<F17>"]	= { f17, "Debugger: Terminate"			} }, { mode = "i", silent = true })

wk.register({ ["<F9>" ] = { f9, "Debugger: Toggle Breakpoint"	} }, { mode = "n", silent = true })
wk.register({ ["<F9>" ] = { f9, "Debugger: Toggle Breakpoint"	} }, { mode = "i", silent = true })

wk.register({ ["<F10>"] = { f10, "Debugger: Step Over"			} }, { mode = "n", silent = true })
wk.register({ ["<F10>"] = { f10, "Debugger: Step Over"			} }, { mode = "i", silent = true })

wk.register({ ["<F11>"] = { f11, "Debugger: Step Into"			} }, { mode = "n", silent = true })
wk.register({ ["<F11>"] = { f11, "Debugger: Step Into"			} }, { mode = "i", silent = true })

				-- <S-F11> Shift adds 12 to the number for function keys
wk.register({ ["<F23>"] = { f12, "Debugger: Step Out"			} }, { mode = "n", silent = true })
wk.register({ ["<F23>"] = { f12, "Debugger: Step Out"			} }, { mode = "i", silent = true })
wk.register({ ["<F12>"] = { f12, "Debugger: Step Out"			} }, { mode = "n", silent = true })
wk.register({ ["<F12>"] = { f12, "Debugger: Step Out"			} }, { mode = "i", silent = true })


-- DAP bindings using <leader>d in a group
wk.register({
	["<leader>d"] = {
		name = "Debugger",

		c = { f5,  "(F5)    Continue"			},
		n = { f10, "(F10)   Next"				},
		s = { f11, "(F11)   Step"				},
		s = { f12, "(F12)   Finish"				},
		q = { f17, "(S-F5)  Terminate"			},

		b = { f9,  "(F9)    Toggle Breakpoint"	},


		r = { function() require'dap'.repl.open()								end, "Open REPL"				},
		u = { function() require'dapui'.toggle()								end, "Toggle UI"				},
		X = { function() require'dap'.clear_breakpoints()						end, "Clear Breakpoint"			},
		C = { function() 
				require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))()
																				end, "Conditional Breakpoint"	},
		t = { function() 
				require('dap-go').debug_test()
																				end, "Debug Test"				},

		k = { function() require'telescope'.extensions.dap.frames{}				end, "Backtrace"				},
		B = { function() require'telescope'.extensions.dap.list_breakpoints{}	end, "List Breakpoints"			},
		v = { function() require'telescope'.extensions.dap.variables{}			end, "Variables"				},

		e = { "<cmd>vsplit .vscode/launch.json<CR>",								 "Edit launch.json"			},

		["<tab>"] = { function() require('dap.ui.widgets').preview()			end, "View value under cursor"	},
	}
}, { mode = "n", silent = true })

-- Let's make it prettier
vim.api.nvim_set_hl(0, 'DapBreakpoint',			{ ctermbg = 0, fg = '#993939', bg = '#31353f' })
vim.api.nvim_set_hl(0, 'DapLogPoint',			{ ctermbg = 0, fg = '#61afef', bg = '#31353f' })
vim.api.nvim_set_hl(0, 'DapStopped',			{ ctermbg = 0, fg = '#98c379', bg = '#31353f' })

vim.fn.sign_define('DapStopped',				{ text='', texthl='DapStopped',	linehl='DapStopped',	numhl='DapStopped'		})
vim.fn.sign_define('DapBreakpoint',				{ text='', texthl='DapBreakpoint',	linehl='DapBreakpoint',	numhl='DapBreakpoint'	})
vim.fn.sign_define('DapBreakpointCondition',	{ text='', texthl='DapBreakpoint',	linehl='DapBreakpoint',	numhl='DapBreakpoint'	})
vim.fn.sign_define('DapBreakpointRejected',		{ text='', texthl='DapBreakpoint',	linehl='DapBreakpoint',	numhl='DapBreakpoint'	})
vim.fn.sign_define('DapLogPoint',				{ text='', texthl='DapLogPoint',	linehl='DapLogPoint',	numhl='DapLogPoint'		})


dap.listeners.after.event_initialized["my_config"] = function()
  -- require('dapui').open()
	require('dap').repl.open()	
end

dap.listeners.after.event_terminated["my_config"] = function()
	require('dap').repl.close()	
	require('dapui').close()
end
dap.listeners.after.event_exited["my_config"] = function()
	require('dap').repl.close()	
	require('dapui').close()
end

vim.api.nvim_create_autocmd( "FileType", {
	pattern = "dap-repl",
	callback = function()
		-- Leave this off... It is annoying
		-- require('dap.ext.autocompl').attach()

		vim.wo.relativenumber	= false
		vim.wo.number			= false
		vim.o.signcolumn		= "no"

		vim.cmd([[ startinsert ]])
	end,
})

-- DAP UI
dapui.setup({
	icons = { expanded = "▾", collapsed = "▸" },

	mappings = {
		-- Use a table to apply multiple mappings
		expand	= { "<CR>", "<2-LeftMouse>" },
		open	= "o", remove = "d", edit = "e", repl = "r", toggle = "t",
	},
	expand_lines = true,

	layouts = {{
		elements = {
			-- Elements can be strings or table with id and size keys.
			{ id = "scopes", size = 0.25 },
			-- "breakpoints",
			"stacks",
			-- "watches",
			-- "repl",
			-- "console",
		},

		size = 80, -- 80 columns
		position = "left",
	}},
	floating = {
		max_height = nil, -- These can be integers or a float between 0 and 1.
		max_width = nil, -- Floats will be treated as percentage of your screen.
		border = "single", -- Border style. Can be "single", "double" or "rounded"
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
	windows = { indent = 1 },
	render = {
		max_type_length = nil, -- Can be integer or nil.
	}
})

-- Telescope DAP
telescope.load_extension('dap')

