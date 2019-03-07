

function OnDiscordClick() {
    $.Schedule(0.2, function() {
        $.DispatchEvent("ExternalBrowserGoToURL", "https://discord.gg/jsRQtAk")
    })
}
