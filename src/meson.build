sources += [
    'main.vala',
    'window.vala',
    'app_entry.vala',
    'config.vala',
]


# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    binary,
    sources,
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('gee-0.8'),
    ],
    install: true
)
