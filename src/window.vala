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

[GtkTemplate (ui = "/com/gitlab/abiosoft/launchar/window.glade")]
public class LauncharWindow: Gtk.ApplicationWindow {

    [GtkChild]
    Gtk.Grid application_grid;

    [GtkChild]
    Gtk.ScrolledWindow application_scroll;

    [GtkChild]
    Gtk.SearchEntry search_apps;

    AppEntry[] applications;
    private AppEntry selectedApp;

    private Gtk.Application app;

    public LauncharWindow (Gtk.Application app) {
        Object (application: app);
        this.app = app;
        setup ();
    }

    private void setup () {
        this.show.connect (() => {
            this.set_keep_above (true);
        });

        key_press_event.connect (handle_esc_return);

        setup_applications ();
        setup_search ();
    }

    private bool handle_esc_return (Gdk.EventKey e) {
        if (e.keyval == Gdk.Key.Escape) {
            app.quit ();
            return true;
        }
        if (e.keyval == Gdk.Key.Return) {
            if (selectedApp != null) {
                selectedApp.app_button.clicked ();
            }
            return true;
        }
        return false;
    }

    private void setup_applications () {
        string[] dirs = Environment.get_system_data_dirs ();
        dirs += Environment.get_user_data_dir ();
        applications = get_application_buttons (dirs);
        filter_grid (null);
    }

    private void setup_search () {
        search_apps.grab_focus ();

        search_apps.search_changed.connect (() => {
            filter_grid (search_apps.text);
        });
    }

    void filter_grid (string ? f) {
        string ? filter = f == null ? null : f.down ();
        application_grid.forall ((element) => application_grid.remove (element));
        GenericArray < AppEntry > matches = new GenericArray < AppEntry > ();

        int count = 0;
        selectedApp = null;
        // filter
        for (int i = 0; i < applications.length; i++) {
            var app = applications[i];
            if (filter != null) {
                if (!app.app_name.down ().contains (filter)
                    && !app.app_search_name.contains (filter)
                    && !app.app_comment.down ().contains (filter)
                    && !app.app_keywords.down ().contains (filter)) {
                    continue;
                }
            }
            matches.add (app);
        }

        // sort
        // horrible bruteforce code.
        // should be done properly someday.
        if (filter != null) {
            matches.sort_with_data ((a, b) => {
                // prioritize name match over comment match
                string[] str = new string[] {
                    a.app_name.down (),
                    b.app_name.down (),
                    a.app_search_name,
                    b.app_search_name,
                    a.app_comment.down (),
                    b.app_comment.down (),
                    a.app_keywords.down (),
                    b.app_keywords.down (),
                };
                for (int i =0; i < str.length; i +=2) {
                    var s1 = str[i].has_prefix (filter);
                    var s2 = str[i + 1].has_prefix (filter);
                    if (s1 != s2) {
                        return s1 ? -1 : 1;
                    }
                    s1 = str[i].contains (filter);
                    s2 = str[i + 1].contains (filter);
                    if (s1 != s2) {
                        return s1 ? -1 : 1;
                    }
                }
                return strcmp (a.app_name.down (), b.app_name.down ());
            });
        }

        // add to grid
        foreach (AppEntry app in matches.data) {
            application_grid.attach (app.app_button, count % 3, count / 3);
            count++;
            if (selectedApp == null) {
                selectedApp = app;
            }
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

