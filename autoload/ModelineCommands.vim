" ModelineCommands.vim: Extended modelines that allow the execution of arbitrary Vim commands.
"
" DEPENDENCIES:
"   - ingo/escape.vim autoload script
"   - ingo/range/borders.vim autoload script
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	13-Jul-2016	file creation
let s:save_cpo = &cpo
set cpo&vim

function! s:GetLines( ranges )
    let l:lines = []
    for l:range in a:ranges
	let l:lines += call('getline', split(l:range, ','))
    endfor
    return l:lines
endfunction
function! s:ExtractModelines()
    let l:lines = s:GetLines(ingo#range#borders#StartAndEndRange(g:ModelineCommands_FirstLines, g:ModelineCommands_LastLines))
    let l:matches = filter(
    \   map(
    \       l:lines,
    \       'matchlist(v:val, ''\C\s[vV]im[cC]ommand\(!\)\?:\s*\(\%(\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\:\|[^:]\)\+\)\%(:\s*\(\x\{4,64}\)\s*\)\?:'')'
    \   ),
    \   '! empty(v:val)'
    \)
    return map(
    \   l:matches,
    \   '{"isSilent": ! empty(v:val[1]), "command": ingo#escape#Unescape(v:val[2], ":\\"), "digest": v:val[3]}'
    \)
endfunction
function! ModelineCommands#Get()
    return s:ExtractModelines()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
" vimcommand: echomsg "I got loaded from ModelineCommands":
