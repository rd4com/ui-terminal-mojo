from `ui-terminal-mojo` import *

def main():
    var ui = UI()
    var users = List(
        (String("Peter"), String("Texas")),
        (String("Maria"), String("Paris"))
    )
    var input_name = String("Bob")
    var input_city = String("Barcelona")
    var input_name_is_edited = False
    var input_city_is_edited = False

    for frame in ui:
        "Users" in ui
        tag(ui, Bg.blue, len(users))
        for u in users:
            Text(u[][0]) in ui
            tooltip(ui, String("city: ", u[][1]))

        input_buffer["Name:"](ui, input_name, input_name_is_edited)
        input_buffer["City:"](ui, input_city, input_city_is_edited)
        Text("Add person") | Bg.magenta in ui
        if ui[-1].click():
            users.append((input_name, input_city))
