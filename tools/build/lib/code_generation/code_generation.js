
import fs from "fs";
import Juke from "../../juke/index.js";
import { ParseFile } from "./generator_parser.js";

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
    fs.readFileSync(file);
  }
  Juke.logger.info("DM code generation complete!");
}
