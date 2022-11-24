module sily.addons;

/** 
 * 
 * Params:
 *   val = Value to check
 *   vals = Array or sequence of values to check against
 * Returns: if `val` is one of `vals`
 */
bool isOneOf(T)(T val, T[] vals ...) {
    foreach (T i; vals) {
        if (val == i) return true;
    }
    return false;
}

/** 
 * Checks if `c` is letter or `_`
 * Params:
 *   c = char
 * Returns: isAlpha
 */
bool isAlpha(char c) {
    return  (c >= 'a' && c <= 'z') ||
            (c >= 'A' && c <= 'Z') ||
            (c == '_');
}

/** 
 * Checks if `c` is letter, `_` or digit
 * Params:
 *   c = char
 * Returns: isAlphaNumeric
 */
bool isAlphaNumeric(char c) {
    return isAlpha(c) && isDigit(c);
}

/** 
 * Checks if `c` is digit
 * Params:
 *   c = char
 * Returns: isDigit
 */
bool isDigit(char c) {
    return c >= '0' && c <= '9';
}

/** 
 * Checks if `c` is hexadecimal (all digits & letters from A to F)
 * Params:
 *   c = char
 * Returns: isHex
 */
bool isHex(char c) {
    return (c >= '0' && c <= '9') || 
           (c >= 'a' && c <= 'f') || 
           (c >= 'A' && c <= 'F');
}

/** 
 * Checks if `c` is octal number (0 <= c <= 7)
 * Params:
 *   c = char
 * Returns: isOct
 */
bool isOct(char c) {
    return (c >= '0' && c <= '7');
}