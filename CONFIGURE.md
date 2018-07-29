configure
---------

config files are expected in `$XDG_CONFIG_HOME/launchar` or `$HOME/.config/launchar` if `$XDG_CONFIG_HOME` is unset.

## Appearance

Appearance is configurable via `config.ini`.

### Defaults

```
[Config]
DarkTheme=false # use gtk dark theme
IconSize=96     # icon size in pixels
Cols=3          # number of columns in the application grid.
```


## Commands

launchar can be extended with configurable commands in `commands.ini`. A command is triggered by appending `,<keyword>` to the search filter.

Each command is an entry with the following format.

```
[keyword]
Desc=command description
Command=command...
```

* `keyword` - the keyword to trigger the command.
* `Desc`    - description of what the command does.
* `Command` - command to run. Variables `@s@` and `@n@` can be used to retrieve application command and application name respectively.

### Examples

A command to lauch the current app in a custom i3 workspace.
```
[code]
Desc=open in 'code' workspace
Command=i3-msg workspace code; @s@
```

A command to send notification before and after launching application.
```
[notify]
Desc=notify before launch
Command=notify-send "launching @n@"; @s@; notify-send "@n@ is done"
```

The command description is displayed as you type, this can help verify the command.

![command demonstration](command.gif)



