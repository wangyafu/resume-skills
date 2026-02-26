#let text-primary = rgb("111827")
#let text-secondary = rgb("6b7280")
#let border-primary = rgb("d1d5db")
#let accent-medium = rgb("374151")

#let resume(
  name: "",
  photo: none,
  info: (),
  body
) = {
  set document(title: name + " - 简历", author: name)
  set text(font: ("Noto Sans SC", "PingFang SC", "Microsoft YaHei", "sans-serif"), size: 10.5pt, fill: text-primary, lang: "zh")
  set page(
    paper: "a4",
    margin: (x: 2cm, y: 2cm),
  )
  set par(justify: true, leading: 0.6em)

  // Header
  box(width: 100%, stroke: (bottom: 1pt + border-primary), padding: (bottom: 12pt))[
    #grid(
      columns: if photo != none { (80pt, 1fr) } else { (1fr) },
      column-gutter: 20pt,
      align: (center, top),
      if photo != none [
        #box(radius: 6pt, clip: true)[
          #image(photo, width: 80pt, height: 100pt, fit: "cover")
        ]
      ] else [],
      [
        #align(left)[
          #text(size: 20pt, weight: "bold")[#name]
          #v(10pt)
          #grid(
            columns: (1fr, 1fr, 1fr),
            row-gutter: 8pt,
            column-gutter: 12pt,
            ..info.map(i => text(size: 9.5pt)[#i])
          )
        ]
      ]
    )
  ]

  show heading.where(level: 2): it => {
    v(16pt)
    box(width: 100%, stroke: (bottom: 1pt + border-primary), padding: (bottom: 4pt))[
      #text(size: 14pt, weight: "semibold")[#it.body]
    ]
    v(8pt)
  }

  set list(indent: 12pt, marker: [▸])

  body
}

#let entry(
  title: "",
  subtitle: "",
  date: "",
  content
) = {
  v(8pt)
  grid(
    columns: (1fr, auto),
    [
      #text(weight: "bold")[#title]
      #if subtitle != "" [
        #h(6pt)
        #text(size: 10.5pt)[- #subtitle]
      ]
    ],
    align(right)[#text(size: 9.5pt, fill: text-secondary)[#date]]
  )
  v(6pt)
  content
}

#let project-meta(links: (), stats: ()) = {
  v(4pt)
  grid(
    columns: (auto, auto),
    column-gutter: 12pt,
    if links.len() > 0 [
      #links.map(l => box(fill: accent-medium, radius: 3pt, inset: (x: 6pt, y: 3pt), text(fill: white, size: 8pt)[#l])).join(h(8pt))
    ] else [],
    if stats.len() > 0 [
       #stats.map(s => box(stroke: 1pt + border-primary, radius: 10pt, inset: (x: 6pt, y: 3pt), text(size: 8pt)[#s])).join(h(8pt))
    ] else []
  )
  v(4pt)
}

#let project-desc(content) = {
  v(4pt)
  box(
    fill: rgb("f9fafb"),
    stroke: (left: 2pt + text-primary),
    inset: 8pt,
    width: 100%,
    radius: 3pt
  )[
    #text(size: 9.5pt)[#content]
  ]
  v(4pt)
}

#let highlight(content) = {
  text(weight: "semibold")[#content]
}

// ==========================================
// 示例数据
// ==========================================
#show: resume.with(
  name: "李明轩",
  photo: none,
  info: (
    [男 / 22 / *25届毕业生*],
    [13812345678],
    [limingxuan@example.com],
    link("https://github.com/limingxuan/")[Github个人主页],
    link("https://limingxuan.dev")[个人网站],
    [希望打造有趣又有用的AI产品],
    [北京理工大学(985) · 计算机科学与技术 · 2021.09-2025.07]
  )
)

== 实习经历

#entry(
  title: "字节跳动（抖音）",
  subtitle: "AI产品开发实习生",
  date: "2024年7月 - 至今",
)[
  作为核心成员参与抖音推荐算法优化项目，推动项目从概念验证到线上部署：
  - *问题分析与方案设计*: 在项目初期通过数据分析发现用户停留时长下降的痛点，为此提出基于#highlight("多模态内容理解")的个性化推荐策略，将#highlight("用户行为预测准确率提升15%")。
  - *技术实现与创新*: 为验证方案可行性，主导开发了#highlight("A/B测试平台")并落地两大层技术创新：设计了支持实时反馈的#highlight("动态权重调整机制")，并构建#highlight("内容质量评估")与#highlight("用户兴趣建模")相结合的双层过滤体系。
  - *成果与影响*: 该项目在向#highlight("技术总监")的汇报中获得认可，并成功完成上线，日活跃用户覆盖超过#highlight("1000万")。
]

#entry(
  title: "腾讯",
  subtitle: "产品策划实习生",
  date: "2024年3月 - 2024年6月",
)[
  - *微信小程序AI助手*: 主导微信生态AI助手小程序的产品设计。设计#highlight("多轮对话管理")等核心模块，使用#highlight("React")完成原型开发并撰写完整PRD文档。
  - *社交媒体数据分析工具*: 基于#highlight("Python数据分析")技术栈开发工具，集成API挖掘热点画像提取功能等。
]

== 个人项目

#entry(
  title: "SmartDataFlow",
  subtitle: "独立开发",
  date: "2024年2月",
)[
  #project-meta(links: ([Github地址], [演示视频]), stats: ([128 stars], [23 forks]))
  #project-desc[*项目简介*: 基于大模型的智能数据处理平台，用户只需描述需求，AI将自动调用工具完成数据分析和可视化任务。]

  - *多Agent协同架构*: 构建了数据分析Agent、可视化Agent及代码生成Agent的#highlight("分布式Agent系统")。各Agent间通过消息队列通信。
  - *智能上下文管理*: 引入#highlight("层次化知识图谱")机制。同时为每个数据集配置#highlight("语义化元数据")，提升理解。
]

== 专业技能

- 掌握#highlight("Python")、#highlight("JavaScript")技术栈，擅长推荐系统和前端开发。熟悉#highlight("React")、#highlight("Redis")/#highlight("MySQL")等开发框架。
- 熟悉#highlight("TensorFlow")/#highlight("PyTorch")框架，有推荐算法和多模态模型实战经验。
- 擅长#highlight("Agent架构设计")与#highlight("Chain-of-Thought")，熟悉#highlight("LangChain")、#highlight("OpenAI API") 等大模型应用框架。
