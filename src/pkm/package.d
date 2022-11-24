module pkm.pkg;

// repo 
// name 
// version 
// (size (package size, installed size) | aur-votes (votes, popularity)) 
// [group]? 
// (orphaned) 
// (outofdate) 
// (installed: (version)) \n 
// (description)

struct Pkg {
    string repo = "aur";
    string name = "Package";
    string ver = "v0.0.0";
    string pkgsize = "0 KB"; // not aur
    string inssize = "0 KB";
    string group = ""; // community only
    bool isOrphaned = false;
    bool isOutdated = false;
    string outdatedDate = "";
    bool isInstalled = false;
    string installedVersion = "";
    string description = "";

    alias aurvotes = pkgsize; // aur
    alias aurpopul = inssize;
}