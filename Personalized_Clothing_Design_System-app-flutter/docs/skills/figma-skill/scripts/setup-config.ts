import { execSync } from "child_process";
import fs from "fs";
import path from "path";

const SKILL_DIR = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");
const CONFIG_TEMPLATE = path.join(SKILL_DIR, ".env.example");
const CONFIG_LOCAL = path.join(SKILL_DIR, ".env");
const TEST_SCRIPT = path.join(SKILL_DIR, "scripts", "test-figma-connection.ts");

const apiKey = process.argv[2] || "";

function die(msg: string): never {
  console.error(`❌ ${msg}`);
  process.exit(1);
}

async function main(): Promise<void> {
  console.log("=========================================");
  console.log(" Figma Skill — 初始化配置");
  console.log("=========================================\n");

  if (!apiKey) {
    die("用法: npx tsx scripts/setup-config.ts <FIGMA_API_KEY>");
  }

  console.log("▶ 运行连接性测试...\n");
  try {
    execSync(`npx tsx "${TEST_SCRIPT}" "${apiKey}"`, { stdio: "inherit" });
  } catch {
    die("连接性测试未通过，配置中止");
  }

  console.log("\n▶ 写入配置...");
  if (!fs.existsSync(CONFIG_TEMPLATE)) {
    die(`未找到模板: ${CONFIG_TEMPLATE}`);
  }

  let content = fs.readFileSync(CONFIG_TEMPLATE, "utf-8");
  content = content.replace(/^FIGMA_API_KEY=.*$/m, `FIGMA_API_KEY=${apiKey}`);
  fs.writeFileSync(CONFIG_LOCAL, content, "utf-8");

  console.log(`  ✅ 已保存: ${CONFIG_LOCAL}`);
  console.log("\n=========================================");
  console.log(" 🎉 配置完成！现在可以使用 Figma 脚本了。");
  console.log("=========================================\n");
  console.log("  获取数据: python3 scripts/get-figma-data.py --file-key <KEY> [--node-id <ID>]");
  console.log("  下载图片: python3 scripts/download-figma-images.py --file-key <KEY> --node-ids <IDs> --output-dir <DIR>");
}

main();
