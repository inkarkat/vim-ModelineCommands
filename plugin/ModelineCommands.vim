" ModelineCommands.vim: Extended modelines that allow the execution of arbitrary Vim commands.
"
" DEPENDENCIES:
"   - ModelineCommands.vim autoload script
"   - ingo/msg.vim autoload script
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	13-Jul-2016	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_ModelineCommands') || (v:version < 700)
    finish
endif
let g:loaded_ModelineCommands = 1
let s:save_cpo = &cpo
set cpo&vim

"- configuration ---------------------------------------------------------------

if ! exists('g:ModelineCommands_FilePattern')
    let g:ModelineCommands_FilePattern = '*'
endif
if ! exists('g:ModelineCommands_FirstLines')
    let g:ModelineCommands_FirstLines = &modelines
endif
if ! exists('g:ModelineCommands_LastLines')
    let g:ModelineCommands_LastLines = &modelines
endif


"- autocmds --------------------------------------------------------------------

if ! empty(g:ModelineCommands_FilePattern)
    augroup ModelineCommands
	autocmd! BufReadPost *
	\   try |
	\       for g:ModelineCommands_Item in ModelineCommands#Get() |
	\           if &verbose > 0 |
	\               echomsg printf('ModelineCommands: Executing %s%s', (g:ModelineCommands_Item.isSilent ? 'silent! ' : ''), g:ModelineCommands_Item.command)|
	\           endif |
	\           try |
	\               if g:ModelineCommands_Item.isSilent |
	\                   silent! execute g:ModelineCommands_Item.command |
	\               else |
	\                   execute g:ModelineCommands_Item.command |
	\               endif |
	\           catch |
	\               call ingo#msg#VimExceptionMsg() |
	\           endtry |
	\       endfor |
	\   finally |
	\       unlet! g:ModelineCommands_Item |
	\   endtry
    augroup END
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
