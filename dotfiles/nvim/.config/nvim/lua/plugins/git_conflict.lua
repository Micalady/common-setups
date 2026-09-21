return {
  'akinsho/git-conflict.nvim',
  -- NOTE: same as telescope - track tagged releases only, not main
  version = '*',
  -- NOTE: `opts = {}` calls setup() with the plugin defaults. Left explicit
  -- here so the buffer-local maps it adds are visible without opening :help:
  --   co  - choose ours (current)      cb - choose both
  --   ct  - choose theirs (incoming)   c0 - choose none
  --   ]x / [x - next / previous conflict
  -- :GitConflictListQf loads every conflict in the repo into the quickfix list.
  -- Works on the <<<<<<< / ======= / >>>>>>> markers in the normal buffer, so it
  -- is a single-file alternative to Fugitive's three-way `dv` split.
  opts = {
    default_mappings = true,
    default_commands = true,
    disable_diagnostics = false,
    list_opener = 'copen',
  },
}
