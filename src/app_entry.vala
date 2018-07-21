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
class AppEntry {

    public Gtk.Button app_button {
        get { return button; }
    }
    private Gtk.Button button;

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

    private string comment;
    public string app_comment {
        get { return comment; }
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
        exec = file.get_string ("Desktop Entry", "Exec").strip ();
        if (exec.get (exec.length - 2) == '%') {
            exec = exec.substring (0, exec.length - 2);
        }
        foreach (string code in desktop_codes) {
            if (exec.contains (code)) {
                exec = exec.replace (code, "");
                break;
            }
        }

        comment = file.get_string ("Desktop Entry", "Comment");

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
        button.relief = Gtk.ReliefStyle.NONE;
        button.always_show_image = true;
        button.clicked.connect (() => {
            instance.hide ();
            launch_app (exec);
        });
        button.show ();
    }

    public string to_string () {
        return "".concat ("name:", name, " icon:", icon, " exec:", exec);
    }

// placeholder, couldn't figure out hot to use Gio library.
    private string[] desktop_codes = new string[] {
        "%f",
        "%F",
        "%u",
        "%U",
        "%d",
        "%D",
        "%n",
        "%N",
        "%i",
        "%c",
        "%k",
        "%v",
        "%m",
    };
}

static AppEntry[] get_application_buttons (string[] dirs) {
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

                AppEntry app_entry = get_appentry (d.get_path (), filename);
                if (app_entry != null) {
                    apps += app_entry;
                }
            }
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
        }
    }

    return apps;
}

private static AppEntry get_appentry (string dir, string filename) {
    AppEntry app_entry = null;
    try{
        var filepath = Path.build_filename (dir, filename);
        app_entry = new AppEntry (filepath);
    } catch (Error e) {
        stderr.printf ("%s - %s\n", filename, e.message);
    }
    return app_entry;
}

static void launch_app (string exec) {
    MainLoop loop = new MainLoop ();

    try{
        Pid child_pid;
        Process.spawn_async (null,
                             new string[] { "sh", "-c", exec },
                             Environ.get (),
                             SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD
                             | SpawnFlags.STDOUT_TO_DEV_NULL | SpawnFlags.STDERR_TO_DEV_NULL,
                             null,
                             out child_pid);

        ChildWatch.add (child_pid, (pid, status) => {
            Process.close_pid (pid);
            loop.quit ();
            instance.app_quit ();
        });

        loop.run ();
    } catch (Error e) {
        stderr.printf ("%s\n", e.message);
    }
}

