import std.stdio: writeln, writefln, stdin, File;
import std.getopt: getopt, Option, config;
import std.array : popFront, join, popBack;
import std.process : execute, environment, executeShell, spawnProcess, wait;
import std.algorithm : canFind, countUntil;
import std.file : readText, tempDir, remove, exists;
import std.path : baseName;

import pkm.search;
import pkm.config;

import sily.getopt;
import sily.bashfmt;
import sily.path: fixPath;


// --aur -a
// --no-aur
// --version -v
// --help -h
// search | yay -Ss term
// list | yay -Q
// info | yay -Qi
// install | yay -S term
// reinstall | yay -R & yay -S
// remove | yay -R term
// checkupdates | yay -Qu
// update | yay -Sy
// upgrade | yay -Su
// clone
// build
// clean | yay -Yc
// -- custom --
// stats | yay -Ps
// pkgbuild | yay -G term | yay -Gp term

private const string _version = "pkm v1.1.4";

int main(string[] args) {
    version (Windows) {
        writelncol(FG.ltred, true, "Error: unable to run on windows.");
        writefln("");
        return 1;
    }

    bool optVersion = false;
    bool optAur = false;

    auto help = getopt(
        args,
        config.bundling, config.passThrough,
        "version", "print version", &optVersion,
        "aur|a", "search only aur", &optAur
    );

    string[] configPath = [
        "~/.pkm.yaml".fixPath,
        "~/.config/pkm/pkm.yaml".fixPath,
        "~/.config/pkm/conf.yaml".fixPath,
    ];
    Config conf = getConfig(configPath);

    Option[] commands = [
        customOption("search", "[option] <package(s)>"),
        customOption("list", "[option]"),
        customOption("info", "[option] <package(s)>"),
        customOption("install", "[option] <package(s)>"),
        // Commands("reinstall", "[option] <package(s)>"),
        customOption("remove", "[option] <package(s)>"),
        customOption("checkupdates", "[option]"),
        customOption("update", "[option] <package(s)>"),
        customOption("upgrade", "[option] <package(s)>"),
        customOption("clean", "[option]"),
    ];

    if (optVersion) {
        writeln(_version);
        return 0;
    }

    if (help.helpWanted || args.length == 1) {
        Option[] customArgs = [];
        for (int i = 0; i < conf.custom.length; ++i) {
            customArgs ~= customOption(conf.custom[i], "");
            for (int j = 0; j < conf.args[i].length; ++j) {
                if (j > 0) customArgs[i].help ~= " ";
                customArgs[i].help ~= conf.args[i][j];
            }
        }
        Option[] aliases = [];
        foreach (key; conf.aliases.keys) {
            aliases ~= customOption(key, conf.aliases[key]);
        }
        if (customArgs.length > 0 && aliases.length > 0) {
            printGetopt("pkm <operation> [...]", 
                "Options", help.options, "Commands", commands, 
                "Custom", customArgs, "Aliases", aliases
            );
        } else 
        if (customArgs.length > 0) {
            printGetopt("pkm <operation> [...]", 
                "Options", help.options, "Commands", commands, "Custom", customArgs
            );
        } else 
        if (aliases.length > 0) {
            printGetopt("pkm <operation> [...]", 
                "Options", help.options, "Commands", commands, "Aliases", aliases
            );
        } else {
            printGetopt("pkm <operation> [...]", 
                "Options", help.options, "Commands", commands
            );
        }
        return 0;
    }

    string yay = "";
    bool yayDefined = false;
    string cyay = conf.yaypath.fixPath;
    if (cyay != "" && cyay.exists) {
        yayDefined = true;
        yay = cyay;
    } else if (cyay != "") {
        writelncol(
            FG.ltred, true, 
            "Error: cannot find package manager in \"" ~ conf.yaypath ~ "\"."
            );
        writefln("Attempting to guess yay location.");
        yay = "/usr/bin/yay";
    }

    if (!yayDefined) {
        string tmpFile = tempDir ~ "/" ~ "pkm-yay-path.txt";
        tmpFile = tmpFile.fixPath;

        auto processOut = File(tmpFile, "w+");
        wait(spawnProcess(["which", "yay"], stdin, processOut));
        processOut.close();
        string _out = tmpFile.readText();
        remove(tmpFile);
        _out.popBack();

        if (_out.canFind("which: no yay in")) {
            writelncol(FG.ltred, true, "Error: cannot find yay.");
            return 1;
        } else {
            yay = _out.fixPath;
        }
    }

    // writeln(yay);

    string[] ops = args.dup;
    ops.popFront(); // removes [0] command
    ops.popFront(); // removes 'command'

    if (optAur || conf.auronly) {
        ops ~= ["--aur"];
    }

    if (conf.aliases.keys.canFind(args[1])) {
        args[1] = conf.aliases[args[1]];
    }

    if (conf.custom.canFind(args[1])) {
        ulong argspos = conf.custom.countUntil(args[1]);
        string pkgmng = conf.args[argspos][0];
        if (conf.managers.keys.canFind(pkgmng)) {
            string ppath = conf.managers[pkgmng];
            if (ppath.fixPath.exists) {
                return wait(spawnProcess([ppath.fixPath] ~ conf.args[argspos][1..$] ~ ops));
            }
        }
        return wait(spawnProcess([yay] ~ conf.args[argspos] ~ ops));
    }

    switch (args[1]) {
        case "search":
            if (conf.yaysearch) {
                return wait(spawnProcess([yay, "-Ss"] ~ ops));
            } else {
                return search(yay, ops, conf);
            }
        case "list":
            return wait(spawnProcess([yay, "-Q"]));
        case "info":
            return wait(spawnProcess([yay, "-Qi"] ~ ops));
        case "install":
            return wait(spawnProcess([yay, "-S"] ~ ops));
        // case "reinstall":
        //     return wait(spawnProcess([yay, "-R"] ~ ops));
        //     return wait(spawnProcess([yay, "-S"] ~ ops));
        case "remove":
            return wait(spawnProcess([yay, "-R"] ~ ops));
        case "checkupdates":
            return wait(spawnProcess([yay, "-Qu"] ~ ops));
        case "update":
            return wait(spawnProcess([yay, "-Sy"] ~ ops));
        case "upgrade":
            return wait(spawnProcess([yay, "-Su"] ~ ops));
        case "clean":
            return wait(spawnProcess([yay, "-Yc"]));
        default: 
            writelncol(
                FG.ltyellow, true, 
                "Warning: unknown command \"" ~ args[1] ~ "\". Executing as is.\033[m"
                );

            return wait(spawnProcess([yay] ~ ops));
    }
}
