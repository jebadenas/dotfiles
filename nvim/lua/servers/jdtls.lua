-- Java language server (jdtls). Requires the `jdtls` binary + Java 21+.
vim.lsp.config("jdtls", {
	settings = {
		java = {
			project = {
				-- also pick up jars in resources/ (COMPSCI 701 Kalah assignments
				-- keep JUnit + test-support jars there, not just lib/)
				referencedLibraries = { "lib/**/*.jar", "resources/**/*.jar" },
			},
		},
	},
})
