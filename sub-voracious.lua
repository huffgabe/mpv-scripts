-- Usage:
--    i - subtitle mode on/off
--    ↑, ↓ (Space) - mode specific shortcuts
-- Note:
--    The script is inspired by voracious.app (https://github.com/rsimmons/voracious).
--
--    - Listening Practice:
--        "Subtitles are initially hidden. At the end of each subtitle, the video will pause automatically.
--         Could you hear what was said? Press ↑ to replay, if necessary.
--         Then press ↓ to reveal the subs, and check if you heard correctly.
--         Then press ↓ to unpause the video."
--
----------------------------------

--------- Script Options ---------
-- Delay the subtitle by a small amount so it's still visible when paused at the end.
visibility_delay = 0.1

-- Play a little bit past the end of the subtitle to reduce voices getting cut off.
end_padding = 0.15

-- How often to check the position against the end of the subtitle.
timer_rate = 0.05
----------------------------------

States = {
    PLAY = 1,
    TEST = 2,
    VIEW_ANSWER = 3,
    REPLAY = 4,
    CONTINUE = 5
}

-- The total subtitle delay that the script applies (in contrast to the user-set delay).
function get_script_delay()
    return visibility_delay + end_padding
end

-- The subtitle delay applied by the user.
function get_user_delay()
    return mp.get_property("sub-delay") - get_script_delay()
end

function get_user_delayed_time(sub_time)
    return sub_time + get_user_delay()
end

function replay()
    if current_state == States.REPLAY then return end

    local sub_start = mp.get_property_number("sub-start")
    if sub_start == nil then return end

    mp.commandv("seek", get_user_delayed_time(sub_start), "absolute+exact")
    mp.set_property("sub-visibility", "no")
    current_state = States.REPLAY
end

function on_playback_restart()
    if current_state ~= States.REPLAY then return end

    mp.set_property("pause", "no")

    -- When you start replaying, you will be within the previous subtitle's
    -- time frame (without delay) for the specified delay.
    -- Waiting before switching back to the play state prevents pausing
    -- immediately after replaying.
    mp.add_timeout(get_script_delay(), function() current_state = States.PLAY end)
end

function confirm()
    if current_state == States.TEST then
        mp.set_property("sub-visibility", "yes")
        current_state = States.VIEW_ANSWER
    elseif current_state == States.VIEW_ANSWER then
        mp.set_property("sub-visibility", "no")
        mp.set_property("pause", "no")
        current_state = States.CONTINUE
    end
end

function toggle_paused()
    mp.set_property_bool("pause", not mp.get_property_bool("pause"))
end

-- Primarily intended for the Space key.
function on_confirm_alt()
    if current_state == States.TEST or current_state == States.VIEW_ANSWER then
        confirm()
    else
        toggle_paused()
    end
end

function check_position()
    if mp.get_property("pause") == "yes" then return end

    if current_state == States.CONTINUE then return end
    if current_state == States.REPLAY then return end

    local current_position = mp.get_property_number("time-pos")
    if current_position == nil then return end

    local sub_end = mp.get_property_number("sub-end")
    if sub_end == nil then return end

    if current_position >= get_user_delayed_time(sub_end) + end_padding then
        mp.set_property("pause", "yes")
        current_state = States.TEST
    end
end

function init_subtitle_mode()
    original_sub_visibility = mp.get_property("sub-visibility")
    mp.set_property("sub-visibility", "no")

    timer = mp.add_periodic_timer(timer_rate, check_position)

    mp.add_key_binding("up", "replay", replay)
    mp.add_key_binding("down", "confirm", confirm)
    mp.add_key_binding("space", "confirm-alt", on_confirm_alt)

    mp.register_event("playback-restart", on_playback_restart)
end

function release_subtitle_mode()
    mp.set_property("sub-visibility", original_sub_visibility)

    timer:kill()

    mp.remove_key_binding("replay")
    mp.remove_key_binding("confirm")
    mp.remove_key_binding("confirm-alt")

    mp.unregister_event(on_playback_restart)
end

function toggle_enabled()
    if is_enabled == false then
        is_enabled = true
        mp.set_property("sub-delay", mp.get_property_number("sub-delay") + get_script_delay())
        init_subtitle_mode()

        mp.osd_message("Listening practice enabled")
    else
        is_enabled = false
        mp.set_property("sub-delay", get_user_delay())
        release_subtitle_mode()

        mp.osd_message("Listening practice disabled")
    end
end

function init()
    is_enabled = false
    current_state = States.PLAY
    mp.add_key_binding("i", "toggle-enabled", toggle_enabled)

    -- After answering, enter a "continue" state until the next subtitle.
    -- This prevents the player from stopping again at the same subtitle.
    -- Observing sub-start would be preferable, but doesn't seem to work.
    mp.observe_property("sub-text", "string", function()
        if current_state == States.CONTINUE then
            current_state = States.PLAY
        end
    end)
end

mp.register_event("file-loaded", init)