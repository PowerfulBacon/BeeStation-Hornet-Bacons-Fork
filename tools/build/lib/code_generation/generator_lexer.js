
/**
 * Couldn't this just all be a regex?
 * Probably, but:
 * a) I thought that after I already wrote this. (sunk cost falacy)
 * b) There are a few complex behaviours that can very vaguely justify proper
 * parsing, IE the variables supported in the language which would have been
 * easier to implement if it used regex.
 */

import Juke from '../../juke/index.js';

// Keywords
export const LEX_SET = "set"; // Check
export const LEX_EXTEND = "extend"; // Check
export const LEX_PARENT_PROC = "..()";
export const LEX_PROC_NAME = "name"; // Check
export const LEX_PATHOF = "pathof"; // Check
export const LEX_SRC = "src"; // Check
export const LEX_ADD = "add"; // Check
export const LEX_ONCE = "once"; // Check

// Variables
export const LEX_NAME = "_name";
export const LEX_NUMBER = "_num";
export const LEX_STRING = "_string";

// Symbols
export const LEX_DOT = "\.";
export const LEX_INDEXER_OPEN = "[";
export const LEX_INDEXER_CLOSE = "]";
export const LEX_EQUALS = "=";
export const LEX_L_BRACKET = "(";
export const LEX_R_BRACKET = ")";
export const LEX_SLASH = "/";
export const LEX_SPACE = "space";
export const LEX_EOL = ";";
export const LEX_COMMA = ","

// Special
export const LEX_DM_INJECTION = "dm_injection";

// Failure
export const LEX_FAIL = 18;
export const LEX_FINISHED = 30;

const $a = 97;
const $b = 98;
const $c = 99;
const $d = 100;
const $e = 101;
const $f = 102;
const $g = 103;
const $h = 104;
const $i = 105;
const $j = 106;
const $k = 107;
const $l = 108;
const $m = 109;
const $n = 110;
const $o = 111;
const $p = 112;
const $q = 113;
const $r = 114;
const $s = 115;
const $t = 116;
const $u = 117;
const $v = 118;
const $w = 119;
const $x = 120;
const $y = 121;
const $z = 122;

const $A = 65;
const $B = 66;
const $C = 67;
const $D = 68;
const $E = 69;
const $F = 70;
const $G = 71;
const $H = 72;
const $I = 73;
const $J = 74;
const $K = 75;
const $L = 76;
const $M = 77;
const $N = 78;
const $O = 79;
const $P = 80;
const $Q = 81;
const $R = 82;
const $S = 83;
const $T = 84;
const $U = 85;
const $V = 86;
const $W = 87;
const $X = 88;
const $Y = 89;
const $Z = 90;

const $0 = 48;
const $1 = 49;
const $2 = 50;
const $3 = 51;
const $4 = 52;
const $5 = 53;
const $6 = 54;
const $7 = 55;
const $8 = 56;
const $9 = 57;

const $crt = 13;
const $space = 32;
const $dot = 46;
const $hash = 35;
const $eol = 10;
const $_ = 95;
const $lbr = 40;
const $rbr = 41;
const $lsbr = 91;
const $rsbr = 93;
const $tab = 9;
const $fwdslash = 47;
const $equals = 61;
const $string_marks = 34;
const $comma = 44;

let pointer = 0;
let lexing_input = "";

let buffer = "";

let currentCharCode = 0;

let lastToken = 0;
let lastData = '';

//let lex_output : (number | {token: number, data: string})[] = [];
let lex_output = [];

/**
 * Maintain a state so that we can do conditional parsing
 */
let state = {};

let error_message = "";

let eols_encountered = 1;

let eof = false;

export const LexString = input => {
  lexing_input = input;
  lex_output = [];
  buffer = "";
  pointer = 0;
  lastToken = 0;
  eols_encountered = 1;
  eof = false;
  while (pointer < lexing_input.length && !eof) {
    currentCharCode = lexing_input.charCodeAt(pointer);
    // Try to parse the line
    if (!parse_block() && !eof) {
      Juke.logger.log(lex_output);
      // TODO: better error message
      Juke.logger.error(`Failed to parse token ${lexing_input[pointer]} (${currentCharCode}) at position ${pointer}, line: ${eols_encountered}. Last token: ${lastToken}`);
      Juke.logger.error(error_message);
      throw new Juke.ExitCode(1);
    }
  }
  return lex_output;
};

/**
 * Parse a single line of the expression
 */
