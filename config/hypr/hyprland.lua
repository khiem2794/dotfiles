-- Host-specific variables and environment, provided by each host's home.nix.
local configDir = os.getenv("HOME") .. "/.config/hypr"

local function try_dofile(path)
	local ok, result = pcall(dofile, path)
	if ok then
		return result
	end
	return nil
end

local envVars = try_dofile(configDir .. "/env.lua") or {}
for name, value in pairs(envVars) do
	hl.env(name, tostring(value))
end

local hostVars = try_dofile(configDir .. "/var.lua") or {}

---- VARS ----
local quickshell = require(hostVars.qs_shell or "qs-noctalia")
local terminal = "kitty"
local fileManager = "kitty -e yazi"
local screenshot = "flameshot gui"
local browser = hostVars.browser or "firefox"
local vscode = "code"
local books = "kitty -e bookokrat -d ~/Documents/Books"
local resizeUnit = 25
local bar = quickshell.bar
local toggleBar = quickshell.toggleBar
local toggleNotifications = quickshell.toggleNotifications
local toggleLauncher = quickshell.toggleLauncher
local togglePowermenu = quickshell.togglePowermenu
local toggleNotepad = quickshell.toggleNotepad

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
	hl.exec_cmd(bar)
	hl.exec_cmd("fcitx5 -d")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("flameshot")
end)

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "",
	mode = "1920x1080@60",
	position = "0x0",
	scale = 1,
})

hl.gesture({
	fingers = 3,
	direction = "vertical",
	action = "workspace",
})
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "scroll_move",
})

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 3,
		border_size = 2,
		resize_on_border = true,
		layout = "scrolling",
		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,
	},

	decoration = {
		rounding = 25,
		rounding_power = 1.0,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		dim_special = 0.65,
		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 2,
		focus_on_close = 2,

		sensitivity = 0.5, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = true,
		},
	},

	binds = {
		scroll_event_delay = 100,
	},

	animations = {
		enabled = true,
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/
hl.config({
	master = {
		new_status = "master",
	},
	dwindle = {
		preserve_split = true,
		force_split = 2,
	},
	scrolling = {
		fullscreen_on_one_column = false,
		direction = "right",
		column_width = 0.5,
		explicit_column_widths = "0.5, 1.0",
		follow_min_visible = 1.0,
		follow_focus = true,
	},
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
-- Custom curves
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })
hl.curve("woa", { type = "bezier", points = { { 0, 0 }, { 0, 1 } } })
hl.curve("overshoot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "windows", enabled = true, speed = 1.5, bezier = "overshoot", style = "popin" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.5, bezier = "overshoot", style = "slidefadevert" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

---- KEYBINDINGS ----
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER"
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + C", hl.dsp.window.center())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(terminal))
-- hl.bind(
-- 	mainMod .. " + BACKSPACE",
-- 	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
-- )
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(vscode))
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(screenshot))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(screenshot))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(books))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ direction = "right" }), { repeatable = true })
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ direction = "left" }), { repeatable = true })

hl.bind("CTRL" .. " + ESCAPE", hl.dsp.exec_cmd(toggleBar))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(toggleLauncher))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(toggleNotifications))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(toggleNotepad))
hl.bind(mainMod .. " + BACKSPACE", hl.dsp.exec_cmd(togglePowermenu))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + GRAVE", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + GRAVE", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing windows + workspaces
hl.bind(mainMod .. " + SHIFT + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + mouse_up", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.focus({ workspace = "e+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.layout("colresize +conf"))

hl.bind(mainMod .. " + minus", hl.dsp.window.resize({ x = -resizeUnit, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + equal", hl.dsp.window.resize({ x = resizeUnit, y = 0, relative = true }), { repeating = true })

hl.bind(mainMod .. " + bracketleft", hl.dsp.layout("consume_or_expel prev"))
hl.bind(mainMod .. " + bracketright", hl.dsp.layout("consume_or_expel next"))
hl.bind(mainMod .. " + DELETE", hl.dsp.exit())

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true }) -- Requires playerctl
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

---- WINDOWS AND WORKSPACES ----
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps.
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(true)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- hl.window_rule({
-- 	name = "move-hyprland-run",
-- 	match = { class = "hyprland-run" },
-- 	float = true,
-- 	move = "20 monitor_h-120",
-- })

hl.window_rule({
	match = { title = "^(Picture-in-Picture|Picture in picture)$", float = false },
	pin = true,
	float = true,
	size = { "(monitor_w*0.1)", "(monitor_h*0.1)" },
})
hl.window_rule({
	match = { title = "^(Save screenshot)$", float = false },
	float = true,
	size = { "(monitor_w*0.4)", "(monitor_h*0.5)" },
})
hl.window_rule({
	match = {
		float = false,
		class = "^(firefox|brave|chrome|chromium|vivaldi)$",
		title = "^(Popup|Picture-in-Picture|Extension|Dropdown|Menu|Picture in picture)$",
	},
	pin = true,
	float = true,
})
hl.window_rule({
	match = { class = ".*(imv|mpv|vlc|Nautilus|flameshot)$" },
	float = true,
	center = true,
	size = { "(monitor_w*0.5)", "(monitor_h*0.5)" },
})
