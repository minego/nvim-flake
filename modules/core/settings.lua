local o				= vim.o		-- options
local g				= vim.g		-- global options
local wo			= vim.wo	-- window options
local bo			= vim.bo	-- buffer options
local lo			= vim.opt_local

o.swapfile			= false

-- Do NOT unload hidden buffer
o.hidden			= true

o.ruler				= true
wo.signcolumn		= "yes"

-- If a buffer is open in another tab, switch to that instead of polluting the current tab
o.switchbuf			= "usetab,uselast"

g.mapleader			= "\\"
o.visualbell		= true	-- I'd prefer a flash over a beep
o.wildmenu			= true
o.wildmode			= "list:longest"

o.hlsearch			= true
o.incsearch			= true

o.smartcase			= true
o.hlsearch			= true
o.ignorecase		= true
o.title				= true
o.scrolloff			= 10
o.sidescrolloff		= 10
o.sidescroll		= 1
o.laststatus		= 3		-- Display a single status bar for all windows

wo.number			= false
wo.wrap				= false

wo.foldenable		= false

bo.textwidth		= 80
vim.opt.colorcolumn	= "80"

-- Ignore files of these types
o.wildignore		= "*.swp,*.o,*.la,*.lo,*.a"
o.suffixes			= o.wildignore

-- Improve the file browser
g.netrw_banner		= false
g.netrw_altv		= true	-- open splits to the right
g.netrw_preview		= true	-- preview split to the right
g.netrw_liststyle	= 3		-- tree view

-- I despise auto formatting, auto indent, etc.
-- 
-- Whenever opening any file, regardless of what plugins may do, turn that
-- shit off!l

-- Auto reload contents of a buffer
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI"}, {
	pattern = { "*" },
	callback = function()
		vim.api.nvim_command('checktime')
	end,
})

-- Show relative numbers in the active window, and absolute in others
vim.api.nvim_create_autocmd({"WinLeave"}, {
	pattern = { "*" },
	callback = function()
		wo.relativenumber	= false
		wo.number			= true
		wo.numberwidth		= 5
	end,
})
vim.api.nvim_create_autocmd({"BufEnter", "WinEnter"}, {
	pattern = { "*" },
	callback = function()
		wo.relativenumber	= true
		wo.number			= true
		wo.numberwidth		= 5
	end,
})

-- Show crosshairs but only in the active window
vim.api.nvim_create_autocmd({"WinLeave"}, {
	pattern = { "*" },
	callback = function()
		wo.cursorline		= false
		wo.cursorcolumn		= false
		o.signcolumn		= "no"
	end,
})
vim.api.nvim_create_autocmd({"BufEnter", "WinEnter"}, {
	pattern = { "*" },
	callback = function()
		wo.cursorline		= true
		wo.cursorcolumn		= true
		o.signcolumn		= "yes"
	end,
})

-- Help me spell
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
	pattern = { "*.txt", "*.md" },
	callback = function()
		lo.spell			= true
		lo.wrap				= true
	end,
})
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
	pattern = { "*.cmake", "CMakeLists.txt" },
	callback = function()
		lo.spell			= false
		lo.wrap				= false
	end,
})

-- I resize my terminal frequently
vim.api.nvim_create_autocmd({"VimResized"}, {
	pattern = { "*" },
	command = "wincmd ="
})

-- Terminal
vim.api.nvim_create_autocmd({"TermOpen", "TermEnter", "BufEnter"}, {
	pattern = { "term://*" },
	callback = function()
		wo.relativenumber	= false
		wo.number			= false
		o.signcolumn		= "no"

		vim.cmd([[ startinsert ]])
	end,
})

local wk = require("which-key")
wk.setup {}

-- Open a terminal with ^Z
wk.register({ ["<c-z>"] = { '<cmd>botright vsplit | terminal<CR><C-L>', "Open a Terminal" } }, { mode = "n", silent = true })

