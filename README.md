# 我的清单 — 个人捕获 · 分类 · 跨设备同步

一个**单文件**的手机端清单应用（待办 / 待读 / 想看 / 提示词），配合 AI 自动录入，并通过 GitHub Pages 实现手机同步。

设计语言：液态玻璃（Liquid Glass）+ Plus Jakarta Sans 字体。
数据唯一真源：`data.json`（页面 `fetch` 读取，AI 负责写入）。

---

## 1. 文件结构

```
index.html      ← 应用本体（界面 + 逻辑），从 ./data.json 读取数据
data.json       ← 数据唯一真源（AI 往这里写，手机拉这里看）
schema.md       ← 数据结构契约（字段 / 分类 / 标签词表）
AGENTS.md       ← 给「任何 AI」的操作手册（捕获→分类→写入→提交推送）
README.md       ← 本文件
```

---

## 2. 一次性部署（人来做）

1. 新建一个 GitHub 仓库，把这 5 个文件原样放进去（根目录）。
2. **开启 GitHub Pages**：仓库 Settings → Pages → Source 选 `main` 分支、`/ (root)` 目录 → Save。
3. 记下 Pages 地址，例如 `https://<user>.github.io/<repo>/`。
4. （可选）在手机 Safari / Chrome 打开该地址 → 分享 →「添加到主屏幕」，获得类 App 体验。

---

## 3. 给 AI 配写入权限（二选一）

- **方式 A（推荐，本地客户端如 WorkBuddy / CLI）**：执行 `gh auth login`，让 AI 能用 `gh` 提交。
- **方式 B（云端 AI / 无本地环境）**：在 GitHub 生成一个 **Fine-grained Personal Access Token**，勾选该仓库的 `Contents: Read and write`，把 token 配置给 AI（环境变量 `GH_TOKEN`）。详见 `AGENTS.md` §4。

> 安全提示：token 只给这一个仓库的最小权限；不要提交到仓库里、不要贴给第三方。

---

## 4. 日常使用

- **录入**：把想记的东西（文字 / 截图 / 链接）发给配好的 AI，它会自动分类并写进 `data.json` 然后推送。
- **查看**：手机打开 Pages 地址，下拉刷新即可看到新内容。
- **本机操作**：在页面上勾选完成、打标签、删除等，只保存在你这台设备的浏览器里（localStorage 覆盖层），用于本地视图，不会反向写回仓库。
- **换 AI / 换客户端**：把整个仓库（含 `AGENTS.md` + `schema.md`）交给新 AI 即可，它会照手册接手，无需重新培训。

---

## 5. 本地预览 / 调试

- 直接双击 `index.html` 也能看界面（此时会回退到内置示例数据 + 本地缓存，因为没有 `data.json` 的同源 fetch）。
- 想本地联调真实数据：在目录里起一个静态服务器，例如 `python3 -m http.server`，然后访问 `http://localhost:8000/`，页面就会读取本地 `data.json`。
- 改 UI（字体、配色、布局）只动 `index.html`；改数据规则看 `schema.md` / `AGENTS.md`。

---

## 6. 常见问题

- **手机看不到新条目？** 确认 AI 已成功 `push`；Pages 有构建延迟（通常几十秒~1 分钟），稍等或强制刷新。
- **页面空白 / 拉不到数据？** 检查 Pages 源是否为根目录、`data.json` 是否真的在根目录、JSON 是否合法（`jq . data.json`）。
- **本地改了删了，手机没变？** 本地操作是设备级覆盖，不会写回仓库；要全局生效必须通过 AI 改 `data.json`。
