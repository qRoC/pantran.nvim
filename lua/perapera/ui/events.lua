local utils = require("perapera.utils")
local actions = require("perapera.ui.actions")

local events = {
  timeout = 300
}

local function timeout_translate(window, state)
  state.timer:start(events.timeout, 0, vim.schedule_wrap(function()
    local input = window.prop.input
    if input ~= state.previous_input then
      actions.translate(window)
      state.previous_input = input
    end
  end))
end

events.events = {
  CursorMoved = timeout_translate,
  CursorMovedI = timeout_translate,
  VimResized = actions.resize,
  BufLeave = {actions.close, once = true}
}

function events.setup(window, bufnr)
  local state = {
    timer = vim.loop.new_timer(),
    previous_input = window.prop.input
  }
  -- BufEnter
  actions.translate(window)

  for event, handler in pairs(events.events) do
    local action, args = handler, {}
    if type(handler) == "table" then
      handler = vim.deepcopy(handler)
      action = table.remove(handler)
      args = handler
    end
    utils.buf_autocmd(bufnr, vim.tbl_extend("keep", args, {
      events = event,
      nested = true,
      callback = function() action(window, state) end
    }))
  end
end

return events
