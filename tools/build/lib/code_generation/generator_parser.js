
import fs from 'fs';
import Juke, { sleep } from '../../juke/index.js';
import { LexString } from './generator_lexer.js'

export const ParseFile = async (file) => {
  Juke.logger.log(`Parsing file: ${file}`);
  const fileContents = fs.readFileSync(file, 'utf-8');
  const result = LexString(fileContents);
  Juke.logger.log(result);
}
