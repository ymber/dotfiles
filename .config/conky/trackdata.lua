local id3 = require "id3"
local request = require "http.request"
local cjson = require "cjson.safe"
local lfs = require "lfs"

require "imlib2"
require "cairo"

settings = {
    album_art_position_x = 21,
    album_art_position_y = 21,
    album_art_size_x = 128,
    album_art_size_y = 128,

    time_bar_position_x = 160,
    time_bar_position_y = 144,
    time_bar_length = 350,
    time_bar_width = 10,
    time_bar_bg_rgba = {1, 1, 1, 0.2},
    time_bar_fg_rgba = {1, 1, 1, 0.5},

    text_position_x = 160,
    text_position_y = 113,
    text_line_gap = 4,
    text_font = "Droid Sans Mono",
    text_size = 20,
    text_rgba = {1, 1, 1, 0.8},
    text_lines = {
        "${mpd_elapsed}/${mpd_length}",
        "${mpd_album}",
        "${mpd_artist}",
        "${mpd_title}"
    },

    music_library = "/home/matthew/Music"
}
local function locate_playing_file()
    return string.format( "%s/%s", settings["music_library"], conky_parse( "${mpd_file}" ) )
end

local function get_album_id( track )
    local file = io.open( track, "rb" )
    local id3_frames = id3.frames_dict( file, id3.read_header( file )[5] )
    file:close()
    
    for key, frame in pairs( id3_frames ) do
        if frame[1] == "TXXX" then
            -- TXXX frame data begins with a null terminated frame descriptor
            local strings = {}
            for str in string.gmatch( id3.utf16_to_utf8( id3.text_frame_data( frame[5] )[2] ), "%Z+" ) do
                table.insert( strings, str )
            end
            if strings[1] == "MusicBrainz Album Id" then
                return strings[2]
            end
        end
    end
end

local function get_release_listing( album_id )
    local headers, stream = request.new_from_uri( string.format( "https://coverartarchive.org/release/%s", album_id ) ):go()
    local release_listing = stream:get_body_as_string()
    return cjson.decode( release_listing )
end

local function get_cover_art( listing_json )
    local headers, stream = request.new_from_uri( listing_json["images"][1]["image"] ):go()
    return stream:get_body_as_string()
end

local function resize_image( image_path, out_x, out_y )
    imlib_context_set_image( imlib_load_image( image_path ) )
    local out_image = imlib_create_cropped_scaled_image( 0, 0, imlib_image_get_width(), imlib_image_get_height(), out_x, out_y )
    -- Free image after new one is generated to prevent oversized image being rendered from cache
    imlib_free_image()

    imlib_context_set_image( out_image )
    imlib_image_set_format( "png" )
    imlib_save_image( image_path )
    imlib_free_image()
end

local function cache_album_art( album_id )
    local image_path = string.format( "%s/albumart/%s.png", os.getenv( "XDG_CACHE_HOME" ), album_id )

    -- Create $XDG_CACHE_HOME/albumart if no such directory exists
    if lfs.attributes( string.format( "%s/albumart", os.getenv( "XDG_CACHE_HOME" ) ) ) == nil then
        lfs.mkdir( string.format( "%s/albumart", os.getenv( "XDG_CACHE_HOME" ) ) )
    end

    local release_listing = get_release_listing( album_id )
    if release_listing == nil then
        return
    end

    local cover_art = io.open( image_path, "wb" )
    cover_art:write( get_cover_art( release_listing ) )
    cover_art:close()
    resize_image( image_path, settings["album_art_size_x"], settings["album_art_size_y"] )
end

local function reverse_array( array )
    local i = 1
    local j = table.getn( array )

    while i < j do
        local temp = array[i]
        array[i] = array[j]
        array[j] = temp
        i = i + 1
        j = j -1
    end
end

