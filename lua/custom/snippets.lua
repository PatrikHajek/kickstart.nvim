local luasnip = require 'luasnip'

-- snippets
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node

local snippets_eslint = {
  s('esd', { t { '/* eslint-disable ' }, i(1), t { ' */' } }),
  s('esl', { t { '// eslint-disable-next-line ' }, i(1) }),
}
luasnip.add_snippets('javascript', snippets_eslint)
luasnip.add_snippets('typescript', snippets_eslint)
luasnip.add_snippets('vue', snippets_eslint)

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
