
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

using Gee;

const string COMMAND_PLACEHOLDER = "@s@";

struct Config {
    bool dark_theme;
    Map < string, Command > commands;
}

class Command {
    public string keyword;
    public string description = "";
    public string command;
}

static Config get_config () {
    Config c = { dark_theme: false, commands: new HashMap < string, Command > () };
    try{
        KeyFile file = load_key_file ("config.ini");
        c.dark_theme = file.get_boolean ("Config", "DarkTheme");
        c.commands = load_commands();
    } catch (Error e) {
        stderr.printf ("%s\n", e.message);
    }
    return c;
}

static KeyFile load_key_file (string file_name) throws Error {
    string file_path = Path.build_filename (Environment.get_user_config_dir (), "launchar", file_name);
    KeyFile key_file = new KeyFile ();

    if (!key_file.load_from_file (file_path, KeyFileFlags.NONE)) {
        throw new FileError.ACCES ("unknown error, could not load config file %s".printf(file_name));
    }
    return key_file;
}

static Map < string, Command > load_commands () {
    var map = new HashMap < string, Command > ();
    try{
        KeyFile key_file = load_key_file ("commands.ini");
        string[] groups = key_file.get_groups ();
        foreach (string group in groups) {
            Command c = new Command();
            c.keyword = group;
            if (!key_file.has_key (group, "Command")) {
                stderr.printf ("command missing for %s, ignoring...", group);
                continue;
            }
            c.command = key_file.get_string (group, "Command");
            if (key_file.has_key (group, "Desc")) {
                c.description = key_file.get_locale_string (group, "Desc");
            }
            map[group] = c;
            print("loaded "+ group);
        }
    } catch (Error e) {
        stderr.printf ("%s\n", e.message);
    }
    return map;
}
