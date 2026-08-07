hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULES", "wayland;fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Nordzy-cursors")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Nordzy-cursors")
hl.env("http_proxy", "http://proxy.hcm.fpt.vn:80")
hl.env("https_proxy", "http://proxy.hcm.fpt.vn:80")
hl.env(
	"no_proxy",
	"localhost,127.0.0.1,.fpt.net,.isc.net,.fti.net,ticketapi.fpt.vn,ticketapi-stag.fpt.vn,ticketopsapi.fpt.vn"
)