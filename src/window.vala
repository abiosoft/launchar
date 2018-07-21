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

    [GtkChild]
    Gtk.Grid application_grid;

    AppEntry[] applications;

    public MyAppWindow (Gtk.Application app) {
        Object (application: app);
        setup ();
        setup_applications();
    }

    private void setup () {
        mnuabout.activate.connect (show_about);
    }

    private void setup_applications(){
        string[] dirs = Environment.get_system_data_dirs ();
        dirs += Environment.get_user_data_dir ();
        applications = get_desktop_files(dirs);
        for(int i =0; i<applications.length; i++) {
            var app = applications[i];
            create_app_button(app, i);
        }
    }

    private void show_about () {
        Gtk.show_about_dialog (this,
                               logo_icon_name: "application-default-icon",
                               program_name: "Hello Elementary",
                               copyright: "Copyright © 2018",
                               website: "https://github.com/abiosoft/hello-elementary");
    }

    void create_app_button(AppEntry app, int pos) {
        Gtk.Image image = new Gtk.Image();
        image.icon_name = app.app_icon;
        image.set_pixel_size(128);

        Gtk.Button button = new Gtk.Button();
        button.set_image(image);
        button.set_label(app.app_name);
        button.set_image_position (Gtk.PositionType.TOP);
        button.always_show_image = true;
        button.show();

        application_grid.attach(button, pos/3, pos%3);
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
                    if (!filename.has_suffix (".desktop")) {
                        continue;
                    }
                    print (info.get_name () + "\n");

                    var filepath = Path.build_filename (d.get_path (), info.get_name ());
                    AppEntry app_entry = new AppEntry (filepath);

                    apps += app_entry;
                    print (app_entry.to_string () + "\n");
                }
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }
        }

        return apps;
    }
}

class AppEntry {

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
            throw new FileError.INVAL ("File is not an application");
        }
        name = file.get_string ("Desktop Entry", "Name");
        icon = file.get_string ("Desktop Entry", "Icon");
        exec = file.get_string ("Desktop Entry", "Exec");
    }

    public string to_string () {
        return "".concat ("name:", name, " icon:", icon, " exec:", exec);
    }
}
