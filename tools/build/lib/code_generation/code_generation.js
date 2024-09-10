
/**
 * Code Generation:
 *
 * V1.0.0: @PowerfulBacon - Implements the initial code generation algorithm
 */

import fs from "fs";
import Juke from "../../juke/index.js";
import { GenerationRule, ParseFile } from "./generator_parser.js";

// Version number: Increment upon updates to this script to trigger a full rebuild
const VERSION_NUMBER = "0_1_4";

export const RunCodeGeneration = async (dme_name, generator_files) => {
  const gen_file = `obj/${dme_name}_v${VERSION_NUMBER}.dm`;
  // Parse generators
  //let generation_rules : { [id: string] : GenerationRule } = {};
  let generation_rules = {};
  for (const file of generator_files) {
    const generation_rule = await ParseFile(file);
    generation_rules[generation_rule.rule_name] = generation_rule;
  }
  if (Object.keys(generation_rules).length === 0) {
    Juke.logger.info("No generators installed, skipping code injection.")
    return;
  }
  // Check the last generation time
  let rebuilt = false;
  if (!fs.existsSync(gen_file)) {
    if (!fs.existsSync(`obj/`)) {
      fs.mkdirSync(`obj/`);
    }
    fs.writeFileSync(gen_file, "", { encoding: "utf-8" });
    rebuilt = true;
  }
  const lastBuildTime = rebuilt ? new Date(0) : fs.statSync(gen_file).mtime;
  // Create a log of the files that we edited to update the last edit time
  // Create a regex that can detect the paterns that we wish to replace
  const dynamic_regex = new RegExp("^\\s*(" + Object.keys(generation_rules).join("|") + ")(?:\\((.*?)\\))?\\s*(?:$|//|\\/\\*)(?=(?:\\n|\\r|.)*?^((?:/\\w+)+(?:/proc)?/\\w*)\\(((?:\\s*[\\w/]+(?:\\s*,\\s*[\\w/]+)*)?\\s*)\\))", "gm");
  // TODO: Read the DME and get the code files from there
  const source_code = Juke.glob('code/**/*.dm');
  Juke.logger.log(dynamic_regex);
  Juke.logger.info(`Code generation: Successfully parsed ${Object.keys(generation_rules).length} rules. Performing pre-compilation generator injection on ${source_code.length} code files...`);
  // Store this data for usage later on
  //let replacedSignatures : { [id: string] : CodeInjection } = {};
  let replacedSignatures = {};
  let skipped = 0;
  for (const path of source_code) {
    // Check that the file is up to date
    // If it is, then skip
    let file = fs.statSync(path);
    if (file.mtime < lastBuildTime) {
      skipped ++;
      continue;
    }
    // Read the contents of the file
    let fileContents = fs.readFileSync(path, { encoding: 'utf-8' });
    // Execute generation requests
    for (const thing of fileContents.matchAll(dynamic_regex)) {
      Juke.logger.info(`Updating code injection for file ${path} (File updated since last code injection)`);
      // Calculate the signature
      // Signature varies if the parameter names are different to simplify multiple rulesets
      const signature = `${thing[3]}(${thing[4]})`;
      let injection = replacedSignatures[signature];
      // Create a new injection signature
      if (!injection) {
        injection = replacedSignatures[signature] = new CodeInjection();
        injection.signature = signature;
      }
      // Inject our code
    }
  }
  // Log the status of the generator
  Juke.logger.info(`Code generation: DM code generation complete! (Skipped ${skipped}/${source_code.length} files)`);
}

class CodeInjection {

  //signature: string;
  //pre_code: string[];
  //post_code: string[];

  constructor() {
    this.signature = "";
    this.pre_code = [];
    this.post_code = [];
  }

}
