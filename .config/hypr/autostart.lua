-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- LocalSend in the background so an iPhone can send files any time (AirDrop-style).
o.launch_on_start("env GTK_IM_MODULE=fcitx localsend --hidden")
