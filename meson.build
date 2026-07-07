project('valamark', 'vala', 'c')

dependencies = [dependency('glib-2.0'), dependency('gobject-2.0'), dependency('gee-0.8')]

unit_test = executable(
  'valamark',
  ['test/test.vala', 'class/lexer.vala', 'class/token.vala', 'class/ast.vala'],
  dependencies: dependencies,
)

test('valamark basic test', unit_test)
