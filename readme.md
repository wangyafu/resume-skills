resume-master-skill是一个致力于帮您编写精美简历的 Skill，它可以帮你从0到1写出一份好简历，还可以帮你优化、针对特定JD修改旧简历。

## 核心亮点

- 内置 5 种精美模板，每种模板都包含面向AI的HTML和面向您的图片。
- 支持阅读 PDF，加载本 Skill 后，Agent 将会将 PDF 转换成图片，然后用阅读图片的工具，以此同时参考您旧简历中的内容和视觉风格。
- 引导 Agent 使用 HTML 形式写简历，并直接向您交付PDF文件
- 内置简历写作规范，从内容和样式上严格要求。

## 内置资源

5种精美模板：

- 典雅酒红
- 极客风尚
- 极简纯白
- 沉稳双栏
- 清新蓝灰
你可以查看 `skills\resume-master\assets\template_refs\images` 目录下的图片，了解模板的视觉效果。

3个脚本：

- 编译为 PDF（HTML → PDF）：`scripts/render_pdf.py`
- PDF 按页拆图（PDF → PNG/JPG）：`scripts/pdf_to_images.py`
- 获取PDF页数：`scripts/pdf_page_count.py`

## 安装指南

### 面向人类

将链接：<https://github.com/wangyafu/resume-skills交给你的Agent。>

### 面向Agent

skills\resume-master即为本项目提供的skills，请你将此skill安装到你的全局skills目录中。

- Claude Code：`~/.claude/skills/`
- Codex：`~/.codex/skills/`
- Antigravity：`~/.gemini/antigravity/skills/`

## 后续计划

- 增加更多模板
- 增加分行业、分岗位的指导文件
