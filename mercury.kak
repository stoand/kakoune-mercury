# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*[.]m %{
    set-option buffer filetype mercury

    set-option buffer comment_line '%'

	# Mixing tabs and spaces will break
	# indentation sensitive syntax checking
    hook buffer InsertChar \t %{ try %{
      execute-keys -draft "h<a-h><a-k>\A\h+\z<ret><a-;>;%opt{indentwidth}@"
    }}

    hook buffer InsertDelete ' ' %{ try %{
      execute-keys -draft 'h<a-h><a-k>\A\h+\z<ret>i<space><esc><lt>'
    }}
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/mercury regions
add-highlighter shared/mercury/code default-region group
add-highlighter shared/mercury/string region (?<!'\\)(?<!')"  (?<!\\)(\\\\)*" fill string
add-highlighter shared/mercury/line_comment region \% $ fill comment

add-highlighter shared/mercury/code/ regex (?<!')\b0x+[A-Fa-f0-9]+ 0:value
add-highlighter shared/mercury/code/ regex (?<!')\b\d+([.]\d+)? 0:value

add-highlighter shared/mercury/code/ regex (?<!')\b(any_func|any_pred|atomic|cc_multi|cc_nondet|det|end_module|erroneous|external|external_pred|external_func|failure|finalize|finalise|func|implementation|import_module|include_module|initialise|initialize|inst|instance|interface|is|mode|module|multi|mutable|nondet|or_else|pragma|pred|promise|require_cc_multi|require_cc_nondet|require_complete_switch|require_det|require_erroneous|require_failure|require_multi|require_nondet|require_semidet|require_switch_arms_cc_multi|require_switch_arms_cc_nondet|require_switch_arms_det|require_switch_arms_erroneous|require_switch_arms_failure|require_switch_arms_multi|require_switch_arms_nondet|require_switch_arms_semidet|semidet|solver|trace|type|typeclass|use_module|where)(?!')\b 0:keyword
add-highlighter shared/mercury/code/ regex (?<!')\b(check_termination|consider_used|does_not_terminate|fact_table|inline|loop_check|memo|minimal_model|no_inline|obsolete|promise_equivalent_clauses|source_file|terminates|type_spec|foreign_code|foreign_decl|foreign_enum|foreign_export|foreign_export_enum|foreign_import_module|foreign_proc|foreign_type|affects_liveness|does_not_affect_liveness|doesnt_affect_liveness|attach_to_io_state|can_pass_as_mercury_type|stable|may_call_mercury|will_not_call_mercury|may_duplicate|may_not_duplicate|may_modify_trail|will_not_modify_trail|no_sharing|unknown_sharing|sharing|promise_pure|promise_semipure|tabled_for_io|local|untrailed|trailed|thread_safe|not_thread_safe|maybe_thread_safe|will_not_throw_exception|terminates|impure|promise_impure|promise_pure|promise_semipure|semipure|fail|false|true|if|then|else|impure_true|semidet_fail|semidet_false|semidet_succeed|semidet_true|some|all|not|try|catch|catch_any|promise_equivalent_solutions|promise_equivalent_solution_sets|arbitrary|yes|no|div|rem|mod)(?!')\b 0:keyword
add-highlighter shared/mercury/code/ regex \b([A-Z]['\w]*\.)*[A-Z]['\w]*(?!['\w])(?![.a-z]) 0:variable

add-highlighter shared/mercury/code/ regex \B'([^\\]|[\\]['"\w\d\\])' 0:string

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden mercury-trim-indent %{
    # remove trailing white spaces
    try %{ execute-keys -draft -itersel <a-x> s \h+$ <ret> d }
}

define-command -hidden mercury-indent-on-new-line %{
    evaluate-commands -draft -itersel %{
        # copy -- comments prefix and following white spaces
        try %{ execute-keys -draft k <a-x> s ^\h*\K--\h* <ret> y gh j P }
        # preserve previous line indent
        try %{ execute-keys -draft \; K <a-&> }
        # align to first clause
        try %{ execute-keys -draft \; k x X s ^\h*(if|then|else)?\h*(([\w']+\h+)+=)?\h*(case\h+[\w']+\h+of|do|let|where)\h+\K.* <ret> s \A|.\z <ret> & }
        # filter previous line
        try %{ execute-keys -draft k : mercury-trim-indent <ret> }
        # indent after lines beginning with condition or ending with expression or =(
        try %{ execute-keys -draft \; k x <a-k> ^\h*(if)|(case\h+[\w']+\h+of|do|let|where|[=(])$ <ret> j <a-gt> }
    }
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook -group mercury-highlight global WinSetOption filetype=mercury %{
    add-highlighter window/mercury ref mercury
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/mercury }
}

hook global WinSetOption filetype=mercury %{
    set-option window extra_word_chars '_' "'"
    hook window ModeChange insert:.* -group mercury-trim-indent  mercury-trim-indent
    # hook window InsertChar \n -group mercury-indent mercury-indent-on-new-line

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window mercury-.+ }
}




