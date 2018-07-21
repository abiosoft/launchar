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
[GtkTemplate (ui = "/com/gitlab/abiosoft/launchar/window.glade")]
public class MyAppWindow: Gtk.ApplicationWindow {

    [GtkChild]
    Gtk.MenuItem mnuabout;

    [GtkChild]
    Gtk.Grid application_grid;

    [GtkChild]
    Gtk.ScrolledWindow application_scroll;

    [GtkChild]
    Gtk.SearchEntry search_apps;

    AppEntry[] applications;

    private Gtk.Application app;

    public MyAppWindow (Gtk.Application app) {
        Object (application: app);
        this.app = app;
        setup ();
    }

    private void setup () {
        set_keep_above (true);
        key_press_event.connect (exit_on_esc);

        mnuabout.activate.connect (show_about);
        setup_applications ();
        setup_search ();
    }

    private bool exit_on_esc (Gdk.EventKey e) {
        print (e.keyval.to_string () + "\n");
        if (e.keyval == Gdk.Key.Escape) {
            app.quit ();
            return true;
        }
        return false;
    }

    private void setup_applications () {
        string[] dirs = Environment.get_system_data_dirs ();
        dirs += Environment.get_user_data_dir ();
        applications = get_desktop_files (dirs);
        filter_grid (null);
    }

    private void setup_search () {
        search_apps.grab_focus ();

        search_apps.search_changed.connect (() => {
            filter_grid (search_apps.text);
        });
    }

    private void show_about () {
        Gtk.show_about_dialog (this,
                               logo_icon_name: "start-here",
                               program_name: "Launchar",
                               copyright: "Copyright © 2018",
                               Website: "https://gitlab.com/abiosoft/launchar");
    }

    void filter_grid (string ? filter) {
        application_grid.forall ((element) => application_grid.remove (element));

        int count = 0;
        for (int i = 0; i < applications.length; i++) {
            var app = applications[i];
            if (filter != null) {
                if (!app.app_name.down ().contains (filter.down ())) {
                    continue;
                }
            }
            application_grid.attach (app.app_button, count % 3, count / 3);
            count++;
        }

        // 12 is a decent list for the view
        for (int i =count; i < 12; i++) {
            Gtk.Image dummy = new Gtk.Image ();

            dummy.can_focus = false;
            dummy.show ();
            application_grid.attach (dummy, i % 3, i / 3);
        }

        // scroll back to top
        application_scroll.vadjustment.value = 0;
    }
}


