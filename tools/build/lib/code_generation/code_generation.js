/**
 * Code Generation:
 *
 * V1.0.0: @PowerfulBacon - Implements the initial code generation algorithm
 */

import fs from "fs";
import Juke from "../../juke/index.js";
import { GenerationRule, ParseFile } from "./generator_parser.js";

// Version number: Increment upon updates to this script to trigger a full rebuild
const VERSION_NUMBER = "0_1_9";

// Initialize startTime for performance tracking
let startTime = 0;

/**
 * Log message with execution duration and reset the start time.
 */
const printTime = (msg) => {
  const duration = (Date.now() - startTime) / 1e3;
  Juke.logger.info(`${msg} Duration: ${duration}s`);
  startTime = Date.now();
};

/**
 * Parse generation rules from the provided files.
 * @param {Array} generator_files - List of files to parse.
 * @returns {{[id: string] : GenerationRule}} A dictionary of parsed generation rules.
 */
const parseGenerationRules = async (generator_files) => {
  let generation_rules = {};
  for (const file of generator_files) {
    const generation_rule = await ParseFile(file);
    generation_rules[generation_rule.rule_name] = generation_rule;
  }
  return generation_rules;
};

/**
 * Ensure that the generated code file exists. If not, create it.
 * @param {string} gen_file - The file to check or create.
 * @returns {Date} The last modified time of the generation file.
 */
const ensureGeneratedFileExists = (gen_file) => {
  let rebuilt = false;
  if (!fs.existsSync(gen_file)) {
    if (!fs.existsSync("obj/")) fs.mkdirSync("obj/");
    fs.writeFileSync(gen_file, "", { encoding: "utf-8" });
    rebuilt = true;
  }
  return rebuilt ? new Date(0) : fs.statSync(gen_file).mtime;
};

/**
 * Build a dynamic regex for matching generation rules in source files.
 * @param {Object} generation_rules - The parsed generation rules.
 * @returns {RegExp} A dynamic regular expression for matching rules.
 */
const buildDynamicRegex = (generation_rules) => {
  return new RegExp(
    `^\\s*(${Object.keys(generation_rules).join("|")})(?:\\((.*?)\\))?\\s*(?:$|//|\\/\\*)` +
    `(?=(?:\\n|\\r|.)*?^((?:/\\w+)+(?:/proc)?/\\w*)\\(((?:\\s*[\\w/]+(?:\\s*,\\s*[\\w/]+)*)?\\s*)\\))`,
    "gm"
  );
};

/**
 * Inject code into the source files based on the generation rules.
 * @param {Array} source_code - List of source files to process.
 * @param {RegExp} dynamic_regex - Regex to find matches in the source files.
 * @param {Date} lastBuildTime - The time of the last code generation build.
 * @param {{[id: string] : GenerationRule}} generation_rules - Parameters related to code generation.
 */
const injectCodeIntoFiles = (source_code, dynamic_regex, lastBuildTime, generation_rules) => {
  let replacedSignatures = {};
  let skipped = 0;

  for (const path of source_code) {
    const file = fs.statSync(path);

    // Skip files that haven't been modified since the last build
    if (file.mtime < lastBuildTime) {
      //skipped++;
      //continue;
    }

    const fileContents = fs.readFileSync(path, { encoding: "utf-8" });

    // Apply generation rules to file contents
    for (const match of fileContents.matchAll(dynamic_regex)) {
      Juke.logger.info(`Updating code injection for file ${path} (File updated since last code injection).`);

      // Generate unique signature based on matched content
      const signature = `${match[3]}(${match[4]})`;
      let injection = replacedSignatures[signature];

      // If no injection exists for the signature, create a new one
      if (!injection) {
        injection = replacedSignatures[signature] = new CodeInjection(signature);
      }

      // Inject code here, you can use `generation_params` if necessary
      const define_name = match[1];
      const define_params = match[2];
      const target_proc = match[3];
      const target_params = match[4];

      // You can log or process generation_params here
      const target_rule = generation_rules[define_name];
      const post_injection = target_rule.create_post_injection(target_proc, target_params.split(",").map(x => x.trim()), define_params.split(",").map(x => x.trim()));
      injection.post_code += post_injection;
    }
  }

  return skipped;
};

/**
 * Main function to run the code generation process.
 * @param {string} dme_name - Name of the DME.
 * @param {Array} generator_files - List of generator files.
 */
export const RunCodeGeneration = async (dme_name, generator_files) => {
  startTime = Date.now();

  const gen_file = `obj/${dme_name}_v${VERSION_NUMBER}.dm`;

  // Parse generator rules
  const generation_rules = await parseGenerationRules(generator_files);

  // If no generation rules found, exit early
  if (Object.keys(generation_rules).length === 0) {
    Juke.logger.info("No generators installed, skipping code injection.");
    return;
  }
  printTime(`Code generation: Successfully parsed ${Object.keys(generation_rules).length} rules.`);

  // Ensure the generated code file exists and get its last modified time
  const lastBuildTime = ensureGeneratedFileExists(gen_file);

  // Build a dynamic regex for matching generation rules in source files
  const dynamic_regex = buildDynamicRegex(generation_rules);

  // Read source code files
  const source_code = Juke.glob("code/**/*.dm");
  printTime(`Located ${source_code.length} files for injection.`);

  // Inject code into the files and count how many were skipped
  const skipped = injectCodeIntoFiles(source_code, dynamic_regex, lastBuildTime, generation_rules);

  // Final logging of the code generation process
  printTime(`Code generation: DM code generation complete! (Skipped ${skipped}/${source_code.length} files)`);
};

/**
 * Class representing a code injection, storing signature, pre-code, and post-code.
 */
class CodeInjection {

  /**
   * @type {string}
   */
  signature;
  /**
  * @type {string}
  */
  pre_code;
  /**
   * @type {string}
   */
  post_code;

  constructor(signature = "") {
    this.signature = signature;
    this.pre_code = ``;
    this.post_code = ``;
  }
}
