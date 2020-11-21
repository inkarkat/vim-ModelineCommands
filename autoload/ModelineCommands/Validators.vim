" ModelineCommands/Validators.vim: Default validators for modeline commands.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2016-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ModelineCommands#Validators#CompositeCommandValidator( command )
    try
	for l:Validator in g:ModelineCommands_CompositeCommandValidators
	    if call(l:Validator, [a:command])
		" Validator results are logically or-ed; i.e. we accept if one
		" validator accepts the command.
		return 1
	    endif
	endfor
    catch /^Reject$/
	return 0
    endtry

    return 0
endfunction

function! ModelineCommands#Validators#PreventPluginReconfigurationCommandValidator( command )
    if a:command =~# '\<let\s\+g:\%(ModelineCommands\|MODELINECOMMANDS\)_'
	throw 'Reject'
    endif
    return 0
endfunction

function! ModelineCommands#Validators#RegexpCommandValidator( command )
    let l:regexp = ingo#plugin#setting#GetBufferLocal('ModelineCommands_ValidCommandPattern')
    if empty(l:regexp)
	throw 'No regexp defined in ModelineCommands_ValidCommandPattern'
    endif

    return (a:command =~# l:regexp)
endfunction

function! ModelineCommands#Validators#Sha256DigestValidator( command, digest )
    let l:Secret = ingo#plugin#setting#GetBufferLocal('ModelineCommands_Secret', '')
    if empty(l:Secret)
	throw 'No secret defined in ModelineCommands_Secret variable'
    endif
    let l:secretValue = ingo#actions#ValueOrFunc(l:Secret)
    if empty(l:secretValue)
	throw printf('Function %s() from ModelineCommands_Secret variable did not yield a value', ingo#funcref#ToString(l:Secret))
    endif

    let l:newDigest = ingo#compat#sha256(a:command . l:secretValue)
    return ingo#str#StartsWith(l:newDigest, a:digest, 1)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