const parse_block = () => {
  error_message = "";
  // Reset the parser state
  state = {};
  ignore_whitespace()
  while ((FindChar($fwdslash, false) && FindChar($fwdslash, false)) || PeekChar($eol) || PeekChar($crt)) {
    SkipLine();
    ignore_whitespace()
  }
  if (eof) {
    return false
  }
  ignore_whitespace();
  if (FindChar($e, false)) {
    if (base_e() !== LEX_EXTEND) {
      error_message = error_message + " (Pass)\nInvalid token, expected either set or extend to start a line when outside of an extend code generation block.";
      return false;
    }
    return parse_extend();
  } else if (FindChar($s, false)) {
    // Find set
    if (base_s() !== LEX_SET) {
      error_message = error_message + " (Pass)\nInvalid token, expected either set or extend to start a line when outside of an extend code generation block.";
      return false;
    }
    return parse_set();
  } else {
    error_message = error_message +  ` (Pass)\nInvalid token, expected either set or extend to start a line when outside of an extend code generation block.`;
    return false;
  }
}

const parse_extend = () => {
  return ignore_whitespace()
      && require_token(LEX_SRC, "extend should always be preceeded by src, as there is not support for other typepaths atm.")
      && parse_extend_src();
      ;
}

const parse_extend_src = () => {
  return ignore_whitespace()
      && require_token(LEX_NAME, "a name to preceed extend src")
      && require_token(LEX_L_BRACKET, "extend should be in the format extend src name() (missing opening bracket)")
      && require_params()
      && require_token(LEX_R_BRACKET, "extend should be in the format extend src name() (missing closing bracket)")
      && require_token(LEX_EOL, "extend src Name() should be followed by a new line")
      && ignore_whitespace()
      && parse_block_contents()
      ;
}

const parse_set = () => {
  return require_token(LEX_SPACE, "a space to preceed the set keyword.")
      && require_token(LEX_NAME, "the set keyword to be followed by an alpha-numeric identifier")
      && ignore_whitespace()
      && require_token(LEX_EQUALS, "the set keyword should be of the form set variable = value. Could not find an equals.")
      && ignore_whitespace()
      && require_variable("the set keyword should be of the form 'set variable = value'. You have not proviated an appropriate value.")
      && require_end_of_line("the line should terminate after the set keyword is used.")
      ;
};

const push_token = (token, include_buffer) => {
  lastToken = token;
  if (include_buffer) {
    lex_output.push({
      token: token,
      data: buffer,
    })
    lastData = buffer;
  } else {
    lex_output.push(token);
    lastData = null;
  }
  buffer = '';
  return token;
}

const require_end_of_line = (error_msg) => {
  while (FindChar($space, false) || FindChar($tab, false))
    continue;
  return require_token(LEX_EOL, error_msg);
}

const ignore_whitespace = () => {
  while (true) {
    while (FindChar($fwdslash, false) && FindChar($fwdslash, false)) {
      SkipLine();
    }
    if (eof)
      return true;
    if (FindChar($eol, true)) {
      eols_encountered ++;
    }
    else if (!FindChar($space, true) && !FindChar($tab, true) && !FindChar($crt, true)) {
      error_message = "";
      return true;
    }
  }
}

const require_token = (token, invalid_text) => {
  error_message = error_message + ` (Pass)\nInvalid token, expected ${invalid_text}`;
  return next_token() === token;
}

const require_variable = (invalid_text) => {
  let located = next_token();
  if (located === LEX_NUMBER) {
    error_message = "";
    return true;
  } else if (located === LEX_NAME) {
    if (PeekChar($dot)) {
      located = next_token();
      if (located !== LEX_DOT) {
        error_message = error_message + ` (Pass)\nInvalid token, expected ${invalid_text}`;
        return false;
      }
      return require_variable(invalid_text);
    } else if (FindChar($lsbr, false)) {
      push_token(LEX_INDEXER_OPEN, false)
      if (next_token() !== LEX_NUMBER) {
        error_message = error_message + ` (Pass)\nInvalid token, expected a constant numeric value inside of an array index.`;
        return false;
      }
      if (next_token() !== LEX_INDEXER_CLOSE) {
        error_message = error_message + ` (Pass)\nInvalid token, array index was not closed with a constant numeric value inside.`;
        return false;
      }
    }
    error_message = "";
    return true;
  } else if (located === LEX_STRING) {
    error_message = "";
    return true;
  } else {
    error_message = error_message + ` (Pass)\nInvalid token, expected ${invalid_text}`;
    return false;
  }
}

