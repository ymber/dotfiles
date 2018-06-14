require "cairo"

rings = {
    {
        name = "time",
        arg = "%S",
        max = 60,
        bg_rgba = {1, 1, 1, 0.1},
        fg_rgba = {1, 1, 1, 0.6},
        x = 110,
        y = 160,
        radius = 65,
        thickness = 4,
        start_angle = -(math.pi / 2),
        end_angle = math.pi * (3 / 2)
    },
    {
        name = "cpu",
        arg = "cpu1",
        max = 100,
        bg_rgba = {1, 1, 1, 0.2},
        fg_rgba = {1, 1, 1, 0.5},
        x = 110,
        y = 160,
        radius = 75,
        thickness = 5,
        start_angle = math.pi * (1 / 36),
        end_angle = math.pi * (2 / 3)
    },
    {
        name = "cpu",
        arg = "cpu2",
        max = 100,
        bg_rgba = {1, 1, 1, 0.2},
        fg_rgba = {1, 1, 1, 0.5},
        x = 110,
        y = 160,
        radius = 81,
        thickness = 5,
        start_angle = math.pi * (1 / 36),
        end_angle = math.pi * (2 / 3)
    },
    {
        name = "cpu",
        arg = "cpu3",
        max = 100,
        bg_rgba = {1, 1, 1, 0.2},
        fg_rgba = {1, 1, 1, 0.5},
        x = 110,
        y = 160,
        radius = 87,
        thickness = 5,
        start_angle = math.pi * (1 / 36),
        end_angle = math.pi * (2 / 3)
    },
    {
        name = "cpu",
        arg = "cpu4",
        max = 100,
        bg_rgba = {1, 1, 1, 0.2},
        fg_rgba = {1, 1, 1, 0.5},
        x = 110,
        y = 160,
        radius = 93,
        thickness = 5,
        start_angle = math.pi * (1 / 36),
        end_angle = math.pi * (2 / 3)
    },
    {
        -- Left side bar of CPU graph
        name = "cpu",
        arg = "",
        max = 100,
        bg_rgba = {1, 1, 1, 0.7},
        fg_rgba = {1, 1, 1, 0},
        x = 110,
        y = 160,
        radius = 130,
        thickness = 2,
        start_angle = -( math.pi * ( 1 / 14 ) ),
        end_angle = math.pi * ( 1 / 14 )
    },
    {
        -- Right side bar of CPU graph
        name = "cpu",
        arg = "",
        max = 100,
        bg_rgba = {1, 1, 1, 0.7},
        fg_rgba = {1, 1, 1, 0},
        x = 110,
        y = 160,
        radius = 430,
        thickness = 2,
        start_angle = -( math.pi * ( 1 / 48 ) ),
        end_angle = math.pi * ( 1 / 48 )
    },
    {
        name = "memperc",
        arg = "",
        max = 100,
        bg_rgba = {1, 1, 1, 0.3},
        fg_rgba = {1, 1, 1, 0.6},
        x = 110,
        y = 160,
        radius = 84,
        thickness = 22.5,
        start_angle = math.pi * (25 / 36),
        end_angle = math.pi * (4 / 3)
    },
    {
        name = "fs_used_perc",
        arg = "/",
        max = 100,
        bg_rgba = {1, 1, 1, 0.2},
        fg_rgba = {1, 1, 1, 0.5},
        x = 110,
        y = 160,
        radius = 105,
        thickness = 5,
        start_angle = -( math.pi * ( 17 / 36 ) ),
        end_angle = math.pi * (1 / 6)
    },
    {
        name = "fs_used_perc",
        arg = "/home",
        max = 100,
        bg_rgba = {1, 1, 1, 0.2},
        fg_rgba = {1, 1, 1, 0.5},
        x = 110,
        y = 160,
        radius = 105,
        thickness = 5,
        start_angle = -( math.pi * ( 7 / 6 ) ),
        end_angle = -( math.pi * ( 19 / 36 ) )
    }
}

function draw_ring( context, ring, percent )
    local filled_arc_length = ( ring["end_angle"] - ring["start_angle"] ) * percent

    -- Draw arc background
    cairo_set_source_rgba( context, unpack( ring["bg_rgba"] ) )
    cairo_arc( context, ring["x"], ring["y"], ring["radius"], ring["start_angle"], ring["end_angle"] )
    cairo_set_line_width( context, ring["thickness"] )
    cairo_stroke( context )

    -- Draw arc foreground
    cairo_set_source_rgba( context, unpack( ring["fg_rgba"] ) )
    cairo_arc( context, ring["x"], ring["y"], ring["radius"], ring["start_angle"], ring["start_angle"] + filled_arc_length )
    cairo_stroke( context )

end

function ring_data(ring)
    -- Returns the percent used value for the ring's conky variable and argument
    local value_str = conky_parse( string.format( "${%s %s}", ring[ "name" ], ring[ "arg" ] ) )
    return tonumber( value_str ) / ring[ "max" ]
end

function conky_rings()
    if conky_window == nil then return end

    local cairo_surface = cairo_xlib_surface_create( conky_window.display,
                                                     conky_window.drawable,
                                                     conky_window.visual,
                                                     conky_window.width,
                                                     conky_window.height )
    local cairo_context = cairo_create( cairo_surface )

    for i in pairs( rings ) do
        draw_ring( cairo_context, rings[i], ring_data( rings[i] ) )
    end
end
