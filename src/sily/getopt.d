module sily.getopt;

import std.getopt: Option;
import std.algorithm: max;
import std.stdio: writefln;

/** 
 * Prints passed **Option**s and text in aligned manner on stdout, i.e:
 * ```
 * A simple cli tool
 * 
 * Usage: 
 *   scli [options] [script] \
 *   scli run [script]
 * 
 * Options: 
 *   -h, --help   This help information. \
 *   -c, --check  Check syntax without running. \
 *   --quiet      Run silently (no output). 
 * Commands:
 *   run          Runs script. \
 *   compile      Compiles script.
 * ```
 * Params:
 *   text = Text to be printed at the beginning of the help output
 *   usage = Usage string
 *   com = Commands
 *   opt = The **Option** extracted from the **getopt** parameter
 */
void printGetopt(string text, string usage, Commands[] com, Option[] opt) {
    size_t maxLen = 0;

    foreach (it; opt) {
        int sep = it.optShort == "" ? 0 : 2;
        maxLen = max(maxLen, it.optShort.length + it.optLong.length + sep);
    }

    foreach (it; com) {
        maxLen = max(maxLen, it.name.length);
    }
    
    if (text != "") {
        writefln(text);
    }
    
    if (usage != "") {
        if (text != "") writefln("");
        writefln("Usage:");
        writefln("  " ~ usage);
    }

    if (com.length != 0) {
        if (text != "" || usage != "") writefln("");
        writefln("Options:");
    }

    foreach (it; opt) {
        // writefln("%*s %*s%s%s", 
        // shortLen, it.optShort,
        //     longLen, it.optLong,
        //     it.required ? " Required: " : " ", it.help);
        string opts = it.optShort ~ (it.optShort == "" ? "" : ", ") ~ it.optLong;
        writefln("  %-*s  %s", maxLen, opts, it.help);
    }

    if (com.length != 0) {
        if (text != "" || usage != "" || com.length != 0) writefln("");
        writefln("Commands:");
    }

    foreach (it; com) { 
        writefln("  %-*s  %s", maxLen, it.name, it.help);
    }
}

struct Commands {
    string name;
    string help;
}