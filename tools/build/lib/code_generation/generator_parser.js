
import fs from 'fs';
import Juke, { sleep } from '../../juke/index.js';
import { LEX_EOL, LEX_EXTEND, LEX_NAME, LEX_PARENT_PROC, LEX_R_BRACKET, LEX_SET, LexString } from './generator_lexer.js';

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
 * @param {[{token: String, data: String}|String]} tokens
 * @returns {GenerationRule}
 */
const ProcessTokens = (file, tokens) => {
  Juke.logger.debug(tokens);
  let created_rule = new GenerationRule();
  let i = 0;
  while (i < tokens.length) {
    if (tokens[i] === LEX_SET) {
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
    } else if (tokens[i] === LEX_EXTEND) {
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
      while (tokens[i] !== LEX_R_BRACKET) {
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
      if (tokens[i] === LEX_EOL) {
        i++;
      }
      // Read the contents
      //let pre_token_stream : number[] = [];
      //let post_token_stream : number[] = [];
      let pre_token_stream = [];
      let post_token_stream = [];
      let pre = true;
      while (i + 1 < tokens.length - 1 && tokens[i + 1] !== LEX_EXTEND) {
        if (tokens[i] === LEX_PARENT_PROC) {
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

  //rule_name : string;
  //run_order : number;
  //extension_rules : { name: string, arguments: number[], pre_tokens: number[], post_tokens: number[]}[];

  constructor() {
    this.rule_name = "";
    // Run last by default
    this.run_order = 100000;
    this.extension_rules = [];
  }

  //create_pre_injection(proc_name: string, proc_params: ProcParam[], rule_params: string[]) {
  create_pre_injection(proc_name, proc_params, rule_params) {
    // Convert tokens into a string
    for (const rule of this.extension_rules) {
      let block = new GeneratedBlock();
      block.proc_name = rule.name;
      block.content = "";
      // Token execution

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

}
