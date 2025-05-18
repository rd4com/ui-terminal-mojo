from `ui-terminal-mojo` import *

@value
struct Movie:
    var title: String
    var rating: UInt8
    var genre: Int

def main():
    var ui = UI()

    var movies = List[Movie](
        Movie("Indiana", 15, 0),
        Movie("Indiana2", 15, 0),
        Movie("Indiana3", 15, 0),
    )
    var genres = List[String]("Adventure", "Action")

    var new_movie = String("New title")
    var new_movie_edit = False
    var new_movie_rating = UInt8(8)
    var new_movie_genre = Int(0)

    for _ in ui:
        "Movies" in ui
        tag(ui, Bg.blue, len(movies))
        var start_measuring_all = ui.start_measuring()
        for m in movies:
            var start_measuring_row = ui.start_measuring()
            var start_measuring_col = ui.start_measuring()
            Text(m[].title) | Fg.blue in ui
            ljust[16](ui)
            if len(ui[-1].data.value) >16:
                ui[-1].data.value = ui[-1].data.value[:16]

            ui.move_cursor_after(start_measuring_col^.stop_measuring())
            start_measuring_col = ui.start_measuring()
            Text("|") | Fg.cyan in ui
            center[8](ui)

            ui.move_cursor_after(start_measuring_col^.stop_measuring())
            start_measuring_col = ui.start_measuring()
            if m[].rating >= 12:
                widget_slider["Rating", theme=Fg.green](ui, m[].rating)
            else:
                widget_slider["Rating", theme=Fg.magenta](ui, m[].rating)

            ui.move_cursor_after(start_measuring_col^.stop_measuring())
            start_measuring_col = ui.start_measuring()
            Text("|") | Fg.cyan in ui
            center[8](ui)

            ui.move_cursor_after(start_measuring_col^.stop_measuring())
            widget_value_selector["Genre"](ui, m[].genre,genres)

            ui.move_cursor_below(start_measuring_row^.stop_measuring())
            " " in ui

        var stop_measuring_all = start_measuring_all^.stop_measuring()
        var tmp_area_width = stop_measuring_all.get_dimensions(ui)
        var area_width = Int(tmp_area_width[0])
        ui.move_cursor_below(stop_measuring_all^)
        Text("-"*area_width) | Fg.green in ui
        "Add to movies" in ui
        ui[-1] |= Bg.blue
        if ui[-1].click():
            movies.append(Movie(new_movie, new_movie_rating, new_movie_genre))
        input_buffer["Movie:"](ui, new_movie, new_movie_edit)
        widget_slider["rating", preview_value = True](ui, new_movie_rating)
        widget_selection_group["Genre", Fg.blue](ui, genres, new_movie_genre)
