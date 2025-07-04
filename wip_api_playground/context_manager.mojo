from `ui-terminal-mojo` import *

def main():
    var ui = UI()
    var entries = List[UInt8](0, 2, 5, 8)
    for _ in ui:

        with MoveCursor.AfterThis(ui):
            for ref e in entries:
                with MoveCursor.BelowThis[StyleBorderSimple](ui):
                    with MoveCursor.AfterThis(ui):
                        Text("->") | Fg.cyan in ui
                    with MoveCursor.AfterThis(ui):
                        widget_slider["n_entries", preview_value=True](ui, e)
                    with MoveCursor.AfterThis(ui):
                        Text("<-") | Fg.cyan in ui
        with MoveCursor.AfterThis(ui):
            for e in entries:
                with MoveCursor.BelowThis[StyleBorderCurved](ui):
                    Text("value:", e)|Bg.blue in ui
                    Text("") in ui

# ------------------------------------------------------------------------------
# output:
# ┌──────────────────────┐╭───────╮
# │->n_entries:0       <-││value:0│
# │  [|---------------]  ││       │
# └──────────────────────┘╰───────╯
# ┌──────────────────────┐╭───────╮
# │->n_entries:2       <-││value:2│
# │  [--|-------------]  ││       │
# └──────────────────────┘╰───────╯
# ┌──────────────────────┐╭───────╮
# │->n_entries:5       <-││value:5│
# │  [-----|----------]  ││       │
# └──────────────────────┘╰───────╯
# ┌──────────────────────┐╭───────╮
# │->n_entries:8       <-││value:8│
# │  [--------|-------]  ││       │
# └──────────────────────┘╰───────╯
# ------------------------------------------------------------------------------
