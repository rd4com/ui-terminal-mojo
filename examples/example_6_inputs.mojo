from `ui-terminal-mojo` import *

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ Features                                                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

fn main():

    # menu widget:
    var inputs = List[String]("Add todo", "Delete todo", "Commit")
    var inputs_edits = List[Bool](False, False, False)
    #^ state for whether an input is currently edited

    var ui = UI()
    for _ in ui:
        Text("Edit:", len(inputs)) | Bg.yellow | Fg.red in ui
        "Add new input" in ui
        if ui[-1].click():
            inputs.append("new")
            inputs_edits.append(False)

        " " in ui

        for i in range(len(inputs)):
            input_buffer["edit:"](ui, inputs[i], inputs_edits[i])
