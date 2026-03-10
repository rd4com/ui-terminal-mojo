from `ui-terminal-mojo` import *


def main():
    var ui = UI()
    var numbers: List[UInt8] = [0, 1, 2, 3]
    for _ in ui:
        # var start_measuring = ui.start_measuring()
        with MoveCursor.AfterThis[StyleBorderDouble, Fg.cyan](ui):
            "ok" in ui
        with MoveCursor.AfterThis[StyleBorderCurved, Fg.blue](ui):
            "ok2" in ui
        # var stop_measuring = start_measuring^.stop_measuring()
        # stop_measuring^.move_cursor_after()
        "Widget moved the cursor below for user friendlyness" in ui
        # Text("But let's go -> !") | Bg.blue in ui
