MODELINE COMMANDS
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

Modelines are a comfortable means to adapt Vim settings (like filetype and
indentation), embedded in the edited file itself. For a power user, it would
be beneficial to apply the same concept to plugin settings and other
customizations. Unfortunately, modelines are not extensible, and cannot be
used to set variables or invoke other commands. One has to define |autocmd|s,
or use a local vimrc plugin, but those solutions all keep the configuration
separate from the edited file, so it's more effort to keep it in sync.

This plugin extends Vim's built-in modelines to execute any Ex command(s) when
a file is opened. A set of configurable validators examine the commands and
can verify the correctness of an optional command digest, in order to prevent
the execution of potentially malicious commands from unknown sources. This
way, you could restrict the commands to only simple :let, or have the plugin
query you to confirm execution of anything that isn't signed with your own
secret key.

### SEE ALSO

- The localrc plugin ([vimscript #3393](http://www.vim.org/scripts/script.php?script_id=3393)), especially with my own enhancements
  (https://github.com/inkarkat/vim-localrc/tree/enhancements) executes Vim
  scripts in the same directory as the opened file, also based on filetype.
  With this, you can place arbitrary customizations close to the file(s), but
  still external to them.

### RELATED WORKS

- let-modeline.vim ([vimscript #83](http://www.vim.org/scripts/script.php?script_id=83)) extends the modeline feature to the
  assignment of variables

USAGE
------------------------------------------------------------------------------

    Modeline commands are read and executed after the buffer has been read (i.e.
    on BufReadPost). The first and last lines of the buffer are searched for
    them.

    The modeline command syntax is similar to the second form of the built-in
    modeline feature, using the vimcommand: prefix instead of vim:
    The command(s) (you can both concatenate multiple Ex commands via :bar
    and/or have separate modeline commands on multiple lines) are concluded with a
    ":" (followed by an optional command digest for verification of its integrity,
    also concluded with a ":"); that means that colons within the command must be
    escaped by preceding them with a backslash.

        [text]{white}{vimcommand:|VimCommand:}[!][white]:{commands}:[text]
        [text]{white}{vimcommand:|VimCommand:}[!][white]:{commands}:[white]{digest}[white]:[text]

    [text]                  any text or empty
    {white}                 at least one blank character (<Space> or <Tab>)
    {vimcommand:|VimCommand:}the string "vimcommand:" or "VimCommand:"
    [!]                     optional marker for :silent! execution
    [white]                 optional white space
    {commands}              Ex commands
    :[white]{digest}[white] optional hash over {commands} and
                            g:ModelineCommands_Secret concatenated together, to
                            verify the integrity of {commands}
    :                       a colon
    [text]                  any text or empty

### EXAMPLE
```
   /\* vimcommand: let b:frobnize = "on": \*/
   /\* vimcommand: IndentConsistencyCopOff: \*/
   /\* vimcommand: echomsg "modeline commands\: an example" | version:7fab292cd: \*/
```

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-ModelineCommands
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim ModelineCommands*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.025 or
  higher.

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

If you want to search for modeline commands only in certain files, you can
specify autocmd-patterns instead of the default "\*". This must be set before
the plugin is sourced:

    let g:ModelineCommands_FilePattern = '*.h,*.c,*.cpp'

The number of lines at the start of the buffer that are searched for modeline
commands; the default is 'modelines'

    let g:ModelineCommands_FirstLines = 10

As arbitrary Vim commands can do harm to your system (with :! and :call
system(...), you can execute any external command!), there are two kinds of
gatekeepers:

Modeline commands that do not have a digest attached can be filtered based on
the command itself. You can configure a Funcref that takes the command as an
argument, and returns whether it should be allowed:

    let g:ModelineCommands_CommandValidator = function('...')

The validator probably will attempt to match the passed command with a regexp.
Note that blacklisting is unreliable, as there are many ways that malicious
commands can be written. Better just allow certain, harmless commands, and be
strict with your regular expression. The default validator tries to match the
command with a single regular expression:

Its default just allows simple :let and :echomsg of numbers and strings.

Both the modeline command and the digest are passed to this validator. The
validator should re-generate the digest from the passed command and a secret,
and compare that with the passed digest.

The format of the digest depends on the digest function, typically it is a
hexadecimal string. Vim's sha256() function returns a 64-digit hex number.
The default digest validator accepts shorter digests, so you can truncate the
long number in the modeline. How short (and therefore how insecure) the
digest can be can be configured in the digest pattern.

    let g:ModelineCommands_DigestPattern = '\x\{8,64}'

The default digest validator requires a secret string. Either put that
directly into the variable, or assign a Funcref that will return it. If a
person knows the secret, he can create valid digests for arbirary modeline
commands, and make you execute the command when you open the file, so guard
this secret carefully!

Validation establishes a certain level of security. If it fails, the command
will be rejected. You can still configure the policy for accepted commands,
one of "no" (discarded), "ask" (query you before execution), "yes" (allow).

Policy for commands where no (command or digest-based) validator is configured:
    let g:ModelineCommands_AcceptUnvalidated = "ask"

Policy for commands that passed a (command or digest-based) validator:

    let g:ModelineCommands_AcceptValidated = "yes"

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-ModelineCommands/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### GOAL
First published version.

##### 0.01    13-Jul-2016
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2016-2019 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat <ingo@karkat.de>
