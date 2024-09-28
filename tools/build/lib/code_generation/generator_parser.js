
import fs from 'fs';
import Juke, { sleep } from '../../juke/index.js';
import { LEX_ADD, LEX_COMMA, LEX_DM_INJECTION, LEX_DOT, LEX_EOL, LEX_EXTEND, LEX_INDEXER_OPEN, LEX_NAME, LEX_NUMBER, LEX_ONCE, LEX_PARENT_PROC, LEX_R_BRACKET, LEX_SET, LexString } from './generator_lexer.js';

/**
 *
 * @param {*} file
 * @returns {GenerationRule}
 */
export const ParseFile = (file) => {
  Juke.logger.debug(`Parsing file: ${file}`);
  const fileContents = fs.readFileSync(file, 'utf-8');
  const result = LexString(fileContents);
  let token_result = ProcessTokens(file, result);
  return token_result;
}

/**
 * Generate a rule from a string of tokens.
 * Why isn't this just a regex again?
 * @param {[{token: String, data: String}]} tokens
 * @returns {GenerationRule}
 */
const ProcessTokens = (file, tokens) => {
  Juke.logger.warn(JSON.stringify(tokens));
  let created_rule = new GenerationRule();
  let i = 0;
  while (i < tokens.length) {
    if (tokens[i].token === LEX_SET) {
      i++;
      let var_name = tokens[i];
      i++;
      // Skip the =
      i++;
      let var_value = tokens[i];
      // Parse the variable letter
      if (var_name.data === 'source') {
        created_rule.rule_name = var_value.data;
      } else if (var_name.data === 'run_order') {
        created_rule.run_order = parseInt(var_value.data);
      }
    } else if (tokens[i].token === LEX_EXTEND) {
      i++;
      // Skip the src part
      i++;
      // Read the proc name
      let proc_name = tokens[i];
      // Skip the open bracket
      i++;
      // Read the arguments
      //let rule_arguments : number[] = [];
      let rule_arguments = [];
      while (tokens[i].token !== LEX_R_BRACKET) {
        // Names
        if (tokens[i].token === LEX_NAME) {
          rule_arguments.push(tokens[i].data);
        }
        // Read the next token
        i++;
      }
      // Skip R bracket
      i++;
      // Skip the new line at the end
      if (tokens[i].token === LEX_EOL) {
        i++;
      }
      // Read the contents
      //let pre_token_stream : number[] = [];
      //let post_token_stream : number[] = [];
      let pre_token_stream = [];
      let post_token_stream = [];
      let pre = true;
      while ((i + 1 < tokens.length && tokens[i + 1].token !== LEX_EXTEND) || i + 1 == tokens.length) {
        if (tokens[i].token === LEX_PARENT_PROC) {
          pre = false;
          i++;
          continue;
        }
        if (pre) {
          pre_token_stream.push(tokens[i]);
        } else {
          post_token_stream.push(tokens[i]);
        }
        i++;
      }
      // Add the semi-parsed rule to the list of rules
      created_rule.extension_rules.push({
        name: proc_name.data,
        arguments: rule_arguments,
        pre_tokens: pre_token_stream,
        post_tokens: post_token_stream,
      });
    }
    i++;
  }
  if (created_rule.rule_name === null) {
    Juke.logger.error(`Generator defined at ${file} does not specify the name of the rule. Use 'set source = "define"' to specify the name of the define to execute the rule over.`);
    throw new Juke.ExitCode(1);
  }
  return created_rule;
}

export class GenerationRule {
  /**
   * @type {string}
   */
  rule_name;
  /**
   * @type {number}
   */
  run_order;
  /**
   * @type {{ name: string, arguments: number[], pre_tokens: {token: string, data: string}[], post_tokens: {token: string, data: string}[]}[]}
   */
  extension_rules;

  constructor() {
    this.rule_name = "";
    // Run last by default
    this.run_order = 100000;
    this.extension_rules = [];
  }

  /**
   *
   * @param {string} proc_name (full typepath included)
   * @param {string[]} proc_params
   * @param {string[]} rule_params
   * @returns {GeneratedBlock[]}
   */
  create_post_injection(proc_name, proc_params, rule_params) {
    // Create the code structures that we need
    // This json structure is accessible via proc.params[1]
    let state = {
      proc: {
        params: proc_params.map(x => ({
          name: x.substring(x.lastIndexOf('/') + 1),
          type: '/' + x.substring(0, x.lastIndexOf('/'))
        })),
        name: proc_name.substring(proc_name.lastIndexOf('/') + 1),
        fullpath: proc_name,
      },
      define: {
        params: rule_params
      }
    };
    let output = [];
    Juke.logger.log('Injecting proc name' + proc_name);
    // Convert tokens into a string
    for (const rule of this.extension_rules) {
      let block = new GeneratedBlock();
      block.proc_name = rule.name;
      block.content = "";
      // Token execution
      let current = 0;
      while (current < rule.post_tokens.length) {
        block.content += this.parse_token_stack(rule.post_tokens[current], state, () => {
          current++;
          return rule.post_tokens[current];
        });
        current ++;
      }
      output.push(block);
    }
    return output;
  }

  /**
   * Start parsing the token stack
   * @param {{token: string, data: string, line: number}} token
   * @param {Object} state
   * @param {function() : string} next_token
   * @returns {string}
   */
  parse_token_stack(token, state, next_token) {
    switch (token.token)
    {
      case LEX_EOL:
        return `\n`;
      case LEX_DM_INJECTION:
        return token.data;
      case LEX_NAME:
        if (typeof state[token.data] === 'string') {
          return state[token.data];
        }
        return this.parse_token_stack(next_token(), state[token.data], next_token);
      case LEX_DOT:
        return this.parse_token_stack(next_token(), state, next_token);
      case LEX_ADD:
        const once = next_token();
        // If we genuienly just find 'add' by itself, parse it as if it was anything else
        if (once.token !== LEX_ONCE) {
          return `add ${this.parse_token_stack(once, state, next_token)}`;
        }
        const function_name = next_token();
        next_token(); //skip brackets
        let next_parameter = next_token();
        while (next_parameter.token !== LEX_R_BRACKET) {
          // Skip commas
          if (next_parameter.token === LEX_COMMA) {
            next_parameter = next_token();
            continue;
          }
          // Do something with the parameter
          next_parameter = next_token();
        }
        return `add once ` + function_name.data;
      case LEX_INDEXER_OPEN:
        let number = next_token();
        if (number.token !== LEX_NUMBER) {
          Juke.logger.error(`Unexpected token encountered when parsing rule into string, ${token.token} is unhandled at line ${token.line}! Expected a [ token to be followed by a constant number.`);
          throw new Error();
        }
        const result = state[Number(number.data) - 1];
        // Skip the closing indexer
        next_token();
        if (typeof result === 'string') {
          return result;
        }
        return this.parse_token_stack(next_token(), result, next_token);
      default:
        Juke.logger.error(`Unexpected token encountered when parsing rule into string, ${token.token} is unhandled at line ${token.line}!`);
        throw new Error();
    }
  }

}

export class ProcParam {

  //proc_name: string;
  //proc_path: string;

}

export class GeneratedBlock {

  //proc_name: string;
  //post_injection: boolean;
  //content: string;

  /**
   * @type {string}
   */
  proc_name;
  /**
   * @type {boolean}
   */
  post_injection;
  /**
   * @type {string}
   */
  content;

}