const require_params = () => {
  if (PeekChar($rbr)) {
    return true;
  }
  ignore_whitespace();
  if (!require_token(LEX_NAME, "a named variable must be inside brackets of a function.")) {
    return false;
  }
  if (!state.params) {
    state.params = [];
  }
  state.params.push(lastData);
  ignore_whitespace();
  while (!PeekChar($rbr)) {
    ignore_whitespace();
    if (!require_token(LEX_COMMA, "parameters of a function must be seperated by commas.")) {
      return false;
    }
    ignore_whitespace();
    if (!require_token(LEX_NAME, "a named variable to come after a comma in the parameters of a function")) {
      return false;
    }
    ignore_whitespace();
    state.params.push(lastData);
  }
  Juke.logger.log(state.params);
  return true;
}

const next_token = () => {
  while (FindChar($fwdslash, false) && FindChar($fwdslash, false)) {
    SkipLine();
  }
  if (eof)
    return LEX_FINISHED;
  if (FindChar($a, false)) {
    return base_a();
  } else if (FindChar($e, false)) {
    return base_e();
  } else if (FindChar($o, false)) {
    return base_o();
  } else if (FindChar($s, false)) {
    return base_s();
  } else if (FindChar($P, false)) {
    return base_P();
  } else if (currentCharCode >= 48 && currentCharCode <= 57) {
    return base_read_number();
  } else if (FindChar($lbr, false)) {
    return push_token(LEX_L_BRACKET, false);
  } else if (FindChar($rbr, false)) {
    return push_token(LEX_R_BRACKET, false);
  } else if (FindChar($space, false) || FindChar($tab, false)) {
    buffer = "";
    return LEX_SPACE;
  } else if (FindChar($equals, false)) {
    return push_token(LEX_EQUALS, false);
  } else if (FindChar($lsbr, false)) {
    return push_token(LEX_INDEXER_OPEN, false);
  } else if (FindChar($rsbr, false)) {
    return push_token(LEX_INDEXER_CLOSE, false);
  } else if (FindChar($comma, false)) {
    return push_token(LEX_COMMA, false);
  } else if (FindChar($dot, false)) {
    return base_dot();
  } else if (FindChar($eol, false)) {
    eols_encountered ++;
    return push_token(LEX_EOL, false);
  } else if (FindChar($string_marks, false)) {
    return check_string();
  }else if ((currentCharCode >= 97 && currentCharCode <= 122) || (currentCharCode >= 65 && currentCharCode <= 90)) {
    return check_name();
  } else {
    error_message = "Unknown token";
    return LEX_FAIL;
  }
}

/**
 * Block contents tokens are special, since they will be treated as a raw replacement unless
 * a special character is reached.
 * Rules:
 * - Ignore comments
 * - If the line starts with add once func(params), then that is a valid special token
 * - ..() indicates the location of where we are going to be replacing
 * - A # indicates a special replacement token, and this will be parsed as a special token
 * - All characters are valid in these sections as block replacements.
 *
 * Note that relpacement of parameter variable injections will be done inside of the
 * generator's code and isn't our responsibility.
 *
 * Limitation: extend src and add once can only have a single space and not any amount of whitespace.
 */
