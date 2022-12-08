module pkm.config;

import std.conv: to;
import std.file: exists;
import std.stdio: writeln, writefln, write;
import std.array: split;

import dyaml;

import pkm.search: writelncol;

import sily.bashfmt;
import sily.dyaml;

Config getConfig(string[] paths) {
    foreach (path; paths) {
        if (path.exists) {
            return __getConfig(path);
        }
    }
    return Config();
}

Config __getConfig(string configPath) {
    Node root;
    try {
        root = Loader.fromFile(configPath).load();
    } catch (YAMLException e) {
        writeln(e.msg);
        writelncol(FG.ltred, true, "Error: Invalid config. Using default configuration.");
        return Config();
    }

    Config conf;

    if (isType!(NodeType.mapping)(root) == false) return conf;

    root.getKey!string(&conf.yaypath, "yaypath");
    root.getKey!bool(&conf.yaysearch, "yaysearch");
    root.getKey!bool(&conf.color, "color");
    root.getKey!bool(&conf.auronly, "auronly");
    root.getKey!string(&conf.separator, "separator");
    root.getKey!string(&conf.separator_color, "separator-color");
    root.getKey!bool(&conf.separate, "separate");

    if (root.hasKeyType!(NodeType.mapping)("custom")) {
        auto custom = root["custom"].mappingKeys;
        foreach (key; custom) {
            if (isType!(NodeType.string)(key)) {
                string keyname = key.as!string;
                conf.custom ~= keyname;
                conf.args ~= root["custom"][keyname].as!string.split(' ');
            }
        }
    }

    if (root.hasKeyType!(NodeType.mapping)("managers")) {
        auto managers = root["managers"].mappingKeys;
        foreach (key; managers) {
            if (isType!(NodeType.string)(key)) {
                string keyname = key.as!string;
                conf.managers[keyname] = root["managers"][keyname].as!string;
            }
        }
    }

    if (root.hasKeyType!(NodeType.mapping)("alias")) {
        auto aliases = root["alias"].mappingKeys;
        foreach (key; aliases) {
            if (isType!(NodeType.string)(key)) {
                string keyname = key.as!string;
                conf.aliases[keyname] = root["alias"][keyname].as!string;
            }
        }
    }

    return conf;
}

string configGetGlobal(string configPath, string field) {
    Node root = Loader.fromFile(configPath).load();

    if (!root.isType!(NodeType.mapping)) return "";
    if (!root.hasKeyAs!string(field)) return "";

    return root[field].as!string;
}


struct Config {
    string yaypath = "";
    bool yaysearch = false;
    bool color = true;
    bool auronly = false;
    bool separate = false;
    string separator = "\u2500";
    string separator_color = "\033[90m";
    string[] custom = [];
    string[][] args = []; 
    string[string] aliases;
    string[string] managers;
    // TODO: overrides
    // TODO: aliases
}