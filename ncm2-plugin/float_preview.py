# -*- coding: utf-8 -*-

# Remove `menu` and prepend it to `info` field of items for ncm2

def wrap():
    from ncm2_core import ncm2_core
    from ncm2 import getLogger
    import vim

    if vim.vars['float_preview#docked']:
        return

    old_matches_decorate = ncm2_core.matches_decorate

    def new_matches_decorate(*args):
        matches = args[-1]
        for m in matches:
            menu = m['menu']
            m['menu'] = ''
            info = m['info'].strip()
            if menu != info[:len(menu)]:
                m['info'] = menu + "\n\n" + info
        return old_matches_decorate(*args)

    ncm2_core.matches_decorate = new_matches_decorate

wrap()

