# 直接写源文件：写作规则（强约束）

## 核心约束
- **不要做“模板填空”**：参考样张仅用于学习排版/结构/视觉风格。
- **不要引入 IR**：不生成 `resume.yaml`、不写 schema、不过一层渲染器。
- **必须可编译**：交付前必须能编译出 PDF。

## 写作步骤（推荐）
1) 先打开参考样张（`assets/template_refs/<lang>/template_001.<ext>`）。以了解参考的视觉风格。
2) 从零创建目标源文件并完整写出：
   - LaTeX：确保 preamble 自洽（字体、geometry、标题、列表），正文结构与样张一致。
   - Typst：先写全局样式与组件样式，再写正文。
   - HTML：先写 DOM 结构 + CSS，再写正文。
3) 编译为 PDF；发现错行/溢出/分页异常就回到源文件修正。

## 交付物（固定）
- 新建：`work/<name>.<ext>` + `work/<name>.pdf`
- 定制：`work/<name>.<ext>` + `work/<name>.pdf` + `work/<name>.changes.md`

除非用户要求，否则不交付摄取过程的临时文件。
