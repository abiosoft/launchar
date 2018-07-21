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

    public MyAppWindow (Gtk.Application app) {
        Object (application: app);
        setup ();
    }

    private void setup () {
        set_keep_above(true);
        mnuabout.activate.connect (show_about);
        setup_applications ();
        setup_search ();
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

    AppEntry[] get_desktop_files (string[] dirs) {
        AppEntry[] apps = new AppEntry[] {};

        foreach (string dir in dirs) {
            try {
                var d = File.new_for_path (Path.build_filename (dir, "applications"));

                var enumerator = d.enumerate_children (FileAttribute.STANDARD_NAME, 0);

                FileInfo info;
                while ((info = enumerator.next_file ()) != null) {
                        var filename = info.get_name ();
                    try{
                        if (!filename.has_suffix (".desktop")) {
                            continue;
                        }
                        var filepath = Path.build_filename (d.get_path (), info.get_name ());
                        AppEntry app_entry = new AppEntry (filepath);

                        apps += app_entry;
                    } catch (Error e) {
                        stderr.printf ("%s - %s\n", filename, e.message);
                    }
                }
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }
        }

        return apps;
    }
}

class AppEntry {

    public Gtk.Button app_button {
        get { return button; }
    }
    private Gtk.Button button;

// Get application icon;
    public string app_icon {
        get { return icon; }
    }
    private string icon;

    private string name;
    public string app_name {
        get { return name; }
    }

    private string exec;
    public string app_exec {
        get { return exec; }
    }

    private string desktop_file;

    public AppEntry (string desktop_file) throws KeyFileError, FileError {
        this.desktop_file = desktop_file;
        init ();
    }

    private void init () throws KeyFileError, FileError {
        KeyFile file = new KeyFile ();

        file.load_from_file (desktop_file, KeyFileFlags.NONE);

        var type = file.get_string ("Desktop Entry", "Type");
        if (type != "Application") {
            throw new FileError.INVAL ("File is not an application, type: %s, file: %s".printf(type, desktop_file));
        }
        name = file.get_string ("Desktop Entry", "Name");
        icon = file.get_string ("Desktop Entry", "Icon");
        exec = file.get_string ("Desktop Entry", "Exec");

        create_button ();
    }

    private void create_button () {
        Gtk.Image image = new Gtk.Image ();

        image.icon_name = app_icon;
        image.set_pixel_size (128);

        button = new Gtk.Button ();

        button.set_image (image);
        button.set_label (app_name);
        button.set_image_position (Gtk.PositionType.TOP);
        button.always_show_image = true;
        button.show ();
    }

    public string to_string () {
        return "".concat ("name:", name, " icon:", icon, " exec:", exec);
    }
}