local domake = function(target)
	cmake = require("cmake-tools")

	if cmake.is_cmake_project() then
		if target == "clean" then
			vim.cmd([[ CMakeClean ]])
		elseif target == "all" then
			vim.cmd([[ CMakeBuild ]])
		elseif target == "clean all" then
			vim.cmd([[ CMakeBuild! ]])
		elseif target == "all install" then
			vim.cmd([[ CMakeInstall ]])
		elseif target == "clean all install" then
			vim.cmd([[ CMakeClean ]])
			vim.cmd([[ CMakeInstall ]])
		elseif target == "all test" then
			vim.cmd([[ CMakeRunTest ]])
		elseif target == "clean all test" then
			vim.cmd([[ CMakeClean ]])
			vim.cmd([[ CMakeRunTest ]])
		elseif target == "all debug" then
			vim.cmd([[ CMakeDebug ]])
		elseif target == "clean all debug" then
			vim.cmd([[ CMakeClean ]])
			vim.cmd([[ CMakeDebug ]])
		elseif target == "all run" then
			vim.cmd([[ CMakeRun ]])
		elseif target == "clean all run" then
			vim.cmd([[ CMakeClean ]])
			vim.cmd([[ CMakeRun ]])
		else
		end
	else
		vim.cmd("make " .. target)
	end
end

-- make
wk.register({
	["<leader>m"] = {
		name	= "make",

		c		= { function() domake("clean")				end, "make clean"				},
		C		= { function() domake("clean")				end, "make clean"				},

		a		= { function() domake("all")				end, "make all"					},
		A		= { function() domake("clean all")			end, "make clean all"			},

		i		= { function() domake("all install")		end, "make all install"			},
		I		= { function() domake("clean all install")	end, "make clean all install"	},

		t		= { function() domake("all test")			end, "make all test"			},
		T		= { function() domake("clean all test")		end, "make clean all test"		},

		d		= { function() domake("all debug")			end, "make all debug"			},
		D		= { function() domake("clean all debug")	end, "make clean all debug"		},

		r		= { function() domake("all run")			end, "make all run"				},
		R		= { function() domake("clean all run")		end, "make clean all run"		},
	},
},  { mode = "n" })

-- Ignore F1 because it is too close to the escape key
wk.register({ ["<F1>"] = { "<cmd><CR>", "Ignored" } }, { mode = "n", silent = true })
wk.register({ ["<F1>"] = { "<cmd><CR>", "Ignored" } }, { mode = "i", silent = true })

-- Change directory
wk.register({
	["<leader>"] = {
		name	= "Change current directory",

		["cd"]	= { "<cmd>tcd %:p:h<CR>",				"Switch the current directory to that of the current file only for the current tab" },
		["lcd"]	= { "<cmd>lcd %:p:h<CR>",				"Switch the current directory to that of the current file only for the current window" },
	}
}, { mode = "n" })

-- Quickfix
wk.register({
	["]q"]		= { "<cmd>cnext<cr>",					"Jump to next warning or error" },
	["[q"]		= { "<cmd>cprev<cr>",					"Jump to prev warning or error" },
}, { mode = "n", silent = true })

wk.register({ ["<leader>w"]	= { "<cmd>wincmd w<CR>", "Select next window" } }, { mode = "n", silent = true })
wk.register({ ["<leader>W"]	= { "<cmd>wincmd W<CR>", "Select prev window" } }, { mode = "n", silent = true })

-- Split helpers
wk.register({ ["<leader>s"]	= { "<cmd>wincmd s<CR>", ":split"  } }, { mode = "n", silent = true })
wk.register({ ["<leader>v"]	= { "<cmd>wincmd v<CR>", ":vsplit" } }, { mode = "n", silent = true })

wk.register({ ["<leader>S"]	= { ":split  <C-R>=expand('%:p:h').'/'<CR>", ":split ..."	} }, { mode = "n", silent = false })
wk.register({ ["<leader>V"]	= { ":vsplit <C-R>=expand('%:p:h').'/'<CR>", ":vsplit ..."	} }, { mode = "n", silent = false })
wk.register({ ["<leader>e"]	= { ":edit   <C-R>=expand('%:p:h').'/'<CR>", ":edit ..."	} }, { mode = "n", silent = false })

-- Terminal
wk.register({ ["<esc><esc>"]= { "<c-\\><c-n>",			"Escape with double escape"	} }, { mode = "t", silent = false })
wk.register({ ["<c-w>"]     = { "<c-\\><c-n><c-w>",		"Treat <c-w> like any other window"	} }, { mode = "t", silent = false })

