/*
 * Copyright 2018 Abiola Ibrahim
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const int ICON_SIZE =96;
const int ICON_COLS =3;
const int BUTTON_CHAR_WIDTH =15;

public class AppEntry {

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
    public string app_name_wrap () {
        return wrap_text (name);
    }

    private string wrap_text (string text) {
        string[] str = text.split_set (" ");
        string[] reorder = {};
        string line = "";
        foreach (string s in str) {
            if (s.strip ().length == 0) {
                continue;
            }
            string concat = line.concat (" ", s);
            if (concat.length > BUTTON_CHAR_WIDTH) {
                reorder += line;
                line = s;
                continue;
            }
            line = concat;
        }
        if (line != "") {
            reorder += line;
        }
        return string.joinv ("\n", reorder);
    }

    private string search_name;
    public string app_search_name {
        get { return search_name; }
    }

    private string exec;
    public string app_exec {
        get { return exec; }
    }

    private string comment = "";
    public string app_comment {
        get { return comment; }
    }

    private bool terminal = false;
    public bool run_in_terminal {
        get { return terminal; }
    }
    public string app_keywords {
        get { return keywords; }
    }
    private string keywords = "";

    private string desktop_file;

    public AppEntry (string desktop_file) throws KeyFileError, FileError {
        this.desktop_file = desktop_file;
        load_desktop_file ();
    }


    private void load_desktop_file () throws KeyFileError, FileError {
        KeyFile file = new KeyFile ();

        file.load_from_file (desktop_file, KeyFileFlags.NONE);

        var type = file.get_string ("Desktop Entry", "Type");
        var no_display = false;
        if (file.has_key ("Desktop Entry", "NoDisplay")) {
            no_display = file.get_boolean ("Desktop Entry", "NoDisplay");

            // override nodisplay if `OnlyShowIn` is set.
            string desktop = Environment.get_variable ("XDG_CURRENT_DESKTOP");
            if (desktop != null) {
                if (file.has_key ("Desktop Entry", "OnlyShowIn")) {
                    string[] list = file.get_string_list ("Desktop Entry", "OnlyShowIn");
                    foreach (string l in list) {
                        if (l.down () == desktop.down ()) {
                            no_display = false;
                            break;
                        }
                    }
                } else if (file.has_key ("Desktop Entry", "NotShowIn")) {
                    string[] list = file.get_string_list ("Desktop Entry", "NotShowIn");
                    foreach (string l in list) {
                        if (l.down () == desktop.down ()) {
                            no_display = true;
                            break;
                        }
                    }
                }
            }
        }
        if (no_display || type != "Application") {
            throw new FileError.INVAL ("File is not an application, type: %s, file: %s".printf(type, desktop_file));
        }
        name = file.get_locale_string ("Desktop Entry", "Name");
        search_name = name.down ().replace (" ", ""); // get rid of whitespace for easier filter.
        icon = file.get_locale_string ("Desktop Entry", "Icon");
        exec = file.get_string ("Desktop Entry", "Exec").strip ();

        // DesktopAppInfo giving undesired results,
        // falling back to manually running the commands.
        // strip out desktop spec codes from the command.
        foreach (string code in desktop_codes) {
            if (exec.contains (code)) {
                exec = exec.replace (code, "").strip ();
                break;
            }
        }

        if (file.has_key ("Desktop Entry", "Comment")) {
            comment = file.get_locale_string ("Desktop Entry", "Comment");
        }

        if (file.has_key ("Desktop Entry", "Terminal")) {
            terminal = file.get_boolean ("Desktop Entry", "Terminal");
        }
        if (file.has_key ("Desktop Entry", "Keywords")) {
            keywords = file.get_locale_string ("Desktop Entry", "Keywords");
        }

        create_button ();
    }

    private void create_button () {
        var config = get_config ();

        Gtk.Image image = new Gtk.Image ();
        if (Path.is_absolute (app_icon)) {
            try{
                Gdk.Pixbuf buf = new Gdk.Pixbuf.from_file (app_icon);

                image.pixbuf = buf.scale_simple (config.icon_size, config.icon_size, Gdk.InterpType.BILINEAR);
            } catch (Error e) {
                stderr.printf ("could not load icon for %s, error: %s\n", app_name, e.message);
                image.icon_name = app_icon;
            }
        } else {
            image.icon_name = app_icon;
        }
        image.set_pixel_size (config.icon_size);
        image.show();

        Gtk.Label label = new Gtk.Label(app_name_wrap());
        label.xalign = 0.5f;
        label.set_justify(Gtk.Justification.CENTER);
        label.show();


        Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        box.pack_start(image);
        box.pack_start(label);
        box.show();

        button = new Button (this);
        button.set_image (box);
        button.set_image_position (Gtk.PositionType.TOP);
        button.relief = Gtk.ReliefStyle.NONE;
        button.always_show_image = true;
        button.tooltip_text = comment;
        button.clicked.connect (() => {
            Instance.app = this;
            Instance.window.close ();
        });
        button.show ();
    }

    public string to_string () {
        return "".concat ("name:", name, " icon:", icon, " exec:", exec);
    }
}

static AppEntry[] get_application_buttons (string[] dirs) {
    GenericArray < AppEntry > apps = new GenericArray < AppEntry > ();

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
                    apps.add (app_entry);
                }
            }
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
        }
    }

    apps.sort_with_data ((a, b) => {
        return strcmp (a.app_name.down (), b.app_name.down ());
    });

    return apps.data;
}

private static AppEntry get_appentry (string dir, string filename) {
    AppEntry app_entry = null;
    try{
        var filepath = Path.build_filename (dir, filename);
        app_entry = new AppEntry (filepath);
    } catch (FileError.INVAL e) {
    } catch (Error e) {
        stderr.printf ("%s - %s\n", filename, e.message);
    }
    return app_entry;
}

static void launch_app (string name, owned string exec, bool terminal, string ? extension = null) {
    MainLoop loop = new MainLoop ();

    if (terminal) {
        Terminal t = get_term ();
        exec = string.join (" ", t.command, t.flag, exec);
    }
    if (extension != null) {
        exec = extension.replace (APP_NAME_PLACEHOLDER, name)
                .replace (COMMAND_PLACEHOLDER, exec);
    }

    string[] args = new string[] { "sh", "-c", exec };

    try{
        Pid child_pid;
        Process.spawn_async (null,
                             args,
                             Environ.get (),
                             SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD
                             | SpawnFlags.STDOUT_TO_DEV_NULL | SpawnFlags.STDERR_TO_DEV_NULL,
                             null,
                             out child_pid);

        ChildWatch.add (child_pid, (pid, status) => {
            Process.close_pid (pid);
            loop.quit ();
        });

        loop.run ();
    } catch (Error e) {
        stderr.printf ("%s\n", e.message);
    }
}

static Terminal get_term () {
    foreach (Terminal t in terms) {
        if (Environment.find_program_in_path (t.command) != null) {
            return t;
        }
    }
    return terms[terms.length - 1];
}

struct Terminal {
    string command;
    string flag;
}

// this is a gtk app, prioritize gnome terminal.
const Terminal[] terms = {
    { "gnome-terminal", "--" },
    { "x-terminal-emulator", "-e" },
    { "lxterminal", "-e" },
    { "xfce4-terminal", "-e" },
    { "urxvt", "-e" },
    { "xterm", "-e" },
};

// placeholder, used becaused DesktopAppInfo is misbehaving.
const string[] desktop_codes = {
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

public class Button: Gtk.Button {
    public Button (AppEntry app) {
        Object ();
        this.app = app;
    }
    public AppEntry app;
}
