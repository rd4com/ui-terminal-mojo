from `ui-terminal-mojo` import *

def main():
    var ui = UI()
    var counter = 0
    for frame in ui:
        Text(counter) | Fg.magenta in ui
        Text("increment") | Bg.cyan in ui
        if ui[-1].click():
            counter+=1
