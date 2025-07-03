from `ui-terminal-mojo` import *

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ Features                                                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

fn main():

    # menu widget:
    var todos = List[String]("Add todo", "Delete todo", "Commit")
    var showtodos = False
    # input widget:
    var input_edit = False
    var input_todo = String("Merge")

    var ui = UI()
    for _ in ui:
        Text("Todos:", len(todos)) | Bg.yellow | Fg.red in ui
        if len(todos)>0:
            Text("clear") | Bg.yellow | Fg.red in ui
            if ui[-1].click():
                todos.clear()


        " " in ui

        #example implementing a menu dropdown:
        Text("ShowTodos") | Bg.black | Fg.yellow in ui
        if ui[-1].click():
            showtodos  ^= True
        if ui[-1].hover():
            "⬆️ Tooltip: this is a button" in ui

        var idx=0
        if showtodos:
            for t in todos:
                Text(String(idx,"   ",t)) in ui
                if ui[-1].click():
                    input_todo = todos.pop(idx)
                if ui[-1].hover():
                    ui[-1]|=Bg.magenta
                idx+=1


        " " in ui

        input_buffer["New:"](ui, input_todo, input_edit)

        Text("Reset") | Bg.red in ui
        if input_todo and ui[-1].click():
            input_todo = String("Hello World")

        Text("Add Todo") | Bg.green in ui
        if ui[-1].click():
            todos.append(input_todo)
