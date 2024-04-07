return {
	RunDebug = {
		terminal_commands = {
			[1] = {
				"cargo run",
			},
		},
	},
	RunRelease = {
		terminal_commands = {
			[1] = {
				"cargo run --release",
			},
		},
	},
	BuildDebug = {
		terminal_commands = {
			[1] = {
				"cargo build",
			},
		},
	},
	BuildRelease = {
		terminal_commands = {
			[1] = {
				"cargo build --release",
			},
		},
	},
	Update = {
		terminal_commands = {
			[1] = {
				"cargo update",
			},
		},
	},
	Test = {
		terminal_commands = {
			[1] = {
				"cargo test",
			},
		},
	},
	Clean = {
		terminal_commands = {
			[1] = {
				"cargo clean",
			},
		},
	},
	Clippy = {
		terminal_commands = {
			[1] = {
				"cargo clippy",
			},
		},
	},
	Check = {
		terminal_commands = {
			[1] = {
				"cargo check",
			},
		},
	},
	Format = {
		terminal_commands = {
			[1] = {
				"cargo fmt",
			},
		},
	},
}
