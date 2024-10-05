local luasnip = require 'luasnip'

-- snippets
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node
luasnip.add_snippets('vue', {
  s('vscript', {
    t { '<script setup lang="ts">', '' },
    i(1),
    t { '', '</script>' },
  }),
  s('vtemplate', {
    t { '<template>', '\t' },
    i(1),
    t { '', '</template>' },
  }),
  s('vcomponent', {
    t { '<script setup lang="ts">', '' },
    i(1),
    t { '', '</script>', '', '<template>', '' },
    i(2),
    t { '', '</template>' },
  }),
})
