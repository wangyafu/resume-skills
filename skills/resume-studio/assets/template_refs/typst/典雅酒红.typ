#let accent-color = rgb("c04848")
#let accent-bg-light = rgb("fdf6f6")
#let text-dark = rgb("333333")
#let text-light = rgb("666666")
#let border-color = rgb("eeeeee")

#let resume(
  name: "",
  title: "",
  phone: "",
  email: "",
  motto: "",
  photo: none,
  body
) = {
  set document(title: name + " - 简历", author: name)
  set text(font: ("Linux Libertine", "PingFang SC", "Microsoft YaHei", "sans-serif"), size: 10.5pt, fill: text-dark, lang: "zh")
  set page(
    paper: "a4",
    margin: (x: 2cm, y: 2cm),
  )
  set par(justify: true, leading: 0.6em)

  // Header
  box(width: 100%, stroke: (bottom: 1pt + border-color), padding: (bottom: 12pt))[
    #grid(
      columns: (1fr, auto),
      [
        #text(size: 24pt, weight: "semibold", fill: text-dark)[#name]
        #v(6pt)
        #text(size: 10pt, fill: text-light)[#phone | #email]
        #v(4pt)
        #text(size: 10pt, fill: text-light)[#title]
        #v(4pt)
        #text(size: 10pt, fill: text-light)[#motto]
      ],
      if photo != none [
        // Using circle for photo with border
        #box(width: 80pt, height: 80pt, radius: 50%, clip: true, stroke: 3pt + white)[
          #image(photo, width: 100%, height: 100%, fit: "cover")
        ]
      ] else []
    )
  ]

  show heading.where(level: 2): it => {
    v(10pt)
    box(
      width: 100%,
      fill: accent-bg-light,
      inset: (x: 8pt, y: 6pt),
      radius: 2pt
    )[
      #grid(
        columns: (4pt, 1fr),
        column-gutter: 8pt,
        align: (center, horizon),
        box(width: 4pt, height: 12pt, fill: accent-color, radius: 1pt),
        text(size: 12pt, weight: "bold", fill: accent-color)[#it.body]
      )
    ]
    v(6pt)
  }

  set list(indent: 10pt, marker: [•])

  body
}

// 简历条目组件
#let entry(
  title: "",
  subtitle: "",
  date: "",
  location: "",
  content
) = {
  v(8pt)
  grid(
    columns: (1fr, auto),
    text(size: 11pt, weight: "bold")[#title],
    text(size: 10pt, fill: text-light, align: right)[#date \ #location]
  )
  if subtitle != "" [
    #v(4pt)
    #text(weight: "bold", fill: text-dark)[#subtitle]
  ]
  v(4pt)
  content
}

// ==========================================
// 以下为内容区域示例
// ==========================================

#show: resume.with(
  name: "李明轩",
  title: "AI应用开发工程师",
  phone: "13812345678",
  email: "limingxuan@example.com",
  motto: "希望打造有趣又有用的AI产品",
  // TODO: 如果有本地图片可以替换此处的none为路径，如 "photo.png"
  photo: none 
)

== 教育背景

#entry(
  title: "北京理工大学（985）",
  subtitle: "计算机科学与技术（本科）",
  date: "2021.09 - 2025.07",
  location: "北京"
)[
  - 绩点3.85（8/45）/ CET-6：578
  - 美国大学生数学建模竞赛M奖
  - 全国大学生数学竞赛省二等奖
  - 北京市计算机应用技术大赛省一等奖
]

== 实习经历

#entry(
  title: "字节跳动（抖音）",
  subtitle: "AI产品开发实习生",
  date: "2024年7月 - 至今",
  location: "北京"
)[
  - 作为核心成员参与抖音推荐算法优化项目，推动项目从概念验证到线上部署：
  - *问题分析与方案设计*：在项目初期通过数据分析发现用户停留时长下降的痛点，提出基于“多模态内容理解”的个性化推荐策略，将用户行为预测准确率提升15%。
  - *技术实现与创新*：主导开发A/B测试平台，设计支持实时反馈的动态权重调整机制，构建“内容质量评估”与“用户兴趣建模”相结合的双层过滤体系。
  - *成果与影响*：项目在技术总监汇报中获得高度认可，成功完成“研发-测试-灰度-全量”上线流程，算法稳定服务日活用户1000万以上。
]

#entry(
  title: "腾讯",
  subtitle: "产品策划实习生",
  date: "2024年3月 - 2024年6月",
  location: "北京"
)[
  - *微信小程序AI助手*：主导微信生态AI助手小程序的产品设计与原型开发，设计多轮对话管理、智能任务分解等核心模块，使用React完成前端原型开发并撰写完整PRD文档，项目已进入开发阶段。
  - *社交媒体数据分析工具*：基于Python数据分析技术栈开发社交媒体趋势分析工具，集成多个API实现热点话题挖掘、用户画像分析等功能，开发的分析报告生成器累计服务500+内部用户。
]

== 个人项目

#entry(
  title: "SmartDataFlow",
  subtitle: "独立开发",
  date: "2024年2月",
  location: "北京"
)[
  - 基于大模型的智能数据处理平台，AI将调用相应工具帮助用户完成数据分析和可视化任务。
  - *多Agent协同架构*：构建了数据分析Agent、可视化Agent及代码生成Agent的分布式Agent系统，各Agent间通过消息队列通信，共享执行上下文但保持独立的专业领域知识。主控Agent基于Chain-of-Thought设计，能解析用户需求、分配任务、监控执行状态并整合结果。
  - *智能上下文管理*：引入层次化知识图谱机制，DataFlow.yaml作为全局配置，定义数据源和处理规则。为每个数据集配置语义化元数据，提升AI对数据结构和业务含义的理解精度。
  - *交互式执行环境*：集成Jupyter内核实现代码实时执行和结果展示。为防止上下文溢出，对长输出内容采用分段存储和智能摘要技术，确保关键信息不丢失。
]

== 专业技能

#v(8pt)
*技能:* #text(fill: text-light)[Python, JavaScript, 推荐系统, 前端开发, React, Redis, MySQL, Docker, TensorFlow, PyTorch, 知识图谱, 向量检索, Jupyter, Agent架构, Chain-of-Thought, LangChain, OpenAI API, 算法, 数据结构, 分布式系统, A/B测试平台]

#v(4pt)
*语言:* #text(fill: text-light)[CET-4, CET-6]
