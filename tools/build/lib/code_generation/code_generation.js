
import fs from "fs";
import Juke from "../../juke/index.js";
import { ParseFile } from "./generator_parser.js";

const test = /^\/datum(\/\w+)+$/m;

export const RunCodeGeneration = async (dmeFile, generator_files) => {
  // Parse generators
  Juke.logger.info(`Running ${generator_files.length} code generators...`);
  for (const file of generator_files) {
    await ParseFile(file);
  }
  // TODO: Read the DME and get the code files from there
  const source_code = Juke.glob('code/**/*.dm');
  Juke.logger.info(`Performing pre-compilation generator injection on ${source_code.length} code files...`);
  for (const file of source_code) {
    const fileContents = fs.readFileSync(file, { encoding: 'utf-8' });
    fileContents.replace(test, "");
    fs.writeFileSync(file, { encoding: 'utf-8' })
  }
  Juke.logger.info("DM code generation complete!");
}
