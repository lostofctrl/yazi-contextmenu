--- @since 25.2.7
-- Right-click context menu with file actions.

local ITEMS = {
	{ on = "o", desc = "Open",                emit = { "open", {} } },
	{ on = "O", desc = "Open with...",        emit = { "open", { interactive = true } } },
	{ on = "r", desc = "Rename",              emit = { "rename", {} } },
	{ on = "y", desc = "Copy (yank)",         emit = { "yank", {} } },
	{ on = "x", desc = "Cut",                 emit = { "yank", { cut = true } } },
	{ on = "p", desc = "Paste",               emit = { "paste", {} } },
	{ on = "a", desc = "New file / dir",      emit = { "create", {} } },
	{ on = "c", desc = "Copy path",           emit = { "copy", { "path" } } },
	{ on = "n", desc = "Copy filename",       emit = { "copy", { "filename" } } },
	{ on = "s", desc = "Toggle selection",    emit = { "toggle", {} } },
	{ on = "d", desc = "Trash",               emit = { "remove", {} } },
	{ on = "D", desc = "Delete permanently",  emit = { "remove", { permanently = true } } },
}

local M = {}

-- Floating menu state (one menu at a time).
local Menu = { open = false, x = 0, y = 0, hover = nil, rect = nil }

local function render() (ui.render or ya.render)() end

local function close()
	if Menu.open then
		Menu.open, Menu.hover, Menu.rect = false, nil, nil
		render()
	end
end

local function open_at(x, y)
	Menu.open, Menu.x, Menu.y, Menu.hover = true, x, y, nil
	render()
end

local function width()
	local w = 0
	for _, it in ipairs(ITEMS) do w = math.max(w, #it.desc) end
	return w + 4
end

-- Menu rect, clamped inside the screen.
local function menu_rect(area)
	local w, h = width(), #ITEMS
	local x = math.max(0, math.min(Menu.x + 1, area.w - w))
	local y = math.max(0, math.min(Menu.y, area.h - h))
	return { x = x, y = y, w = w, h = h }
end

local function item_at(event)
	local r = Menu.rect
	if r and event.x >= r.x and event.x < r.x + r.w and event.y >= r.y and event.y < r.y + r.h then
		return event.y - r.y + 1
	end
end

-- Modal child that draws the menu.
local MenuUI = { _id = "contextmenu" }

function MenuUI:new(area) return setmetatable({ _area = area }, { __index = self }) end
function MenuUI:reflow() return {} end

function MenuUI:redraw()
	if not Menu.open then return {} end
	local r = menu_rect(self._area)
	Menu.rect = r
	local base = ui.Style():fg("white"):bg("#2b2b2b")
	local sel = ui.Style():fg("black"):bg("#7aa2f7")
	local els = { ui.Clear(ui.Rect(r)) }
	for i, it in ipairs(ITEMS) do
		local line = " " .. it.desc .. string.rep(" ", r.w - #it.desc - 1)
		els[#els + 1] = ui.Text(line)
			:area(ui.Rect { x = r.x, y = r.y + i - 1, w = r.w, h = 1 })
			:style(i == Menu.hover and sel or base)
	end
	return els
end

-- Call once from init.lua.
function M:setup()
	Modal:children_add(MenuUI, 9000)

	-- Right-click on a file: select it and show the menu (instead of opening it).
	local left_click = Entity.click
	function Entity:click(event, up)
		if event.is_right then
			if not up then
				ya.emit("reveal", { self._file.url })
				open_at(event.x, event.y)
			end
		elseif left_click then
			return left_click(self, event, up)
		end
	end

	-- Menu captures clicks while open; middle-click on a file also opens it.
	local root_click = Root.click
	function Root:click(event, up)
		if Menu.open then
			if up then return end
			local i = item_at(event)
			close()
			if i then ya.emit(ITEMS[i].emit[1], ITEMS[i].emit[2]) end
			return
		end
		if event.is_middle and not up then
			local c = ya.child_at(ui.Rect { x = event.x, y = event.y }, self:reflow())
			if c and c._id == "current" and c._folder then
				local f = c._folder.window[event.y - c._area.y + 1]
				if f then
					ya.emit("reveal", { f.url })
					return open_at(event.x, event.y)
				end
			end
		end
		return root_click(self, event, up)
	end

	local root_scroll = Root.scroll
	function Root:scroll(event, step)
		if Menu.open then return close() end
		return root_scroll(self, event, step)
	end

	local root_move = Root.move
	function Root:move(event)
		if Menu.open then
			local i = item_at(event)
			if i ~= Menu.hover then Menu.hover = i; render() end
		end
		return root_move and root_move(self, event)
	end
end

function M:entry()
	local idx = ya.which { cands = ITEMS, silent = false }
	local item = idx and ITEMS[idx]
	if item then
		ya.emit(item.emit[1], item.emit[2])
	end
end

return M
