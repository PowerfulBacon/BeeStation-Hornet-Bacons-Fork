
import Juke from '../../juke/index.js';

// Keywords
export const LEX_SET = "set"; // Check
export const LEX_EXTEND = "extend"; // Check
export const LEX_PARENT_PROC = "proc";
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
export const LEX_EOL = "new_line";

// Failure
export const LEX_FAIL = 18;

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

const $space = 32;
const $dot = 46;
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

let pointer = 0;
let lexing_input = "";

let buffer = "";

let currentCharCode = 0;

let lastToken = 0;

let lex_output = [];

let error_message = "";

let eols_encountered = 1;

export const LexString = input => {
  lexing_input = input;
  lex_output = [];
  buffer = "";
  pointer = 0;
  lastToken = 0;
  eols_encountered = 1;
  while (pointer < lexing_input.length) {
    currentCharCode = lexing_input.charCodeAt(pointer);
    // Try to parse the line
    if (!parse_block()) {
      Juke.logger.log(lex_output);
      // TODO: better error message
      Juke.logger.error(`Failed to parse token ${lexing_input[pointer]} (${currentCharCode}) at position ${pointer}, line: ${eols_encountered}.`);
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
  while ((FindChar($fwdslash) && FindChar($fwdslash)) || PeekChar($eol)) {
    SkipLine();
  }
  ignore_whitespace();
  if (FindChar($e)) {
    if (base_e() !== LEX_EXTEND) {
      error_message = error_message || "Invalid token, expected either set or extend to start a line when outside of an extend code generation block.";
      return false;
    }
    return ignore_whitespace()
      && require_token(LEX_SRC, "extend should always be preceeded by src, as there is not support for other typepaths atm.")
      && require_token(LEX_EOL, "extend src should be followed by a new line")
      && ignore_whitespace()
      // TODO: Read the rest of the block by scanning until we find another extend
      && parse_block_contents()
      ;
  } else if (FindChar($s)) {
    // Find set
    if (base_s() !== LEX_SET) {
      error_message = error_message || "Invalid token, expected either set or extend to start a line when outside of an extend code generation block.";
      return false;
    }
    return require_token(LEX_SPACE, "a space to preceed the set keyword.")
      && require_token(LEX_NAME, "the set keyword to be followed by an alpha-numeric identifier")
      && ignore_whitespace()
      && require_token(LEX_EQUALS, "the set keyword should be of the form set variable = value. Could not find an equals.")
      && ignore_whitespace()
      && require_variable("the set keyword should be of the form 'set variable = value'. You have not proviated an appropriate value.")
      && require_end_of_line("the line should terminate after the set keyword is used.")
      ;
  } else {
    error_message = error_message || "Invalid token, expected either set or extend to start a line when outside of an extend code generation block.";
    return false;
  }
}

const parse_block_contents = () => {
  return true;
}

const push_token = (token) => {
  lex_output.push(token);
  lastToken = token;
  return token;
}

const require_end_of_line = (error_msg) => {
  while (FindChar($space) || FindChar($tab))
    continue;
  return require_token(LEX_EOL, error_msg);
}

const ignore_whitespace = () => {
  while (true) {
    while (FindChar($fwdslash) && FindChar($fwdslash)) {
      SkipLine();
    }
    if (FindChar($eol)) {
      eols_encountered ++;
    }
    else if (!FindChar($space) && !FindChar($tab)) {
      error_message = "";
      return true;
    }
  }
}

const require_token = (token, invalid_text) => {
  error_message = error_message || `Invalid token, expected ${invalid_text}`;
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
        error_message = error_message || `Invalid token, expected ${invalid_text}`;
        return false;
      }
      return require_variable(invalid_text);
    } else if (FindChar($lsbr)) {
      push_token(LEX_INDEXER_OPEN)
      if (next_token() !== LEX_NUMBER) {
        error_message = error_message || `Invalid token, expected a constant numeric value inside of an array index.`;
        return false;
      }
      if (next_token() !== LEX_INDEXER_CLOSE) {
        error_message = error_message || `Invalid token, array index was not closed with a constant numeric value inside.`;
        return false;
      }
    }
    error_message = "";
    return true;
  } else if (located === LEX_STRING) {
    error_message = "";
    return true;
  } else {
    error_message = error_message || `Invalid token, expected ${invalid_text}`;
    return false;
  }
}

const next_token = () => {
  while (FindChar($fwdslash) && FindChar($fwdslash)) {
    SkipLine();
  }
  if (FindChar($a)) {
    return base_a();
  } else if (FindChar($e)) {
    return base_e();
  } else if (FindChar($o)) {
    return base_o();
  } else if (FindChar($s)) {
    return base_s();
  } else if (FindChar($P)) {
    return base_P();
  } else if (currentCharCode >= 48 && currentCharCode <= 57) {
    return base_read_number();
  } else if (FindChar($lbr)) {
    return push_token(LEX_L_BRACKET);
  } else if (FindChar($rbr)) {
    return push_token(LEX_R_BRACKET);
  } else if (FindChar($space)) {
    return LEX_SPACE;
  } else if (FindChar($equals)) {
    return push_token(LEX_EQUALS);
  } else if (FindChar($lsbr)) {
    return push_token(LEX_INDEXER_OPEN);
  } else if (FindChar($rsbr)) {
    return push_token(LEX_INDEXER_CLOSE);
  } else if (FindChar($dot)) {
    return base_dot();
  } else if (FindChar($eol)) {
    eols_encountered ++;
    return push_token(LEX_EOL);
  } else if (FindChar($string_marks)) {
    return check_string();
  }else if ((currentCharCode >= 97 && currentCharCode <= 122) || (currentCharCode >= 65 && currentCharCode <= 90)) {
    return check_name();
  } else {
    error_message = "Unknown token";
    return LEX_FAIL;
  }
}

