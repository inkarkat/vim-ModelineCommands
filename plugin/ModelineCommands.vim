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
"	002	14-Jul-2016	Add several configuration variables.
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

if ! exists('g:ModelineCommands_AcceptUnvalidated')
    let g:ModelineCommands_AcceptUnvalidated = 'ask'
endif
if ! exists('g:ModelineCommands_AcceptValidated')
    let g:ModelineCommands_AcceptValidated = 'yes'
endif
if ! exists('g:ModelineCommands_AllowedCommands')
    let g:ModelineCommands_AllowedCommands = {}
endif
if ! exists('g:ModelineCommands_DisallowedCommands')
    let g:ModelineCommands_DisallowedCommands = {}
endif

if v:version < 702 | runtime autoload/ModelineCommands/Validators.vim | endif  " The Funcref doesn't trigger the autoload in older Vim versions.
if ! exists('g:ModelineCommands_CommandValidator')
    let g:ModelineCommands_CommandValidator = function('ModelineCommands#Validators#RegexpCommandValidator')
endif
if ! exists('g:ModelineCommands_DigestValidator')
    let g:ModelineCommands_DigestValidator = function('ModelineCommands#Validators#Sha256DigestValidator')
endif

if ! exists('g:ModelineCommands_ValidCommandPattern')
    let g:ModelineCommands_ValidCommandPattern = ''
endif
" g:ModelineCommands_Secret not defined here, as there's no sensible default.


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
" vimcommand: echomsg "I got loaded from ModelineCommands":
