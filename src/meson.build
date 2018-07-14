sources += [
    'main.vala',
    'window.vala',
]


# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    sources,
    dependencies: [
        dependency('gtk+-3.0')
    ],
    install: true
)
