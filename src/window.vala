/*
 * Copyright (c) 2011-2018 Your Organization (https://yourwebsite.com)
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
 * Authored by: Author <author@example.com>
 */
[GtkTemplate (ui = "/com/github/user/Hello/window.glade")]
public class MyAppWindow: Gtk.ApplicationWindow {

    [GtkChild]
    Gtk.MenuItem mnuabout;

    public MyAppWindow (Gtk.Application app) {
        Object (application: app);
        setup ();
    }

    private void setup () {
        mnuabout.activate.connect (show_about);
    }

    private void show_about () {
        Gtk.show_about_dialog (this,
                               logo_icon_name: "application-default-icon",
                               program_name: "Hello Elementary",
                               copyright: "Copyright © 2018",
                               website: "https://github.com/abiosoft/hello-elementary");
    }
}
