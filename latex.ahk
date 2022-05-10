; ::aa::\alpha 
; ::aa::\alpha 
; ::bb::\beta 
; ::dd::\delta 
; ::gg::\gamma 
; ::ee::\epsilon 
; ::zz::\zeta 
; ::tt::\theta 
; ::ii::\iota 
; ::kk::\kappa 
; ::ll::\lambda 
; ::mm::\mu 
; ::nn::\nu 
; ::xx::\xi 
; ::oo::\omega 
; ::pp::\pi 
; ::rr::\rho 
; ::ss::\sigma 
; ::cc::\chi 
; ::uu::\upsilon

EmacsSelect()
{
    Send("{Alt Down}{Shift Down}{b 10}{Shift Up}{Alt Up}")
}

NormalSelect()
{
    Send("{Ctrl Down}{Shift Down}{Left 10}{Shift Up}{Ctrl Up}")
}

EmacsCopy()
{
    Send("^w")
}

NormalCopy()
{
    Send("^c")
}

EmacsPaste()
{
    Send("^y")
}

NormalPaste()
{
    Send("^v")
}

RAlt::
{
    title := WinGetTitle("A")
    isEmacs := (InStr(title, "Emacs") != 0)

    select := ""
    copy := ""
    paste := ""
    ;; for Emacs, use 
    if (isEmacs) {
        select := EmacsSelect
        copy := EmacsCopy
        paste := EmacsPaste
    } else {
        select := NormalSelect
        copy := NormalCopy
        paste := NormalPaste
    }

    select()

    ;; read them to clipboard
    A_Clipboard := ""
    Sleep(50)
    copy()
    if !ClipWait(0.1) {
        return
    }
    input := A_Clipboard
    Sleep(50)

    m := ""

    RegExMatch(input, "i)(?:(?<!\\)\$|\s)*(\S+) ((?!\$)[a-z]+)((?:(?<!\\)\$|\s)*)$", &m)
    if (m != "") {
        rest_len := StrLen(input) - StrLen(m[1]) - StrLen(m[2]) - StrLen(m[3]) - 1
        result := SubStr(input, 1, rest_len)

        ;; add hat / tilde...
        decorators1 := Map(
            "hat", "",
            "tilde", ""
        )

        if  (decorators1.Has(m[2])) {
            A_Clipboard := result . "\" . m[2] . "{" . m[1] . "} "
            paste()
            return
        }

        ;; add inv / transpose...
        decorators2 := Map(
            "tr", "\top",
            "inv", "-1"
        )

        x := decorators2.Get(m[2], "")
        if  (x != "") {
            A_Clipboard := result . m[1] . "^{" . x . "} "
            paste()
            return
        }
    }

    ;; match greek letter command
    RegExMatch(input, "i)(?:(?<!\\)\$|\s)*(\\[a-z]+)((?:(?<!\\)\$|\s)*)$", &m)
    if (m != "") {

        rest_len := StrLen(input) - StrLen(m[1]) - StrLen(m[2])
        result := SubStr(input, 1, rest_len)

        ;; expand greek letter abbr
        greeks := Map(
            "\alpha",       "aa",
            "\beta",        "bb",
            "\gamma",       "gg",
            "\delta",       "dd",
            "\epsilon",     "ee",
            "\zeta",        "zz",
            "\theta",       "tt",
            "\iota",        "ii",
            "\kappa",       "kk",
            "\lambda",      "ll",
            "\mu",          "mm",
            "\nu",          "nn",
            "\xi",          "xx",
            "\omega",       "oo",
            "\pi",          "pp",
            "\rho",         "rr",
            "\sigma",       "ss",
            "\chi",         "cc",
            "\upsilon",     "uu",
            "\epsilon",     "\varepsilon",
            "\varepsilon", "\eta",
            "\eta",         "ee",
            "\theta",       "\tau",
            "\tau",         "tt",
            "\pi",          "\phi",
            "\phi",         "pp"
        )

        expand := greeks.Get(m[1], "")
        if (expand != "") {
            A_Clipboard := result . expand . " "
            paste()
            return
        }

        ;; expand some abbrs
        abbrs := Map(
            "\to", "\rArr",
            "\rArr", "\implies",
            "\implies", "\mapsto",
            "\mapsto", "->",
            "\larr", "\lArr",
            "\lArr", "\Longleftarrow",
            "\Longleftarrow", "<-",
            "\leqslant", "<=",
            "\geqslant", ">=",
            "\sim", "~",
            "\approx", "~="
        )

        expand := abbrs.Get(m[1], "")
        if (expand != "") {
            A_Clipboard := result . expand . " "
            paste()
            return
        }
    }

    ;; match latex command
    RegExMatch(input, "i)\\([a-z]+)\{(\w+)\}\s*$", &m)
    if (m != "") {

        rest_len := StrLen(input) - StrLen(m[0])
        result := SubStr(input, 1, rest_len)

        ;; according to current style, choose next style
        style := m[1]
        next_style := ""
        if (style == "bm")
            next_style := "mathrm"
        else if (style == "mathrm")
            next_style := "mathcal"
        else if (style == "mathcal")
            next_style := "mathbb"
        else if (style == "mathbb")
            next_style := "mathfrak"
        else if (style == "mathfrak") { ;; back no no style
            A_Clipboard := result . m[2]
            paste()
            return
        }
        else return ;; unknown style or command, ignored
        
        ;; switch to next style
        A_Clipboard := result . "\" . next_style . "{" . m[2] . "}"
        paste()
        return
    }
    
    
    ;; match last word
    RegExMatch(input, "i)(?: |\$)?((?:(?!\$)\S)+)((?:\s|\$)*)$", &m)

    if (m != "") {

        rest_len := StrLen(input) - StrLen(m[1]) - StrLen(m[2])
        result := SubStr(input, 1, rest_len)

        last_word := m[1]

        ;; expand greek letter abbr
        greeks := Map(
            "aa", "\alpha",
            "bb", "\beta",
            "gg", "\gamma",
            "dd", "\delta",
            "ee", "\epsilon",
            "zz", "\zeta",
            "tt", "\theta",
            "ii", "\iota",
            "kk", "\kappa",
            "ll", "\lambda",
            "mm", "\mu",
            "nn", "\nu",
            "xx", "\xi",
            "oo", "\omega",
            "pp", "\pi",
            "rr", "\rho",
            "ss", "\sigma",
            "cc", "\chi",
            "uu", "\upsilon"
        )

        expand := greeks.Get(last_word, "")
        if (expand != "") {
            A_Clipboard := result . expand . " "
            paste()
            return
        }

        ;; expand some abbrs
        abbrs := Map(
            "->", "\to",
            "<-", "\larr",
            "<=", "\leqslant",
            ">=", "\geqslant",
            "!=", "\neq",
            "~=", "\approx",
            "~", "\sim"
        )

        expand := abbrs.Get(last_word, "")
        if (expand != "") {
            A_Clipboard := result . expand . " "
            paste()
            return
        }

        ;; expand ( to \(left \right)
        if (last_word == "(") {
            A_Clipboard := result . "\left( " . " \right)"
            paste()
            Send("{Left 8}")
            return
        }

        ;; expand / to \frac{}{•}
        if (last_word == "/") {
            A_Clipboard := result . "\frac{}{•}"
            paste()
            Send("{Left 4}")
            return
        }

        ;; expand case to case environment
        lm := ""
        RegExMatch(last_word, "i)case(\d)", &lm)

        if (lm != "") {
            result .= "`n\begin{cases}"
            loop lm[1] {
                result .= "`n    • &, • \\"
            }
            result .= "`n\end{cases}`n"

            A_Clipboard := result
            paste()

            first_dot_pos := InStr(result, "•")
            Send("{Left " . StrLen(result) - first_dot_pos . "}")
            Send("{BackSpace}")

            return
        }

        ;; expand _mat to matrix environment
        lm := ""
        RegExMatch(last_word, "i)(\w)mat(\d)(\d)", &lm)

        if (lm != "") {
            matrix_type := lm[1] . "matrix"
            result .= "`n\begin{" . matrix_type . "}"
            loop lm[2] {
                result .= "`n    "
                loop lm[3] - 1 {
                    result .= "• & "
                }
                result .= "• \\"
            }
            result .= "`n\end{" . matrix_type . "}`n"

            A_Clipboard := result
            paste()

            first_dot_pos := InStr(result, "•")
            Send("{Left " . StrLen(result) - first_dot_pos . "}")
            Send("{BackSpace}")

            return
        }

        ;; add bold style
        A_Clipboard := result . "\bm{" . last_word . "}"
        paste()
        return
    }
}

;; jump to next dot
CapsLock::{
    
    ;; selct texts from current line to end of current line
    Send("{Ctrl Down}{Shift Down}{End}{Shift Up}{Ctrl Up}")

    ;; read them to clipboard
    A_Clipboard := ""
    Sleep(50)
    Send("^c")
    if !ClipWait(0.1) {
        return
    }
    input := A_Clipboard

    ;; find the first dot (multiline)
    m := InStr(input, "•")

    ;; if there exists a dot, jump to its position and delete it
    Send("{Left}")
    if (m != 0) {

        ;; count \n
        count := 0
        loop parse SubStr(input, 1, m), "`n" {
            count += 1
        }

        Send("{Right " . m - count + 1 . "}")
        Send("{BackSpace}")
        return
    }
}