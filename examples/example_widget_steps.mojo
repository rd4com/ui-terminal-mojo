from module_ui import *


def main():
    var ui = UI()

    var current_step = UInt8(0)
    var steps = List[String]("Step1", "Step2", "Step3!")

    for _ in ui:
        "App" in ui
        widget_steps(ui, steps, current_step)
        widget_steps[Fg.blue, 4](ui, steps, current_step)
        widget_steps[Fg.blue, 8](ui, steps, current_step)
        "Increment step" in ui
        if ui[-1].click():
            current_step = (current_step+1)#%len(steps)

