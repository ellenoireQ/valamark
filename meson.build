project('valamark', 'vala', 'c')

deps = [dependency('glib-2.0'), dependency('gobject-2.0'), dependency('gee-0.8')]

valamark_lib = library(
  'valamark',
  [
    'class/lexer.vala',
    'class/token.vala',
    'class/ast.vala',
    'class/valamark.vala',
  ],
  dependencies: deps,
  vala_header: 'valamark.h',
  vala_vapi: 'valamark.vapi',
  install: true,
)

valamark_dep = declare_dependency(
  link_with: valamark_lib,
  include_directories: include_directories('class'),
  dependencies: deps,
)
