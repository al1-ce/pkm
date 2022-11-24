module sily.bashfmt;

alias FG = Foreground;
alias BG = Background;
alias FM = Formatting;
alias RS = FormattingReset;

enum Foreground : string {
    reset = "\033[39m",
    black = "\033[30m",
    red = "\033[31m",
    green = "\033[32m",
    yellow = "\033[33m",
    blue = "\033[34m",
    magenta = "\033[35m",
    cyan = "\033[36m",
    ltgray = "\033[37m",
    dkgray = "\033[90m",
    ltred = "\033[91m",
    ltgreen = "\033[92m",
    ltyellow = "\033[93m",
    ltblue = "\033[94m",
    ltmagenta = "\033[95m",
    ltcyan = "\033[96m",
    white = "\033[97m"
}

enum Background : string {
    reset = "\033[49m",
    black = "\033[40m",
    red = "\033[41m",
    green = "\033[42m",
    yellow = "\033[43m",
    blue = "\033[44m",
    magenta = "\033[45m",
    cyan = "\033[46m",
    ltgray = "\033[47m",
    dkgray = "\033[100m",
    ltred = "\033[101m",
    ltgreen = "\033[102m",
    ltyellow = "\033[103m",
    ltblue = "\033[104m",
    ltmagenta = "\033[105m",
    ltcyan = "\033[106m",
    white = "\033[107m"
}

enum Formatting : string {
    bold = "\033[1m",
    dim = "\033[2m",
    italics = "\033[3m",
    uline = "\033[4m",
    blink = "\033[5m",
    inverse = "\033[7m",
    hidden = "\033[8m",
    striked = "\033[9m",
    dline = "\033[21m",
    cline = "\033[4:3m",
    oline = "\033[53"
}

enum FormattingReset : string {
    reset = "\033[0m",

    bold = "\033[21m",
    dim = "\033[22m",
    italics = "\033[22m",
    uline = "\033[24m",
    blink = "\033[25m",
    inverse = "\033[27m",
    hidden = "\033[28m",
    striked = "\033[29m",
    dline = "\033[24m",
    cline = "\033[4:0m",
    oline = "\033[55m"
}