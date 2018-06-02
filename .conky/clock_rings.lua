settings_table = {
    --[[
    {
        -- "name" is the Conky object to display data for. Value should be one of 'cpu', 'memperc', 'fs_used_perc', or 'battery_used_perc'
        name='cpu',
        -- "arg" is the argument to the stat type, e.g. if in Conky you would write ${cpu cpu0}, 'cpu0' would be the argument. For no argument leave an empty string
        arg='cpu0',
        -- "max" is the maximum value of the data the ring displays. Value should be 100 for percentages
        max=100,
        -- "bg_color" is the color of the base ring
        bg_color=0xffffff,
        -- "bg_alpha" is the alpha value of the base ring
        bg_alpha=0,
        -- "fg_color" is the color of the indicator part of the ring
        fg_color=0xffffff,
        -- "fg_alpha" is the alpha value of the indicator part of the ring
        fg_alpha=0,
        -- "x" and "y" give the distance in pixels of the center of the ring from the top left corner of the Conky window
        x=110, y=160,
        -- "radius" is the radius of the ring in pixels
        radius=50,
        -- "thickness" is the thickness of the ring, centred around the radius
        thickness=5,
        -- "start_angle" is the starting angle of the ring in degrees measured clockwise from the positive y axis. Value can be positive or negative
        start_angle=0,
        -- "end_angle" is the ending angle of the ring in degrees measured clockwise from the positive y axis. Value can be positive or negative and must be larger than start_angle
        end_angle=360
    }
    -- ]]
    {
        name='time',
        arg='%S',
        max=60,
        bg_color=0xffffff,
        bg_alpha=0.1,
        fg_color=0xffffff,
        fg_alpha=0.6,
        x=110, y=160,
        radius=65,
        thickness=4,
        start_angle=0,
        end_angle=360
    },
    {
        name='cpu',
        arg='cpu1',
        max=100,
        bg_color=0xffffff,
        bg_alpha=0.2,
        fg_color=0xffffff,
        fg_alpha=0.5,
        x=110, y=160,
        radius=75,
        thickness=5,
        start_angle=95,
        end_angle=210
    },
    {
        name='cpu',
        arg='cpu2',
        max=100,
        bg_color=0xffffff,
        bg_alpha=0.2,
        fg_color=0xffffff,
        fg_alpha=0.5,
        x=110, y=160,
        radius=81,
        thickness=5,
        start_angle=95,
        end_angle=210
    },
    {
        name='cpu',
        arg='cpu3',
        max=100,
        bg_color=0xffffff,
        bg_alpha=0.2,
        fg_color=0xffffff,
        fg_alpha=0.5,
        x=110, y=160,
        radius=87,
        thickness=5,
        start_angle=95,
        end_angle=210
    },
    {
        name='cpu',
        arg='cpu4',
        max=100,
        bg_color=0xffffff,
        bg_alpha=0.2,
        fg_color=0xffffff,
        fg_alpha=0.5,
        x=110, y=160,
        radius=93,
        thickness=5,
        start_angle=95,
        end_angle=210
    },
    {
        name='memperc',
        arg='',
        max=100,
        bg_color=0xffffff,
        bg_alpha=0.2,
        fg_color=0xffffff,
        fg_alpha=0.5,
        x=110, y=160,
        radius=84,
        thickness=22.5,
        start_angle=214,
        end_angle=330
    },
    {
        -- Left side bar of CPU graph
        name='cpu',
        arg='',
        max=1,
        bg_color=0xd5dcde,
        bg_alpha=0.7,
        fg_color=0xd5dcde,
        fg_alpha=0,
        x=110, y=160,
        radius=130,
        thickness=2,
        start_angle=78,
        end_angle=102
    },
    {
        -- Right side bar of CPU graph
        name='cpu',
        arg='',
        max=1,
        bg_color=0xffffff,
        bg_alpha=0.7,
        fg_color=0xffffff,
        fg_alpha=0,
        x=110, y=160,
        radius=430,
        thickness=2,
        start_angle=86,
        end_angle=94
    },
    {
        name='fs_used_perc',
        arg='/',
        max=100,
        bg_color=0xffffff,
        bg_alpha=0.2,
        fg_color=0xffffff,
        fg_alpha=0.5,
        x=110, y=160,
        radius=105,
        thickness=5,
        start_angle=-120,
        end_angle=-1.5
    },
    {
        name='fs_used_perc',
        arg='/home',
        max=100,
        bg_color=0xffffff,
        bg_alpha=0.2,
        fg_color=0xffffff,
        fg_alpha=0.5,
        x=110, y=160,
        radius=105,
        thickness=5,
        start_angle=1.5,
        end_angle=120
    },
}

require 'cairo'

function rgb_to_r_g_b(color,alpha)
    return ((color / 0x10000) % 0x100) / 255., ((color / 0x100) % 0x100) / 255., (color % 0x100) / 255., alpha
end

function draw_ring(cr,t,pt)
    local w,h=conky_window.width,conky_window.height

    local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
    local bgc, bga, fgc, fga=pt['bg_color'], pt['bg_alpha'], pt['fg_color'], pt['fg_alpha']

    local angle_0=sa*(2*math.pi/360)-math.pi/2
    local angle_f=ea*(2*math.pi/360)-math.pi/2
    local t_arc=t*(angle_f-angle_0)

    -- Draw background ring

    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
    cairo_set_line_width(cr,ring_w)
    cairo_stroke(cr)

    -- Draw indicator ring

    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
    cairo_stroke(cr)
end

function conky_status_rings()
    local function setup_rings(cr,pt)
                local str=''
                local value=0

                str=string.format('${%s %s}',pt['name'],pt['arg'])
                str=conky_parse(str)

                value=tonumber(str)
                if value == nil then value = 0 end
                pct=value/pt['max']

                draw_ring(cr,pct,pt)
        end

    if conky_window==nil then return end
    local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

    local cr=cairo_create(cs)

    for i in pairs(settings_table) do
        setup_rings(cr,settings_table[i])
    end
end
