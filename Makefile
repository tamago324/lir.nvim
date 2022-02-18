.PHONY: lint

lint:
	luacheck lua

fmt:
	stylua --config-path stylua.toml --glob 'lua/**/*.lua' -- lua
