

var open = false;


function on_info_button_click() {
    find_hud_element("game_info_button").GetParent().style.transform = (open ? "translateX(-475px)" : "translateX(0)");
    open = !open;
}
