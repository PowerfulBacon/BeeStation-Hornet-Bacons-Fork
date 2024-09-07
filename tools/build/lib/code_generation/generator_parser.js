
import fs from 'fs';
import Juke, { sleep } from '../../juke/index.js';
import { LEX_SET, LexString } from './generator_lexer.js';

export const ParseFile = async (file) => {
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
  let created_rule = new GenerationRule();
  created_rule.tokens = tokens;
  let i = 0;
  while (i < tokens.length) {
    if (tokens[i] == LEX_SET) {
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

  constructor() {
    this.rule_name = null;
    // Run last by default
    this.run_order = 100000;
    this.tokens = null;
  }

}
