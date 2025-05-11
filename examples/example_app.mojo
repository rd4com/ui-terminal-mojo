from `ui-terminal-mojo` import *

def main():

    var ui = UI()
    ui.feature_tab_menu = True

    var current_page:String = "Home"
    var news = List[String]("First page created", "Commit some PR")

    for frame in ui:
        @parameter
        fn tab_menu():
            animate_simple_inline(ui)
            Text("Home") | Fg.magenta in ui
            if ui[-1].click():
                current_page = "Home"
            if ui[-1].hover(): ui[-1] |= Bg.cyan

            Text("News") | Fg.magenta in ui
            if ui[-1].click():
                current_page = "News"
            if ui[-1].hover(): ui[-1] |= Bg.cyan

        ui.set_tab_menu[tab_menu]()

        Text("app") | Fg.yellow in ui


        if current_page == "Home":
            animate_emojis[List[String]("🌍","🌎", "🌏")](ui)
            "Home page" in ui
            "Welcome !" in ui
            Text("Press Tab") | Fg.magenta in ui
            blink(ui)

        elif current_page == "News":
            spinner2(ui)
            Text("News") | Bg.cyan in ui
            "Mojo is awesome!!!!" in ui
            widget_ticker(ui, news)
