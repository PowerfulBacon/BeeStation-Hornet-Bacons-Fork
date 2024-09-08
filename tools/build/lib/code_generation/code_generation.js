
import fs from "fs";
import Juke from "../../juke/index.js";
import { ParseFile } from "./generator_parser.js";

// Version number: Increment upon updates to this script to trigger a full rebuild
const VERSION_NUMBER = "0_0_1";

const test = /^((?:\/\w+)+?)(?:\/proc)?\/(\w+)\((?:\/?(?:\w+\/)+)?\w+(?:\s*,\s*(?:\/?(?:\w+\/)+)?\w+)*\s*\)$/gm;

export const RunCodeGeneration = async (dme_name, generator_files) => {
  // Parse generators
  let generation_rules = [];
  for (const file of generator_files) {
    const generation_rule = await ParseFile(file);
    generation_rules.push(generation_rule);
  }
  if (generation_rules.length === 0) {
    Juke.logger.info("No generators installed, skipping code injection.")
    return;
  }
  // Check the last generation time
  if (!fs.existsSync(`obj/${dme_name}_v${VERSION_NUMBER}.gendat`)) {
    if (!fs.existsSync(`obj/`)) {
      fs.mkdirSync(`obj/`);
    }
    fs.writeFileSync(`obj/${dme_name}_v${VERSION_NUMBER}.gendat`, "", { encoding: "utf-8" });
  }
  const lastBuildTime = fs.statSync(`obj/${dme_name}_v${VERSION_NUMBER}.gendat`).mtime;
  // Create a log of the files that we edited to update the last edit time
  // Create a regex that can detect the paterns that we wish to replace
  const dynamic_regex = new RegExp("^\\s*(" + generation_rules.map(rule => rule.rule_name).join("|") + ")(?:\\((.*?)\\))?\\s*(?:$|//|\\/*)(?=(?:\\n|\\r|.)*?^((?:/\\w+)+(?:/proc)?/\\w*)\\(((?:\\s*[\\w/]+(?:\\s*,\\s*[\\w/]+)*)?\\s*)\\))", "gm");
  // TODO: Read the DME and get the code files from there
  const source_code = Juke.glob('code/**/*.dm');
  Juke.logger.info(`Code generation: Successfully parsed ${generation_rules.length} rules. Performing pre-compilation generator injection on ${source_code.length} code files...`);
  // Store this data for usage later on
  let allTypePaths = {};
  let replacementRequests = [];
  let skipped = 0;
  for (const path of source_code) {
    // Check that the file is up to date
    let file = fs.statSync(path);
    if (file.mtime < lastBuildTime) {
      skipped ++;
      continue;
    }
    // Read the contents of the file
    let fileContents = fs.readFileSync(path, { encoding: 'utf-8' });
    // Scan for proc names
    for (const thing of fileContents.matchAll(test)) {
      let key = thing[1] + "/proc/" + thing[2];
      let existing = allTypePaths[key];
      if (!existing) {
        existing = [];
      }
      existing.push({ index: thing.index, file: file });
      allTypePaths[key] = existing;
    }
    // Execute generation requests
    for (const thing of fileContents.matchAll(dynamic_regex)) {
      replacementRequests.push(thing);
      Juke.logger.info(`Updating code injection for file ${file} (File updated since last code injection)`);
    }
  }
  Juke.logger.info(`Code generation: (Skipped ${skipped}/${source_code.length} files) Located ${Object.keys(allTypePaths).length} procs and ${replacementRequests.length} attributes.`);
  // Write the build results
  Juke.logger.info("Code generation: DM code generation complete!");
}
