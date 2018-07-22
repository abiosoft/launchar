/*
 * Copyright (c) 2018 Abiola Ibrahim (https://abio.la)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Abiola Ibrahim <abiola89@gmail.com>
 */
int main (string[] args) {
    var app = new Gtk.Application ("com.gitlab.abiosoft.launchar",
                                   ApplicationFlags.NON_UNIQUE);

    app.activate.connect (() => {
        var win = app.active_window;
        if (win == null) {
            win = (Instance.window = new MyAppWindow (app));
        }
        win.present ();
    });
    int exit = app.run (args);

    // launch desktop app
    if (Instance.app != null) {
        launch_app (Instance.app.app_exec, Instance.app.run_in_terminal);
    }

    return exit;
}

namespace Instance {
    public Gtk.ApplicationWindow window;
    public AppEntry app;
}