const parse_block_contents = () => {
  while (true) {
    // Skip rest of the line when we see //
    while (FindChar($fwdslash, false) && FindChar($fwdslash, false)) {
      let tempBuffer = buffer.substring(0, buffer.length - 2);
      SkipLine();
      buffer = tempBuffer + '\n';
    }
    // Finish at end of line
    if (eof) {
      if (IsDataInBuffer()) {
        push_token(LEX_DM_INJECTION, true);
      }
      return false;
    }
    // Check for ..()
    if (FindChar($dot, false) && FindChar($dot, false) && FindChar($lbr, false) && FindChar($rbr, false)) {
      // Trim off the last 4 characters of the buffer
      buffer = buffer.substring(0, buffer.length - 4);
      if (IsDataInBuffer()) {
        push_token(LEX_DM_INJECTION, true);
      }
      push_token(LEX_PARENT_PROC, false);
      continue;
    }
    // Check for # replacements
    if (FindChar($hash, false) && FindChar($hash, false)) {
      // Trim off the last 4 characters of the buffer
      buffer = buffer.substring(0, buffer.length - 2);
      if (IsDataInBuffer()) {
        push_token(LEX_DM_INJECTION, true);
      }
      let found_token = next_token();
      if (found_token === LEX_PATHOF){
        if (!require_token(LEX_L_BRACKET, 'PATHOF should always be followed by an opening bracket.') || !require_variable("PATHOF should always contain a variable to get the path of") || !require_token(LEX_R_BRACKET, "PATHOF should always have a closing bracket after its variable")) {
          return false;
        }
        continue;
      } else if (found_token === LEX_PROC_NAME) {
        continue;
      } else {
        error_message = error_message + ` \nInvalid token, expected either PATHOF or PROC_NAME to supercede ## (Actually found ${found_token})`;
        return false;
      }
    }
    // Check for add once
    if (FindChar($a, false) && FindChar($d, false) && FindChar($d, false) && FindChar($space, false) && FindChar($o, false) && FindChar($n, false) && FindChar($c, false) && FindChar($e, false) && FindChar($space, false)) {
      buffer = buffer.substring(0, buffer.length - 9);
      if (IsDataInBuffer()) {
        push_token(LEX_DM_INJECTION, true);
      }
      push_token(LEX_ADD, false);
      push_token(LEX_ONCE, false);
      ignore_whitespace()
      if (!require_token(LEX_NAME, `Invalid token, expected a function name to appear after 'add once'`)) {
        return false;
      }
      if (!require_token(LEX_L_BRACKET, `Invalid token, the function name appearing after 'add once' was not properly bracketted.`)) {
        return false;
      }
      if (!require_token(LEX_R_BRACKET, `Invalid token, the function name appearing after 'add once' was not properly bracketted.`)) {
        return false;
      }
      push_token(LEX_EOL, false);
    }
    // Check if extend is upcoming and will finish us off
    if (FindChar($e, false) && FindChar($x, false) && FindChar($t, false) && FindChar($e, false) && FindChar($n, false) && FindChar($d, false) && FindChar($space, false) && FindChar($s, false) && FindChar($r, false) && FindChar($c, false)) {
      // Trim off the last 4 characters of the buffer
      buffer = buffer.substring(0, buffer.length - 10);
      if (IsDataInBuffer()) {
        push_token(LEX_DM_INJECTION, true);
      }
      state = {};
      push_token(LEX_EOL, false);
      push_token(LEX_EXTEND, false);
      push_token(LEX_SRC, false);
      return parse_extend_src();
    }
    // Just read until the end of the file
    if (!ReadChar(false)) {
      if (IsDataInBuffer()) {
        push_token(LEX_DM_INJECTION, true);
      }
      return true;
    }
  }
}

const base_read_number = () => {
  if (!ReadNumber()) {
    error_message = "Invalid token, numbers should not contain non-numeric characters.";
    return push_token(LEX_FAIL, false);
  }
  return push_token(LEX_NUMBER, true);
}

const base_dot = () => {
  if (!FindChar($dot, false) || !FindChar($lbr, false) || !FindChar($rbr, false)) {
    return push_token(LEX_DOT, false);
  }
  return push_token(LEX_PARENT_PROC, false);
}

const base_o = () => {
  if (!FindChar($n, false) || !FindChar($c, false) || !FindChar($e, false) || !PeekWhitespace()) {
    return check_name();
  }
  return push_token(LEX_ONCE, false);
}

const base_a = () => {
  if (!FindChar($d, false) || !FindChar($d, false) || !PeekWhitespace()) {
    return check_name();
  }
  return push_token(LEX_ADD, false);
}

const base_P = () => {
  if (FindChar($A, false)) {
    if (!FindChar($T, false) || !FindChar($H, false) || !FindChar($O, false) || !FindChar($F, false) || !PeekChar($lbr)) {
      return check_name();
    }
    return push_token(LEX_PATHOF, false);
  } else if (FindChar($R, false)) {
    if (!FindChar($O, false) || !FindChar($C, false) || !FindChar($_, false) || !FindChar($N, false) || !FindChar($A, false) || !FindChar($M, false) || !FindChar($E, false)) {
      return check_name();
    }
    return push_token(LEX_PROC_NAME, true);
  }
  return check_name();
};

const base_e = () => {
  if (!FindChar($x, false) || !FindChar($t, false) || !FindChar($e, false) || !FindChar($n, false) || !FindChar($d, false) || !PeekWhitespace()) {
    return check_name();
  }
  return push_token(LEX_EXTEND, false);
};

