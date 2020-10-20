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

function change_to_play_state()
    mp.set_property("sub-visibility", "no")
    overlay:remove()
    current_state = States.PLAY
end

function change_to_test_state()
    mp.set_property("pause", "yes")
    mp.set_property("sub-visibility", "no")
    overlay.data = test_overlay_data
    overlay:update()
    current_state = States.TEST
end

function change_to_view_answer_state()
    mp.set_property("pause", "yes")
    mp.set_property("sub-visibility", "yes")
    overlay.data = view_answer_overlay_data
    overlay:update()
    current_state = States.VIEW_ANSWER
end

function change_to_replay_state()
    mp.set_property("pause", "no")
    mp.set_property("sub-visibility", "no")
    overlay:remove()
    current_state = States.REPLAY
end

function change_to_continue_state()
    mp.set_property("pause", "no")
    mp.set_property("sub-visibility", "no")
    overlay:remove()
    current_state = States.CONTINUE
end

function change_to_state(state)
    if state == States.PLAY then
        change_to_play_state()
    elseif state == States.TEST then
        change_to_test_state()
    elseif state == States.VIEW_ANSWER then
        change_to_view_answer_state()
    elseif state == States.REPLAY then
        change_to_replay_state()
    elseif state == States.CONTINUE then
        change_to_continue_state()
    end
end

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
    change_to_replay_state()
end

function on_playback_restart()
    if current_state == States.TEST or current_state == States.VIEW_ANSWER then
        change_to_play_state()
    elseif current_state == States.REPLAY then
        -- When you start replaying, you will be within the previous subtitle's
        -- time frame (without delay) for the specified delay.
        -- Waiting before switching back to the play state prevents pausing
        -- immediately after replaying.
        mp.add_timeout(get_script_delay(), change_to_play_state)
    end
end

function confirm()
    if current_state == States.TEST then
        change_to_view_answer_state()
    elseif current_state == States.VIEW_ANSWER then
        change_to_continue_state()
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
        change_to_test_state()
    end
end

function position_did_not_change_since_disable()
    return mp.get_property_number("time-pos") == previous_position
end

function init_subtitle_mode()
    original_sub_visibility = mp.get_property("sub-visibility")

    mp.set_property("sub-delay", mp.get_property_number("sub-delay") + get_script_delay())

    timer = mp.add_periodic_timer(timer_rate, check_position)

    mp.add_key_binding("up", "replay", replay)
    mp.add_key_binding("down", "confirm", confirm)
    mp.add_key_binding("space", "confirm-alt", on_confirm_alt)

    mp.register_event("playback-restart", on_playback_restart)

    if position_did_not_change_since_disable() then
        change_to_state(current_state)
    else
        change_to_play_state()
    end

    is_enabled = true
    mp.osd_message("Listening practice enabled")
end

function release_subtitle_mode()
    mp.set_property("sub-visibility", original_sub_visibility)

    mp.set_property("sub-delay", get_user_delay())

    timer:kill()

    mp.remove_key_binding("replay")
    mp.remove_key_binding("confirm")
    mp.remove_key_binding("confirm-alt")

    mp.unregister_event(on_playback_restart)

    overlay:remove()

    previous_position = mp.get_property_number("time-pos")

    is_enabled = false
    mp.osd_message("Listening practice disabled")
end

function toggle_enabled()
    if not is_enabled then
        init_subtitle_mode()
    else
        release_subtitle_mode()
    end
end

function init()
    is_enabled = false
    current_state = States.PLAY
    previous_position = 0

    overlay = mp.create_osd_overlay("ass-events")
    test_overlay_data = "{\\an4}{\\fs30}Up: Replay line\\NDown/Space: Reveal subtitle"
    view_answer_overlay_data = "{\\an4}{\\fs30}Up: Replay line\\NDown/Space: Play next line"

    mp.add_key_binding("i", "toggle-enabled", toggle_enabled)

    -- After answering, enter a "continue" state until the next subtitle.
    -- This prevents the player from stopping again at the same subtitle.
    -- Observing sub-start would be preferable, but doesn't seem to work.
    mp.observe_property("sub-text", "string", function()
        if current_state == States.CONTINUE then
            change_to_play_state()
        end
    end)
end

mp.register_event("file-loaded", init)