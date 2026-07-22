local state_file = "/tmp/hypr-show-desktop"

local function minimize_all()
    local active = hl.get_active_workspace()
    local orig_id = active.id

    local f = io.open(state_file, "w")
    f:write(tostring(orig_id))
    f:close()

    local windows = hl.get_windows()
    for _, w in ipairs(windows) do
        if w.workspace.id == orig_id and w.mapped then
            hl.dispatch(hl.dsp.window.move({
                address = w.address,
                workspace = "special:desktop"
            }))
        end
    end

    hl.dispatch(hl.dsp.workspace.toggle_special("desktop"))
end

local function restore_all()
    local f = io.open(state_file, "r")
    if not f then return end
    local orig_id = tonumber(f:read("*l"))
    f:close()

    local windows = hl.get_windows()
    for _, w in ipairs(windows) do
        if w.workspace.name == "special:desktop" then
            hl.dispatch(hl.dsp.window.move({
                address = w.address,
                workspace = tostring(orig_id)
            }))
        end
    end

    hl.dispatch(hl.dsp.focus({ workspace = orig_id }))
    os.remove(state_file)
end

local f = io.open(state_file, "r")
if f then
    f:close()
    restore_all()
else
    minimize_all()
end
