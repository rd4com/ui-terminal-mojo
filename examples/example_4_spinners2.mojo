from `ui-terminal-mojo` import *

fn main():

    var ui = UI()
    for _ in ui:
        @parameter
        for i in range(1, 5):
            Text("Spinner2 cycle:", i) | Bg.yellow | Fg.black in ui
            spinner2[speed=i](ui)
