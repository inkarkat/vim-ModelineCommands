" ModelineCommands.vim: Extended modelines that allow the execution of arbitrary Vim commands.
"
" DEPENDENCIES:
"   - ModelineCommands.vim autoload script
"   - ingo/msg.vim autoload script
"
" Copyright: (C) 2016-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.005	24-Aug-2017	Correct regular expression for double-quoted
"				String: Must put the escaped inner double quote
"				branch before the non-quote branch.
"				Single-quoted one is fine.
"   1.00.004	19-Jul-2016	Define default
"				ModelineCommands_ValidCommandPattern that allows
"				:let and :echomsg.
"	003	16-Jul-2016	Extract g:ModelineCommands_DigestPattern.
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
if ! exists('g:ModelineCommands_DigestPattern')
    let g:ModelineCommands_DigestPattern = '\x\{8,64}'
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
    " let var = number | 0xHexNumber | 'string' | "string"
    " echosmg number | 0xHexNumber | 'string' | "string"
    let g:ModelineCommands_ValidCommandPattern = '^\%(let\s\+\<\%([bwglsav]:\)\=\h[a-zA-Z0-9#_]*\>\s*[.+-]\==\s*\|echom\%[sg]\s\+\)\%(-\=\d\+\%(\.\d\+\%([eE][+-]\=\d\+\)\=\)\=\|\<0[xX]\x\+\|''\%([^'']\|''''\)*''\|"\%(\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\"\|[^"]\)*"\)\s*$'
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
