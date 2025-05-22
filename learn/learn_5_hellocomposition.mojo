from `ui-terminal-mojo` import *

@value
struct User:
    var name: String
    var city: String

def main():
    var ui = UI()
    ui.feature_tab_menu = True

    var users = List(
        User("Peter", "Texas"),
        User("Maria", "Paris")
    )
    var new_users = List[User]()
    var current_list = Pointer[List[User], __origin_of(users,new_users)](to=users)
    var user_adder = UserAdder(ui)

    for frame in ui:
        @parameter
        fn tab_menu():
            Text("Select user list") | Bg.blue in ui
            "New users" in ui
            if ui[-1].click():
                current_list = __type_of(current_list)(to=new_users)
            tag(ui,Bg.magenta, len(new_users))
            "Users" in ui
            if ui[-1].click():
                current_list =  __type_of(current_list)(to=users)
            tag(ui,Bg.magenta, len(users))
            Text("Merge new users")| Bg.green in ui
            if ui[-1].click():
                users.extend(new_users)
                new_users.clear()
        ui.set_tab_menu[tab_menu]()

        Text("Users page") | Bg.blue in ui
        var start_measuring = ui.start_measuring()
        show_users(ui, current_list[])
        ui.move_cursor_after(start_measuring^.stop_measuring())
        user_adder.render(current_list[])

fn show_users(mut ui: UI, users: List[User]):
    "Function to show users."

    var measuring = ui.start_measuring()
    var b = measuring.start_border()
    for u in users:
        Text(u[].name) in ui
        tooltip(ui, String("city: ", u[].city))
    if not users:
        Text("Empty") | Bg.cyan in ui
    b^.end_border(ui, Fg.blue)
    ui.move_cursor_below(measuring^.stop_measuring())

@value
struct UserAdder[O:MutableOrigin]:
    var input_name: String
    var input_city: String
    var input_name_is_edited: Bool
    var input_city_is_edited: Bool
    var ui: Pointer[UI, O]
    fn __init__(out self, ref[O]ui: UI):
        self.input_name = "Bob"
        self.input_city = "Barcelona"
        self.input_name_is_edited = False
        self.input_city_is_edited = True
        self.ui = Pointer(to=ui)
    fn render(mut self, mut users: List[User]):
        input_buffer["Name:"](self.ui[], self.input_name, self.input_name_is_edited)
        input_buffer["City:"](self.ui[], self.input_city, self.input_city_is_edited)
        Text("Add person") | Bg.magenta in self.ui[]
        if self.ui[][-1].click():
            users.append(User(self.input_name, self.input_city))
