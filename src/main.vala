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

int main (string[] args) {
    var app = new Gtk.Application ("com.gitlab.abiosoft.launchar",
                                   ApplicationFlags.NON_UNIQUE);

    app.activate.connect (() => {
        var win = app.active_window;
        if (win == null) {
            win = (Instance.window = new LauncharWindow (app));
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
