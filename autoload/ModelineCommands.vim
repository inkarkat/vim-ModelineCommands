" ModelineCommands.vim: Extended modelines that allow the execution of arbitrary Vim commands.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2016-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
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
    \       'matchlist(v:val, ''\C\s[vV]im[cC]ommand\(!\)\?:\s*\(\%(\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\:\|[^:]\)\+\)\%(:\s*\('' . ingo#plugin#setting#GetBufferLocal("ModelineCommands_DigestPattern") . ''\)\s*\)\?:'')'
    \   ),
    \   '! empty(v:val)'
    \)
    return map(
    \   l:matches,
    \   '{"isSilent": ! empty(v:val[1]), "command": ingo#escape#Unescape(v:val[2], ":\\"), "digest": v:val[3]}'
    \)
endfunction
function! ModelineCommands#Get()
    let l:modelines = []
    for l:modeline in s:ExtractModelines()
	let [l:Validator, l:arguments] = (empty(l:modeline.digest) ?
	\   [ingo#plugin#setting#GetBufferLocal('ModelineCommands_CommandValidator'), [l:modeline.command]] :
	\   [ingo#plugin#setting#GetBufferLocal('ModelineCommands_DigestValidator'), [l:modeline.command, l:modeline.digest]]
	\)
	if empty(l:Validator)
	    let l:acceptPolicy = ingo#plugin#setting#GetBufferLocal('ModelineCommands_AcceptUnvalidated')
	    let l:isValid = 1
	else
	    let l:acceptPolicy = ingo#plugin#setting#GetBufferLocal('ModelineCommands_AcceptValidated')
	    try
		let l:isValid = call(l:Validator, l:arguments)
	    catch
		" Switch to policy for unvalidated commands.
		let l:acceptPolicy = ingo#plugin#setting#GetBufferLocal('ModelineCommands_AcceptUnvalidated')
		let l:isValid = 1

		call ingo#msg#ErrorMsg(printf('ModelineCommands: Error while validating command "%s": %s', l:modeline.command, ingo#msg#MsgFromVimException()))
	    endtry
	endif

	if l:isValid
	    if s:IsAccepted(l:acceptPolicy, l:modeline.command)
		call add(l:modelines, l:modeline)
	    endif
	else
	    call ingo#msg#ErrorMsg(printf('ModelineCommands: Command did not pass validation: %s', l:modeline.command))
	endif
    endfor
    return l:modelines
endfunction
function! s:IsAccepted( acceptPolicy, command )
    if a:acceptPolicy ==# 'no'
	call ingo#msg#WarningMsg(printf('ModelineCommands: Reject command %s', a:command))
	return 0
    elseif a:acceptPolicy ==# 'yes'
	return 1
    elseif a:acceptPolicy ==# 'ask'
	return ModelineCommands#QueryUser(a:command)
    else
	throw 'ASSERT: Invalid accept policy: ' . string(a:acceptPolicy)
    endif
endfunction

function! ModelineCommands#QueryUser( command )
    if has_key(g:ModelineCommands_DisallowedCommands, a:command)  || has_key(ingo#plugin#persistence#Load('MODELINECOMMANDS_DISALLOWED_COMMANDS', {}), a:command)
	return 0
    elseif has_key(g:ModelineCommands_AllowedCommands, a:command) || has_key(ingo#plugin#persistence#Load('MODELINECOMMANDS_ALLOWED_COMMANDS',    {}), a:command)
	return 1
    endif

    let l:response = ingo#plugin#persistence#QueryYesNo(printf("ModelineCommands: Execute command?\n%s", a:command))
    if l:response ==# 'Always'
	let g:ModelineCommands_AllowedCommands[a:command] = 1
	return 1
    elseif l:response ==# 'Never'
	let g:ModelineCommands_DisallowedCommands[a:command] = 1
	return 0
    elseif l:response ==# 'Forever'
	call ingo#plugin#persistence#Add('MODELINECOMMANDS_ALLOWED_COMMANDS', a:command, 1)
	return 1
    elseif l:response ==# 'Never ever'
	call ingo#plugin#persistence#Add('MODELINECOMMANDS_DISALLOWED_COMMANDS', a:command, 1)
	return 0
    else
	return (l:response ==# 'Yes')
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
" vimcommand: echomsg "I got loaded from ModelineCommands":
