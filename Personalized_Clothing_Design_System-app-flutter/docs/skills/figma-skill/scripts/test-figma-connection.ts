import { execSync } from "child_process";
import https from "https";

const API_KEY = process.argv[2] || process.env.FIGMA_API_KEY || "";

let pass = 0;
let fail = 0;

const logPass = (msg: string) => { console.log(`  ✅ ${msg}`); pass++; };
const logFail = (msg: string) => { console.log(`  ❌ ${msg}`); fail++; };

function checkNode(): void {
  try {
    const ver = execSync("node -v", { encoding: "utf-8" }).trim();
    const major = parseInt(ver.replace("v", "").split(".")[0], 10);
    major >= 18 ? logPass(`Node.js ${ver} (>= 18 ✓)`) : logFail(`Node.js ${ver} 版本过低，需要 >= 18`);
  } catch {
    logFail("未找到 Node.js");
  }
}

function checkNpx(): void {
  try {
    execSync("npx --version", { encoding: "utf-8", stdio: "pipe" });
    logPass("npx 可用");
  } catch {
    logFail("未找到 npx");
  }
}

function checkApiKey(): Promise<void> {
  return new Promise((resolve) => {
    if (!API_KEY) {
      logFail("未提供 FIGMA_API_KEY（通过参数或环境变量）");
      console.log("\n用法:");
      console.log("  npx tsx scripts/test-figma-connection.ts <YOUR_FIGMA_API_KEY>");
      console.log("  或: FIGMA_API_KEY=xxx npx tsx scripts/test-figma-connection.ts\n");
      resolve();
      return;
    }

    const masked = `****${API_KEY.slice(-4)}`;
    logPass(`API Key 已提供 (${masked})`);

    const options = {
      hostname: "api.figma.com",
      path: "/v1/me",
      headers: { "X-Figma-Token": API_KEY },
    };

    https.get(options, (res) => {
      let body = "";
      res.on("data", (chunk: Buffer) => { body += chunk.toString(); });
      res.on("end", () => {
        if (res.statusCode === 200) {
          try {
            const data = JSON.parse(body);
            logPass(`认证成功 — 用户: ${data.handle || "unknown"} (${data.email || "unknown"})`);
          } catch {
            logPass("认证成功");
          }
        } else if (res.statusCode === 403) {
          logFail("API Key 无效或已过期 (HTTP 403)");
        } else if (res.statusCode === 429) {
          logFail("请求频率限制 (HTTP 429)，请稍后重试");
        } else {
          logFail(`API 返回异常 (HTTP ${res.statusCode})`);
        }
        resolve();
      });
    }).on("error", () => {
      logFail("网络请求失败（无法连接 api.figma.com）");
      resolve();
    });
  });
}

async function main(): Promise<void> {
  console.log("=========================================");
  console.log(" Figma Skill — 连接性测试");
  console.log("=========================================\n");

  console.log("▶ 环境检查");
  checkNode();
  checkNpx();
  console.log("");

  console.log("▶ API Key & 连接测试");
  await checkApiKey();
  console.log("");

  console.log("=========================================");
  console.log(` 结果: ${pass} 通过, ${fail} 失败`);
  console.log("=========================================");

  if (fail > 0) {
    process.exit(1);
  } else {
    console.log("\n🎉 所有检查通过！");
    process.exit(0);
  }
}

main();
