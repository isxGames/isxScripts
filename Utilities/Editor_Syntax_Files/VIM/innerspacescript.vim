" ==============================================================
" Vim syntax file                                              =
" Language:     LavishScript                                  =
" Maintainer:   masterj                                       =
" Last Change:  Tue Sep 06, 2005                              =
" ==============================================================
" For version 5.x: Clear all syntax items                      =
" For version 6.x: Quit when a syntax file was already loaded  =
" ==============================================================

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case match

if version >= 600
  setlocal iskeyword=.,-,48-58,A-Z,a-z,_
else
  set iskeyword=.,-,48-58,A-Z,a-z,_
endif

syn case        ignore
syn match       scriptEscape            contained "\\."
syn match       scriptObject               contained /[a-zA-Z_][a-zA-Z0-9_]*[:\[\.]/me=e-1 nextgroup=ScriptObject,ScriptIndex,ScriptObjectAccess,scriptObjectEnd,scriptIdent
syn match       scriptObjectEnd          contained /[a-zA-Z_][a-zA-Z0-9_]*/ nextgroup=scriptObjectAccess,scriptIdent
syn match       scriptObjectAccess      contained ":\|\." nextgroup=scriptObjectEnd,scriptIdent
syn region      scriptIdent             contained matchgroup=Special start="\${" end="}" contains=scriptIdent,scriptIndex,scriptTypecast,scriptObject,scriptObjectEnd oneline
syn match      scriptIndicesSplitter    contained "\,"
syn match      scriptIndices            contained "[^,\]]\+" contains=scriptIdent,scriptString,scriptNumber,scriptOperator,scriptEscape
syn region      scriptIndex             contained matchgroup=Operator start=+\[+ skip=+\\\]+ end=+\]+  contains=scriptIndices,scriptIndicesSplitter nextgroup=scriptObjectAccess,scriptTypecast
syn match       scriptNumber            display contained "\([0-9]\+\.[0-9]\+\|[0-9]\+\)"
syn match       scriptOperator          contained /+\|\-\|\*\|\/\|<\|>\|=\|!\|&\||\|\~\|\^/

syn match       scriptCommandParameter  contained "[^; \t]\+" skipwhite nextgroup=scriptCommandParameter,scriptCommandList contains=scriptIdent,scriptNumber,scriptOperator,scriptString,scriptEscape

syn match       scriptCommandWord       contained "[ \t]*[^; \t]*" skipwhite nextgroup=scriptCommandParameter,scriptCommandList contains=scriptIndex,scriptString,scriptObject,scriptObjectAccess,scriptStatement,scriptRepeat,scriptBadCommands,scriptIdent

syn match       scriptCommandList         contained ";.*" contains=scriptCommandWord
syn match       scriptCommandLine         contained "^[^;]*" contains=scriptCommandWord,scriptBlock nextgroup=scriptCommandList
syn match       scriptBraceError        "^[ \t]*}"
syn region      scriptString            start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=scriptNumber,scriptOperator,scriptIdent,scriptEscape oneline

" ------------ individual commands -----------------
"  Add these groups to scriptCommandWord contains
"syn keyword    scriptConditional       contained if else switch endswitch
"syn keyword     scriptLabel             contained case default
syn keyword     scriptBadCommands       contained for next varcalc vardata varset goto
syn keyword     scriptRepeat            contained do while
syn keyword     scriptStatement         contained break return continue


" ------------ data types --------------------------
" types are case sensitive
syn case match

syn keyword     scriptType              contained string mutablestring byte float int uint int64 bool boolptr byteptr floatptr intptr intptr uintptr int64ptr rgbptr stringptr array time point3f rgb script buffer filepath file
syn match     scriptTypecast          contained "([^)]*)" contains=scriptType nextgroup=scriptObject

syn case ignore
" ------------- functions --------------------------
syn region      scriptBlock             matchgroup=Operator contained start="^[ \t]*{" end="^[ \t]*}" contains=scriptCommandLine,EmptyLine
syn region      functionBlock           matchgroup=Operator contained start="^[ \t]*{"hs=e+1 end="^[ \t]*}"me=e-1 contains=scriptCommandLine,EmptyLine
syn region     scriptFunctionRegion     start="^[ \t]*function[ \t]*.*" end="^[ \t]*}" contains=functionBlock,EmptyLine skipnl

" ------------- Preprocessor -----------------------
syn match       scriptComment           "^[ \t]*;.*"
syn region      scriptCComment          start="\/\*" end="\*\/"
syn match       scriptInclude           "^#include .*"
syn match       scriptInclude           "^#includeoptional .*"
syn region    scriptMacro        start="^[ \t]*#mac[ \t].*" end="^[ \t]*#endmac[ \t]*$"
syn match    scriptDefine        "^[ \t]*#\(define\|undef\)[ \t]*.*"
syn match    scriptPreCond       "^[ \t]*#\(if\|else\|endif\|elif\|ifdef\|ifndef\)[ \t]*.*"
syn match    scriptPreDisplay    "^[ \t]*#\(echo\|error\)[ \t]*.*"

if version >= 508 || !exists("did_bind_zone_syn_inits")
  if version < 508
    let did_bind_zone_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink scriptFunction Operator
  HiLink scriptComment  Comment
  HiLink scriptCComment Comment
  HiLink scriptConditional      Conditional
  HiLink scriptEscape   Constant
  HiLink scriptIdent    Constant
  HiLink scriptIndicesSplitter Operator
  HiLink scriptInclude  Include
  HiLink scriptLabel    Label
  HiLink scriptNumber   Number
  HiLink scriptOperator Operator
  HiLink scriptRepeat   Repeat
  HiLink scriptStatement        Statement
  HiLink scriptObject   Constant
  HiLink scriptObjectEnd Constant
  HiLink scriptObjectAccess Special
  HiLink scriptString   String
  HiLink scriptStructure        Structure
  HiLink scriptType     Type
  HiLink scriptTypecast Operator
  HiLink scriptBraceError Error
  HiLink scriptFunctionRegion Function

"sync scriptCComment scriptFunctionRegion scriptBlock functionBlock

" Specific commands
  HiLink scriptBadCommands Error

" General commands
  HiLink scriptCommandWord Structure
  HiLink scriptCommandWord2 Structure
"  HiLink scriptCommandLine
  HiLink scriptCommandList Operator
"  HiLink scriptCommandParameter

" Preprocessor
  HiLink scriptMacro Macro
  HiLink scriptDefine Define
  HiLink scriptPreCond PreCondit
  HiLink scriptPreDisplay PreProc

  delcommand HiLink
endif

let b:current_syntax = "lavishscript"
