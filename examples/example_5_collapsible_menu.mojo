from `ui-terminal-mojo` import *

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ Features                                                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝
# this widgets is great, the implementation is simple,
# users could just implement it with a button
fn main():

    # menu widget:
    var opened = False
    var selected = 0
    var ui = UI()
    for _ in ui:
        "Example menu" in ui
        _ = widget_collapsible_menu["SelectMenu"](
            ui,
            List[String]("Zero", "One", "Two", "Three"),
            opened, selected
        )
        Text(repr(SIMD[DType.uint8, 4](selected))) | Bg((selected|4)+41) in ui
