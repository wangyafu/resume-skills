#let text-primary = rgb("111827")
#let border-primary = rgb("d1d5db")
#let bg-white = rgb("ffffff")

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
    margin: (x: 2.5cm, y: 2.5cm),
  )
  set par(justify: true, leading: 0.6em)

  // Header
  // The header content takes up remaining space
  grid(
    columns: if photo != none { (80pt, 1fr) } else { (1fr) },
    column-gutter: 20pt,
    if photo != none [
      #image(photo, width: 80pt, height: 100pt, fit: "cover")
    ] else [],
    [
      #text(size: 20pt, weight: "bold")[#name]
      #v(10pt)
      // Display info array as contact items
      #grid(
        columns: (1fr, 1fr, 1fr), // Or automatic depending on length
        row-gutter: 8pt,
        column-gutter: 12pt,
        ..info.map(i => text(size: 9.5pt)[#i])
      )
    ]
  )

  show heading.where(level: 2): it => {
    v(16pt)
    text(size: 14pt, weight: "semibold")[#it.body]
    v(6pt)
    line(length: 100%, stroke: 1pt + border-primary)
    v(8pt)
  }

  set list(indent: 14pt, marker: [•])

  body
}

#let entry(
  title: "",
  subtitle: "",
  date: "",
  title-center: false,
  content
) = {
  v(8pt)
  if title-center {
    grid(
      columns: (1fr, 1fr, 1fr),
      text(weight: "bold")[#title],
      align(center)[#text(weight: "bold")[#subtitle]],
      align(right)[#text(size: 9.5pt, fill: text-primary.lighten(30%))[#date]]
    )
  } else {
    grid(
      columns: (1fr, auto),
      [
        #text(weight: "bold")[#title]
        #if subtitle != "" [
          #h(8pt)
          #text(size: 10.5pt)[#subtitle]
        ]
      ],
      align(right)[#text(size: 9.5pt, fill: text-primary.lighten(30%))[#date]]
    )
  }
  v(6pt)
  content
}

#let highlight(content) = {
  text(weight: "semibold")[#content]
}

// ==========================================
// 以下为内容区域示例
// ==========================================

#show: resume.with(
  name: "李明轩",
  // TODO: 如果有本地图片可以替换此处的none为路径，如 "photo.png"
  photo: none,
  info: (
    [男 / 22 / *25届毕业生*],
    [13812345678],
    [limingxuan@example.com],
    link("https://github.com/limingxuan/")[Github个人主页],
    link("https://limingxuan.dev")[个人网站],
    [希望打造有趣又有用的AI产品]
  )
)

== 校园经历

#entry(
  title: "北京理工大学（985）",
  subtitle: "计算机科学与技术",
  date: "2021.09 - 2025.07",
  title-center: true
)[
  - *学业成绩*: 绩点3.85 (8/45) / CET6: 578 / 全国大学生数学竞赛省二等奖 / 北京市计算机应用技术大赛省一等奖
  - *数学建模*: 美国大学生数学建模竞赛M奖，全国大学生数学建模省一等奖
]

== 实习经历

#entry(
  title: "字节跳动（抖音）",
  subtitle: "AI产品开发实习生",
  date: "2024年7月 - 至今",
)[
  作为核心成员参与抖音推荐算法优化项目，推动项目从概念验证到线上部署：
  - *问题分析与方案设计*: 在项目初期通过数据分析发现用户停留时长下降的痛点，为此提出基于#highlight("多模态内容理解")的个性化推荐策略，将#highlight("用户行为预测准确率提升15%")。
  - *技术实现与创新*: 为验证方案可行性，主导开发了#highlight("A/B测试平台")并落地两大创新：一是设计了支持实时反馈的#highlight("动态权重调整机制")以提升推荐精度。二是构建了#highlight("内容质量评估")与#highlight("用户兴趣建模")相结合的双层过滤体系。
  - *成果与影响*: 该项目在向#highlight("技术总监")的汇报中获得高度认可，并成功完成了#highlight("研发-测试-灰度-全量")的完整上线流程。目前该算法已在抖音主App稳定运行，日活跃用户覆盖超过#highlight("1000万")。
]

#entry(
  title: "腾讯",
  subtitle: "产品策划实习生",
  date: "2024年3月 - 2024年6月",
)[
  - *微信小程序AI助手*: 主导微信生态AI助手小程序的产品设计与原型开发。为提高用户交互体验和功能实用性，设计#highlight("多轮对话管理")、智能任务分解等核心模块，使用#highlight("React")完成前端原型开发并撰写了完整PRD文档。目前该项目已进入开发阶段。
  - *社交媒体数据分析工具*: 基于#highlight("Python数据分析")技术栈开发社交媒体趋势分析工具，集成多个API实现热点话题挖掘、用户画像分析等功能。开发的分析报告生成器累计服务#highlight("500+")内部用户。
]

== 个人项目

#entry(
  title: "SmartDataFlow",
  subtitle: "独立开发",
  date: "2024年2月",
)[
  基于大模型的智能数据处理平台，AI将调用相应工具帮助用户完成数据分析和可视化任务。
  
  - *多Agent协同架构*: 构建了数据分析Agent、可视化Agent及代码生成Agent的#highlight("分布式Agent系统")。各Agent间通过消息队列通信，共享执行上下文但保持独立的专业领域知识。主控Agent基于#highlight("Chain-of-Thought")设计，能解析用户需求、分配任务、监控执行状态并整合结果。
  - *智能上下文管理*: 引入#highlight("层次化知识图谱")机制。DataFlow.yaml作为全局配置，定义数据源和处理规则。同时，为每个数据集配置#highlight("语义化元数据")，提升AI对数据结构和业务含义的#highlight("理解精度")。
  - *交互式执行环境*: 集成#highlight("Jupyter")内核实现代码实时执行和结果展示。为防止上下文溢出，对长输出内容采用#highlight("分段存储")和#highlight("智能摘要")技术，确保关键信息不丢失。
]

== 专业技能

- 掌握#highlight("Python")/#highlight("JavaScript")技术栈，擅长#highlight("推荐系统")和前端开发；熟悉#highlight("React")、#highlight("Redis")/#highlight("MySQL")、#highlight("Docker")等开发框架和工具。
- 熟悉#highlight("TensorFlow")/#highlight("PyTorch")框架，有推荐算法和多模态模型实战经验。
- 掌握#highlight("知识图谱")与#highlight("向量检索")等技术，能使用#highlight("Jupyter")搭建#highlight("数据分析流水线")。
- 擅长#highlight("Agent架构设计")与#highlight("Chain-of-Thought")，熟悉#highlight("LangChain")、#highlight("OpenAI API")等大模型应用框架。
- 具备扎实#highlight("算法")/#highlight("数据结构")基础，熟悉#highlight("分布式系统设计")，有A/B测试平台开发经验。
