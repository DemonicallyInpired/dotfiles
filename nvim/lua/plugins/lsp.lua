return {
	-- Main LSP Configuration
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for Neovim
		{ "williamboman/mason.nvim", opts = {} },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		-- Useful status updates for LSP.
		{ "j-hui/fidget.nvim", opts = {} },
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("gd", require("fzf-lua").lsp_definitions, "[G]oto [D]efinition")
				map("gr", require("fzf-lua").lsp_references, "[G]oto [R]eferences")
				map("gI", require("fzf-lua").lsp_implementations, "[G]oto [I]mplementation")
				map("<leader>D", require("fzf-lua").lsp_typedefs, "Type [D]efinition")
				map("<leader>ds", require("fzf-lua").lsp_document_symbols, "[D]ocument [S]ymbols")
				map("<leader>ws", require("fzf-lua").lsp_live_workspace_symbols, "[W]orkspace [S]ymbols")
				map("<leader>cr", vim.lsp.buf.rename, "[R]e[n]ame")
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

				local function client_supports_method(client, method, bufnr)
					if vim.fn.has("nvim-0.11") == 1 then
						return client:supports_method(method, bufnr)
					else
						return client.supports_method(method, { bufnr = bufnr })
					end
				end

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if
					client
					and client_supports_method(
						client,
						vim.lsp.protocol.Methods.textDocument_documentHighlight,
						event.buf
					)
				then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end

				if
					client
					and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
				then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		vim.diagnostic.config({
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			underline = { severity = vim.diagnostic.severity.ERROR },
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			},
			virtual_text = {
				source = "if_many",
				spacing = 2,
				format = function(diagnostic)
					local diagnostic_message = {
						[vim.diagnostic.severity.ERROR] = diagnostic.message,
						[vim.diagnostic.severity.WARN] = diagnostic.message,
						[vim.diagnostic.severity.INFO] = diagnostic.message,
						[vim.diagnostic.severity.HINT] = diagnostic.message,
					}
					return diagnostic_message[diagnostic.severity]
				end,
			},
		})

		local original_capabilities = vim.lsp.protocol.make_client_capabilities()
		local capabilities = require("blink.cmp").get_lsp_capabilities(original_capabilities)

		local servers = {
			bashls = {},
			marksman = {},
			clangd = {},
			pyright = {},
			cssls = {},
			ts_ls = {
				enabled = false,
			},
			vtsls = {
				cmd = { vim.fn.stdpath("data") .. "/mason/bin/vtsls", "--stdio" },

				-- explicitly add default filetypes, so that we can extend
				-- them in related extras
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
				single_file_support = true,
				root_dir = function(fname)
					local util = require("lspconfig.util")
					return util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")(fname)
						or util.path.dirname(fname)
				end,
				settings = {
					complete_function_calls = true,
					vtsls = {
						enableMoveToFileCodeAction = true,
						autoUseWorkspaceTsdk = true,
						experimental = {
							maxInlayHintLength = 30,
							completion = {
								enableServerSideFuzzyMatch = true,
							},
						},
					},
					typescript = {
						updateImportsOnFileMove = { enabled = "always" },
						suggest = {
							completeFunctionCalls = true,
						},
						inlayHints = {
							enumMemberValues = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							parameterNames = { enabled = "literals" },
							parameterTypes = { enabled = true },
							propertyDeclarationTypes = { enabled = true },
							variableTypes = { enabled = false },
						},
					},
				},
				keys = {
					{
						"gD",
						function()
							local params = vim.lsp.util.make_position_params()
							vim.lsp.buf.execute_command({
								command = "typescript.goToSourceDefinition",
								arguments = { params.textDocument.uri, params.position },
							})
						end,
						desc = "Goto Source Definition",
					},
					{
						"gR",
						function()
							vim.lsp.buf.execute_command({
								command = "typescript.findAllFileReferences",
								arguments = { vim.uri_from_bufnr(0) },
							})
						end,
						desc = "File References",
					},
					{
						"<leader>co",
						function()
							vim.lsp.buf.execute_command({
								command = "source.organizeImports",
								arguments = { vim.uri_from_bufnr(0) },
							})
						end,
						desc = "Organize Imports",
					},
					{
						"<leader>cM",
						function()
							vim.lsp.buf.execute_command({
								command = "source.addMissingImports.ts",
								arguments = { vim.uri_from_bufnr(0) },
							})
						end,
						desc = "Add missing imports",
					},
					{
						"<leader>cu",
						function()
							vim.lsp.buf.execute_command({
								command = "source.removeUnused.ts",
								arguments = { vim.uri_from_bufnr(0) },
							})
						end,
						desc = "Remove unused imports",
					},
					{
						"<leader>cD",
						function()
							vim.lsp.buf.execute_command({
								command = "source.fixAll.ts",
								arguments = { vim.uri_from_bufnr(0) },
							})
						end,
						desc = "Fix all diagnostics",
					},
					{
						"<leader>cV",
						function()
							vim.lsp.buf.execute_command({
								command = "typescript.selectTypeScriptVersion",
								arguments = { vim.uri_from_bufnr(0) },
							})
						end,
						desc = "Select TS workspace version",
					},
				},
			},
			html = {},
			yamlls = {
				settings = {
					ymal = { keyordering = false },
				},
			},
			lua_ls = {},
		}

		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			"stylua",
			"prettier",
			"prettierd",
			"isort",
		})
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		require("mason-lspconfig").setup({
			ensure_installed = {},
			automatic_installation = false,
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,
				["vtsls"] = function(server_name)
					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})

					local prev_on_attach = server.on_attach
					server.on_attach = function(client, bufnr)
						if prev_on_attach then
							pcall(prev_on_attach, client, bufnr)
						end
						client.commands["_typescript.moveToFileRefactoring"] = function(command)
							---@type string, string, lsp.Range
							local action, uri, range = unpack(command.arguments)

							local function move(newf)
								client.request("workspace/executeCommand", {
									command = command.command,
									arguments = { action, uri, range, newf },
								})
							end

							local fname = vim.uri_to_fname(uri)
							client.request("workspace/executeCommand", {
								command = "typescript.tsserverRequest",
								arguments = {
									"getMoveToRefactoringFileSuggestions",
									{
										file = fname,
										startLine = range.start.line + 1,
										startOffset = range.start.character + 1,
										endLine = range["end"].line + 1,
										endOffset = range["end"].character + 1,
									},
								},
							}, function(_, result)
								---@type string[]
								local files = result.body.files
								table.insert(files, 1, "Enter new path...")
								vim.ui.select(files, {
									prompt = "Select move destination:",
									format_item = function(f)
										return vim.fn.fnamemodify(f, ":~:.")
									end,
								}, function(f)
									if f and f:find("^Enter new path") then
										vim.ui.input({
											prompt = "Enter move destination:",
											default = vim.fn.fnamemodify(fname, ":h") .. "/",
											completion = "file",
										}, function(newf)
											return newf and move(newf)
										end)
									elseif f then
										move(f)
									end
								end)
							end)
						end
					end
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})

		-- Fallback: ensure vtsls is set up even if mason-lspconfig handler didn't run
		do
			local lspconfig = require("lspconfig")
			local server = vim.tbl_deep_extend("force", {}, servers.vtsls or {})
			server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
			local prev_on_attach = server.on_attach
			server.on_attach = function(client, bufnr)
				if prev_on_attach then
					pcall(prev_on_attach, client, bufnr)
				end
				client.commands["_typescript.moveToFileRefactoring"] = function(command)
					---@type string, string, lsp.Range
					local action, uri, range = unpack(command.arguments)

					local function move(newf)
						client.request("workspace/executeCommand", {
							command = command.command,
							arguments = { action, uri, range, newf },
						})
					end

					local fname = vim.uri_to_fname(uri)
					client.request("workspace/executeCommand", {
						command = "typescript.tsserverRequest",
						arguments = {
							"getMoveToRefactoringFileSuggestions",
							{
								file = fname,
								startLine = range.start.line + 1,
								startOffset = range.start.character + 1,
								endLine = range["end"].line + 1,
								endOffset = range["end"].character + 1,
							},
						},
					}, function(_, result)
						---@type string[]
						local files = result.body.files
						table.insert(files, 1, "Enter new path...")
						vim.ui.select(files, {
							prompt = "Select move destination:",
							format_item = function(f)
								return vim.fn.fnamemodify(f, ":~:.")
							end,
						}, function(f)
							if f and f:find("^Enter new path") then
								vim.ui.input({
									prompt = "Enter move destination:",
									default = vim.fn.fnamemodify(fname, ":h") .. "/",
									completion = "file",
								}, function(newf)
									return newf and move(newf)
								end)
							elseif f then
								move(f)
							end
						end)
					end)
				end
			end

			lspconfig.vtsls.setup(server)
		end
	end,
}