const base_s = () => {
  if (FindChar($r, false)) {
    return check_src()
  } else if (FindChar($e, false)) {
    return check_set()
  } else {
    return check_name();
  }
};

const check_src = () => {
  if (FindChar($c, false) && PeekWhitespace()) {
    return push_token(LEX_SRC, false);
  }
  return check_name();
}

const check_set = () => {
  if (FindChar($t, false) && PeekWhitespace()) {
    return push_token(LEX_SET, false);
  }
  return check_name();
}

const SkipLine = () => {
  if (eof) {
    return;
  }
  while (currentCharCode !== $eol) {
    increment_pointer();
    if (pointer >= lexing_input.length) {
      eof = true;
      currentCharCode = $eol;
      return;
    }
  }
  eols_encountered ++;
  increment_pointer();
  if (pointer >= lexing_input.length) {
    eof = true;
    currentCharCode = $eol;
  }
}

const ReadNumber = () => {
  if (currentCharCode < $0 || currentCharCode > $9) {
    return false;
  }
  while (currentCharCode >= $0 && currentCharCode <= $9) {
    buffer += lexing_input.charAt(pointer);
    increment_pointer();
    if (pointer >= lexing_input.length) {
      eof = true;
      currentCharCode = $eol;
      return true;
    }
  }
  return true;
}

const check_string = () => {
  while (currentCharCode !== $string_marks) {
    if (currentCharCode === $eol) {
      error_message = "Invalid token, string was not properly terminated.";
      return push_token(LEX_FAIL, false);
    }
    buffer += lexing_input.charAt(pointer);
    increment_pointer();
    if (pointer >= lexing_input.length) {
      eof = true;
      currentCharCode = $eol;
      error_message = "Invalid token, string was not properly terminated.";
      return push_token(LEX_FAIL, false);
    }
  }
  buffer += lexing_input.charAt(pointer);
  increment_pointer();
  if (pointer >= lexing_input.length) {
    eof = true;
    currentCharCode = $eol;
  }
  buffer = buffer.substring(1, buffer.length - 1)
  return push_token(LEX_STRING, true);
}

const check_name = () => {
  while (currentCharCode !== $space && currentCharCode !== $lbr && currentCharCode !== $rbr && currentCharCode !== $lsbr && currentCharCode !== $dot && currentCharCode !== $comma) {
    // If we encountered a /, then this is actually a path
    // We actually just don't care about paths
    if (currentCharCode === $fwdslash) {
      buffer = "";
      increment_pointer();
      continue;
    }
    // Bad characters
    if ((currentCharCode < $a || currentCharCode > $z) && (currentCharCode < $A || currentCharCode > $Z) && (currentCharCode < $0 || currentCharCode > $9) && currentCharCode !== $_) {
      error_message = "Invalid token, names must consist of alpha-numeric characters only.";
      return push_token(LEX_FAIL, false);
    }
    buffer += lexing_input.charAt(pointer);
    increment_pointer();
    if (pointer >= lexing_input.length) {
      eof = true;
      currentCharCode = $eol;
      return push_token(LEX_NAME, true);
    }
  }
  return push_token(LEX_NAME, true);
}

const FindChar = (char, no_buffer) => {
  if (currentCharCode === char) {
    if (!no_buffer)
      buffer += lexing_input.charAt(pointer);
    increment_pointer();
    if (pointer >= lexing_input.length) {
      eof = true;
      currentCharCode = $eol;
      return false;
    }
    return true;
  }
  return false;
}

const ReadChar = (no_buffer) => {
  if (!no_buffer)
    buffer += lexing_input.charAt(pointer);
  increment_pointer();
  if (pointer >= lexing_input.length) {
    eof = true;
    currentCharCode = $eol;
    return false;
  }
  return true;
}

const PeekChar = (char) => {
  return currentCharCode === char;
}

const PeekWhitespace = () => {
  return currentCharCode === $space || currentCharCode === $eol || currentCharCode === $tab;
}

const IsDataInBuffer = () => {
  return buffer.trim() !== '';
}

const increment_pointer = () => {
  pointer ++;
  if (pointer >= lexing_input.length) {
    currentCharCode = $eol;
    return;
  }
  currentCharCode = lexing_input.charCodeAt(pointer);
  while (currentCharCode == $crt) {
    pointer ++;
    if (pointer >= lexing_input.length) {
      currentCharCode = $eol;
      return;
    }
    currentCharCode = lexing_input.charCodeAt(pointer);
  }
}
