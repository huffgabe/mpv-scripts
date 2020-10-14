local function is_emptystring(str)
    return str == nil or str == ''
end

local function copy_sub_to_clipboard()
    subtitle = mp.get_property("sub-text")
    subtitle = string.gsub(subtitle, "\n", " ")
    
    if is_emptystring(subtitle) then
        return
    end

    mp.commandv("run", "cmd.exe", "/d", "/c", string.format("@echo off & chcp 65001 & echo %s|clip", subtitle))
    mp.osd_message("Copied subtitle")
end

mp.add_key_binding("ctrl+c", "copy-sub-to-clipboard", copy_sub_to_clipboard)