
import fs from "fs";
import Juke from "../../juke/index.js";
import { ParseFile } from "./generator_parser.js";

const test = /^((?:\/\w+)+?)(?:\/proc)?\/(\w+)\((?:\/?(?:\w+\/)+)?\w+(?:\s*,\s*(?:\/?(?:\w+\/)+)?\w+)*\s*\)$/gm;

export const RunCodeGeneration = async (dmeFile, generator_files) => {
  // Parse generators
  let generation_rules = [];
  for (const file of generator_files) {
    generation_rules.push(await ParseFile(file));
  }
  // TODO: Read the DME and get the code files from there
  const source_code = Juke.glob('code/**/*.dm');
  Juke.logger.info(`Code generation: Successfully parsed ${generation_rules.length} rules. Performing pre-compilation generator injection on ${source_code.length} code files...`);
  let allTypePaths = {};
  for (const file of source_code) {
    let fileContents = fs.readFileSync(file, { encoding: 'utf-8' });
    for (const thing of fileContents.matchAll(test)) {
      let key = thing[1] + "/proc/" + thing[2];
      let existing = allTypePaths[key];
      if (!existing) {
        existing = [];
      }
      existing.push({ index: thing.index, file: file });
      allTypePaths[key] = existing;
    }
  }
  Juke.logger.info(`Code generation: Located ${Object.keys(allTypePaths).length} procs.`);
  Juke.logger.info("Code generation: DM code generation complete!");
}
