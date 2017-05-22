function love.conf(t)
    t.console = true
    t.window.width = 1280--640--
    t.window.height = 720--768--
    t.window.fullscreen = false
    t.window.borderless = false         -- Remove all border visuals from the window (boolean)
    t.window.resizable = true          -- Let the window be user-resizable (boolean)

    t.console = true --for windows debugging
    t.window.vsync = true
end