local function time_bar_percent()
    -- Convert time strings to seconds, return elapsed time as a fraction of track length
    local elapsed_time_parts = {}
    for part in string.gmatch( conky_parse( "${mpd_elapsed}" ), "%d+" ) do
        table.insert( elapsed_time_parts, part )
    end
    reverse_array( elapsed_time_parts )

    local elapsed_time_seconds = 0
    for i, part in pairs( elapsed_time_parts ) do
        elapsed_time_seconds = elapsed_time_seconds + tonumber( part ) * ( 60 ^ ( i - 1 ) )
    end

    local track_length_parts = {}
    for part in string.gmatch( conky_parse( "${mpd_length}" ), "%d+" ) do
        table.insert( track_length_parts, part )
    end
    reverse_array( track_length_parts )

    local track_length_seconds = 0
    for i, part in pairs( track_length_parts ) do
        track_length_seconds = track_length_seconds + tonumber( part ) * ( 60 ^ ( i - 1 ) )
    end

    return elapsed_time_seconds / track_length_seconds
end

local function draw_time_bar( context )
    cairo_set_line_width( context, settings["time_bar_width"] )
    local filled_line_length = settings["time_bar_length"] * time_bar_percent()

    -- Draw bar background
    cairo_set_source_rgba( context, unpack( settings["time_bar_bg_rgba"] ) )
    cairo_move_to( context, settings["time_bar_position_x"], settings["time_bar_position_y"] )
    cairo_line_to( context, settings["time_bar_position_x"] + settings["time_bar_length"], settings["time_bar_position_y"] )
    cairo_stroke( context )

    -- Draw bar foreground
    cairo_set_source_rgba( context, unpack( settings["time_bar_fg_rgba"] ) )
    cairo_move_to( context, settings["time_bar_position_x"], settings["time_bar_position_y"] )
    cairo_line_to( context, settings["time_bar_position_x"] + filled_line_length, settings["time_bar_position_y"] )
    cairo_stroke( context )
end

local function draw_text( context )
    cairo_set_source_rgba( context, unpack( settings["text_rgba"] ) )
    cairo_select_font_face( context, settings["text_font"] )
    cairo_set_font_size( context, settings["text_size"] )

    -- Cairo text position is bottom left corner - render lines upwards
    for line_number, line_text in pairs( settings["text_lines"] ) do
        local offset = ( settings["text_size"] + settings["text_line_gap"] ) * ( line_number - 1 )
        cairo_move_to( context, settings["text_position_x"], settings["text_position_y"] - offset )
        cairo_show_text( context, conky_parse( line_text ) )
    end
end

function conky_trackdata()
    if conky_window == nil then return end

    local cairo_surface = cairo_xlib_surface_create( conky_window.display,
                                                     conky_window.drawable,
                                                     conky_window.visual,
                                                     conky_window.width,
                                                     conky_window.height )
    local cairo_context = cairo_create( cairo_surface )

    -- Show not playing if MPD has no active track
    if conky_parse( "${mpd_status}" ) ~= "Playing" and conky_parse( "${mpd_status}" ) ~= "Paused" then
        cairo_set_source_rgba( cairo_context, unpack( settings["text_rgba"] ) )
        cairo_select_font_face( cairo_context, settings["text_font"] )
        cairo_set_font_size( cairo_context, settings["text_size"] )
        cairo_move_to( cairo_context, settings["text_position_x"], settings["text_position_y"] )
        cairo_show_text( cairo_context, "Not playing" )
        return
    end
    
    -- Allocate 2MB image cache so the script doesn't hit the disk every time it executes
    imlib_set_cache_size( 2097152 )
    imlib_context_set_drawable( conky_window.drawable )

    draw_time_bar( cairo_context )
    draw_text( cairo_context )

    local album_id = get_album_id( locate_playing_file() )
    local image_path = string.format( "%s/albumart/%s.png", os.getenv( "XDG_CACHE_HOME" ), album_id )
    if lfs.attributes( image_path ) == nil then
        cache_album_art( album_id )
    end

    local image = imlib_load_image( image_path )
    if image ~= nil then
        imlib_context_set_image( image )
        imlib_render_image_on_drawable( settings["album_art_position_x"], settings["album_art_position_y"] )
    end
end

