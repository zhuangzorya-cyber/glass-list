#!/usr/bin/env bash
# ============================================================
# 一键把「我的清单」发布到 GitHub + 开启 Pages
# 用法（在 Git Bash 里，且当前目录已放好这 5 个文件）：
#   index.html  data.json  schema.md  AGENTS.md  README.md
#
#   export GH_TOKEN=ghp_你的真实token      # 仅本机内存，不写进任何文件
#   export REPO_NAME=glass-list            # 仓库名（可改）
#   export PRIVATE=true                    # true=私有 / false=公开
#   bash setup.sh
# ============================================================
set -uo pipefail

API="https://api.github.com"
AUTH="Authorization: Bearer $GH_TOKEN"
UA="Accept: application/vnd.github+json"

if [ -z "${GH_TOKEN:-}" ]; then
  echo "❌ 请先执行: export GH_TOKEN=ghp_xxx"; exit 1
fi
REPO_NAME="${REPO_NAME:-glass-list}"
PRIVATE="${PRIVATE:-true}"

# 1) 登录名
USER=$(curl -s -H "$AUTH" -H "$UA" "$API/user" | grep -o '"login":"[^"]*"' | head -1 | sed 's/"login":"//;s/"//')
if [ -z "$USER" ]; then echo "❌ token 无效，请检查 GH_TOKEN"; exit 1; fi
echo "✅ 已登录为: $USER"

# 2) 建仓库（已存在则忽略）
echo "📦 创建/复用仓库 $USER/$REPO_NAME (private=$PRIVATE) ..."
curl -s -o /tmp/gh_repo.json -w "HTTP %{http_code}\n" -H "$AUTH" -H "$UA" -X POST "$API/user/repos" \
  -d "{\"name\":\"$REPO_NAME\",\"private\":$PRIVATE,\"description\":\"My Liquid-Glass List — AI 自动归档同步\",\"auto_init\":false}" \
  >/dev/null
grep -o '"html_url":"[^"]*"' /tmp/gh_repo.json | head -1 | sed 's/"html_url":"//;s/"//' || true

# 3) 初始化并推送
git init -q 2>/dev/null || true
git config user.email "ai-sync@local"
git config user.name "AI Sync"
# 只提交这 6 个文件，避免误传工作区其它内容
git add index.html data.json schema.md AGENTS.md README.md setup.sh
git commit -q -m "init: liquid-glass list + sync rules" 2>/dev/null || echo "  (无新提交)"
git branch -M main 2>/dev/null || true
git remote remove origin 2>/dev/null || true
git remote add origin "https://x-access-token:${GH_TOKEN}@github.com/${USER}/${REPO_NAME}.git"
echo "🚀 推送到 main ..."
git push -u origin main -f

# 4) 开 Pages
echo "🌐 开启 GitHub Pages ..."
curl -s -o /tmp/gh_pages.json -w "HTTP %{http_code}\n" -H "$AUTH" -H "$UA" -X POST "$API/repos/$USER/$REPO_NAME/pages" \
  -d '{"source":{"branch":"main","path":"/"}}' >/dev/null
grep -o '"html_url":"[^"]*"' /tmp/gh_pages.json | head -1 | sed 's/"html_url":"//;s/"//' || true

# 5) 轮询 Pages 地址（构建需 30~90 秒）
echo "⏳ 等待 Pages 构建 ..."
PAGES=""
for i in $(seq 1 12); do
  sleep 8
  PAGES=$(curl -s -H "$AUTH" -H "$UA" "$API/repos/$USER/$REPO_NAME/pages" | grep -o '"html_url":"[^"]*"' | head -1 | sed 's/"html_url":"//;s/"//')
  [ -n "$PAGES" ] && break
done

echo ""
echo "🎉 完成！"
echo "   仓库:  https://github.com/$USER/$REPO_NAME"
echo "   Pages: ${PAGES:-（构建中，1~2 分钟后到仓库 Settings → Pages 查看）}"
echo ""
echo "📱 手机：用浏览器打开上面的 Pages 地址 → 点 分享 → 添加到主屏幕。"
if [ "$PRIVATE" = "true" ]; then
  echo "   （私有仓库：首次打开需用你的 GitHub 账号登录后才能看）"
fi
