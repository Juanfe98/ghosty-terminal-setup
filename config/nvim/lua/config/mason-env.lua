-- Make Mason use public npm registry (without touching your shell/company ~/.npmrc)
local mason_npmrc = vim.fn.stdpath("config") .. "/npmrc.mason"

if vim.fn.filereadable(mason_npmrc) == 0 then
	vim.fn.writefile({
		"registry=https://registry.npmjs.org/",
		"always-auth=false",
	}, mason_npmrc)
end

-- npm reads config from env vars (case-insensitive)
vim.env.NPM_CONFIG_USERCONFIG = mason_npmrc
vim.env.npm_config_userconfig = mason_npmrc
vim.env.NPM_CONFIG_REGISTRY = "https://registry.npmjs.org/"
vim.env.npm_config_registry = "https://registry.npmjs.org/"
vim.env.NPM_CONFIG_ALWAYS_AUTH = "false"
vim.env.npm_config_always_auth = "false"
