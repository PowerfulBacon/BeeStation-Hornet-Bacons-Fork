
/// Regex that detects block comments
#define BLOCK_COMMENT_TRIMMER(name) var/regex/##name = new /regex(@"\/\*(?:.|\n|\r)*\*\/", "g")

/// Regex that detects regular comments
#define COMMENT_TRIMMER(name) var/regex/##name = new /regex(@"^\s*?\/\/", "gm")
