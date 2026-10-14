// Run fyai (fyai/bin/claude) in place of the CLI that the TypeScript SDK bundles.
import { spawn } from "child_process";
import { fileURLToPath } from "url";
import path from "path";

const claude = process.env.FYAI_CLAUDE ||
  path.join(path.dirname(fileURLToPath(import.meta.url)), "fyai-claude");
const child = spawn(claude, process.argv.slice(2), { stdio: "inherit" });
for (const sig of ["SIGINT", "SIGTERM"])
  process.on(sig, () => child.kill(sig));
child.on("exit", (code, signal) => process.exit(signal ? 1 : code));
