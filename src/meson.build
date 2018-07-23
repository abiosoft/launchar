sources += [
    'main.vala',
    'window.vala',
    'app_entry.vala',
]


# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    binary,
    sources,
    dependencies: [
        dependency('gtk+-3.0'),
    ],
    install: true
)