const base_read_number = () => {
  if (!ReadNumber($space)) {
    error_message = "Invalid token, numbers should not contain non-numeric characters.";
    return push_token(LEX_FAIL);
  }
  return push_token(LEX_NUMBER);
}

const base_dot = () => {
  if (!FindChar($dot) || !FindChar($lbr) || !FindChar($rbr)) {
    return push_token(LEX_DOT);
  }
  return push_token(LEX_PARENT_PROC);
}

const base_o = () => {
  if (!FindChar($n) || !FindChar($c) || !FindChar($e) || !PeekWhitespace()) {
    return check_name();
  }
  return push_token(LEX_ONCE);
}

const base_a = () => {
  if (!FindChar($d) || !FindChar($d) || !PeekWhitespace()) {
    return check_name();
  }
  return push_token(LEX_ADD);
}

const base_P = () => {
  if (FindChar($A)) {
    if (!FindChar($T) || !FindChar($H) || !FindChar($O) || !FindChar($F) || !PeekChar($lbr)) {
      return check_name();
    }
    return push_token(LEX_PATHOF);
  } else if (FindChar($R)) {
    if (!FindChar($O) || !FindChar($C) || !FindChar($_) || !FindChar($N) || !FindChar($A) || !FindChar($M) || !FindChar($E) || !PeekChar($lbr)) {
      return check_name();
    }
    return push_token(LEX_PROC_NAME);
  }
  return check_name();
};

const base_e = () => {
  if (!FindChar($x) || !FindChar($t) || !FindChar($e) || !FindChar($n) || !FindChar($d) || !PeekWhitespace()) {
    return check_name();
  }
  return push_token(LEX_EXTEND);
};

const base_s = () => {
  if (FindChar($r)) {
    return check_src()
  } else if (FindChar($e)) {
    return check_set()
  } else {
    return check_name();
  }
};

const check_src = () => {
  if (FindChar($c) && PeekWhitespace($space)) {
    return push_token(LEX_SRC);
  }
  return check_name();
}

const check_set = () => {
  if (FindChar($t) && PeekWhitespace($space)) {
    return push_token(LEX_SET);
  }
  return check_name();
}

const SkipLine = (char) => {
  while (currentCharCode !== $eol) {
    pointer ++;
    currentCharCode = lexing_input.charCodeAt(pointer);
  }
  eols_encountered ++;
  pointer ++;
  currentCharCode = lexing_input.charCodeAt(pointer);
}

const ReadNumber = () => {
  if (currentCharCode < $0 || currentCharCode > $9) {
    return false;
  }
  while (currentCharCode >= $0 && currentCharCode <= $9) {
    buffer += lexing_input.charCodeAt(pointer);
    pointer ++;
    currentCharCode = lexing_input.charCodeAt(pointer);
  }
  return true;
}

const check_string = () => {
  while (currentCharCode !== $string_marks) {
    if (currentCharCode === $eol) {
      error_message = "Invalid token, string was not properly terminated.";
      return push_token(LEX_FAIL);
    }
    buffer += lexing_input.charCodeAt(pointer);
    pointer ++;
    currentCharCode = lexing_input.charCodeAt(pointer);
  }
  buffer += lexing_input.charCodeAt(pointer);
  pointer ++;
  currentCharCode = lexing_input.charCodeAt(pointer);
  return push_token(LEX_STRING);
}

const check_name = () => {
  while (currentCharCode !== $space && currentCharCode !== $lbr && currentCharCode !== $lsbr && currentCharCode !== $dot) {
    if ((currentCharCode < $a || currentCharCode > $z) && (currentCharCode < $A || currentCharCode > $Z) && currentCharCode !== $_) {
      error_message = "Invalid token, names must consist of alpha-numeric characters only.";
      return push_token(LEX_FAIL);
    }
    buffer += lexing_input.charCodeAt(pointer);
    pointer ++;
    currentCharCode = lexing_input.charCodeAt(pointer);
  }
  return push_token(LEX_NAME);
}

const FindChar = (char) => {
  if (currentCharCode === char) {
    buffer += char;
    pointer ++;
    currentCharCode = lexing_input.charCodeAt(pointer);
    return true;
  }
  return false;
}

const PeekChar = (char) => {
  return currentCharCode === char;
}

const PeekWhitespace = () => {
  return currentCharCode === $space || currentCharCode === $eol || currentCharCode === $tab;
}
