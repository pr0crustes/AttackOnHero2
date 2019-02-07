

var open = false;


function get_hud() {
    var p = $.GetContextPanel();
    while (p !== null && p.id !== "Hud") {
        p = p.GetParent();
    }
    return p;
}


function on_info_button_click() {
    get_hud().FindChildTraverse("game_info_button").GetParent().style.transform = (open ? "translateX(-475px)" : "translateX(0)");
    open = !open;
}
