from `ui-terminal-mojo` import *

fn main():

    var ui = UI()
    for _ in ui:
        @parameter
        for i in range(1, 9):
            Text("Spinner cycle:", i) | Bg.yellow | Fg.black in ui
            spinner[i](ui)

        " " in ui

        @parameter
        for i in range(1, 9):
            Text("Spinner backward cycle:", i) | Bg.magenta | Fg.black in ui
            spinner[i, False](ui)
