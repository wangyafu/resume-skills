#let theme = rgb("254665")
#let bg = rgb("ffffff")
#let text-color = rgb("1f2937")
#let muted = rgb("6b7280")

#let resume(
  name: "",
  photo: none,
  info: (),
  skills: (),
  body
) = {
  set document(title: name + " - 简历", author: name)
  set text(font: ("Noto Sans SC", "PingFang SC", "Microsoft YaHei", "sans-serif"), size: 10.5pt, fill: text-color, lang: "zh")
  set page(
    paper: "a4",
    margin: 0pt, // Full page for the grid
  )
  set par(justify: true, leading: 0.6em)
  
  grid(
    columns: (1fr, 2.6fr),
    box(
      width: 100%, height: 100%, fill: theme, inset: 20pt
    )[
      #set text(fill: white)
      #if photo != none [
        #align(center)[
          #box(radius: 8pt, clip: true)[
            #image(photo, width: 100pt, height: 125pt, fit: "cover")
          ]
        ]
        #v(16pt)
      ]
      
      #set list(indent: 0pt, marker: "")
      #for item in info [
        #item
        #v(6pt)
      ]
      
      #v(20pt)
      #text(size: 14pt, weight: "bold")[专业技能]
      #v(12pt)
      #set list(indent: 14pt, marker: [•])
      #skills
    ],
    box(
      width: 100%, height: 100%, fill: bg, inset: (x: 24pt, top: 32pt, bottom: 32pt)
    )[
      #text(size: 20pt, weight: "bold", spacing: 0.5pt)[#name]
      #v(16pt)
      
      #show heading.where(level: 2): it => {
        v(12pt)
        text(size: 14pt, weight: "bold")[#it.body]
        v(8pt)
      }
      
      #set list(indent: 12pt, marker: [•])
      #body
    ]
  )
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
        #h(8pt)
        #text(size: 10.5pt)[#subtitle]
      ]
    ],
    align(right)[#text(size: 9.5pt, fill: muted)[#date]]
  )
  v(6pt)
  content
}

#let strongtext(content) = {
  // text(fill: theme, weight: "bold")[#content]
  text(weight: "bold")[#content]
}

// ==========================================
// 示例内容
// ==========================================

#show: resume.with(
  name: "李明轩",
  photo: none,
  info: (
    [男 / 22 / 25届毕业生],
    [13812345678],
    [limingxuan@example.com],
    [Github个人主页],
    [个人网站],
    [希望打造有趣又有用的AI产品]
  ),
  skills: [
    - 掌握#strongtext[Python]/#strongtext[JavaScript]技术栈，擅长#strongtext[推荐系统]和前端开发；熟悉#strongtext[React]、#strongtext[Redis]/#strongtext[MySQL]、#strongtext[Docker]等开发框架和工具。
    - 熟悉#strongtext[TensorFlow]/#strongtext[PyTorch]框架，有推荐算法和多模态模型实战经验。
    - 掌握#strongtext[知识图谱]与#strongtext[向量检索]等技术，能使用#strongtext[Jupyter]搭建#strongtext[数据分析流水线]。
    - 擅长#strongtext[Agent架构设计]与#strongtext[Chain-of-Thought]，熟悉#strongtext[LangChain]、#strongtext[OpenAI API]等大模型应用框架。
    - 具备扎实#strongtext[算法]/#strongtext[数据结构]基础，熟悉#strongtext[分布式系统设计]。
  ]
)

== 校园经历

#entry(
  title: "北京理工大学（985）",
  subtitle: "计算机科学与技术",
  date: "2021.09 - 2025.07",
)[
  - *学业成绩*: 绩点3.85 (8/45) / CET6: 578 / 全国大学生数学竞赛省二等奖 / 北京市计算机应用技术大赛省一等奖
  - *数学建模*: 美国大学生数学建模竞赛M奖，全国大学生数学建模省一等奖(负责算法设计和代码实现)
]

== 实习经历

#entry(
  title: "字节跳动（抖音）",
  subtitle: "AI产品开发实习生",
  date: "2024年7月 - 至今",
)[
  作为核心成员参与抖音推荐算法优化项目，推动项目从概念验证到线上部署：
  - *问题分析与方案设计*: 在项目初期通过数据分析发现用户停留时长下降的痛点，为此提出基于#strongtext("多模态内容理解")的个性化推荐策略。
  - *技术实现与创新*: 为验证方案可行性，主导开发了#strongtext("A/B测试平台")并落地两大创新。
  - *成果与影响*: 该项目在向#strongtext("技术总监")的汇报中获得高度认可，并成功完成了#strongtext("研发-测试-灰度-全量")的完整上线流程。
]

#entry(
  title: "腾讯",
  subtitle: "产品策划实习生",
  date: "2024年3月 - 2024年6月",
)[
  - *微信小程序AI助手*: 主导微信生态AI助手小程序的产品设计与原型开发。为提高用户交互体验和功能实用性，设计#strongtext("多轮对话管理")等核心模块。
  - *社交媒体数据分析工具*: 基于#strongtext("Python数据分析")技术栈开发社交媒体趋势分析工具，集成多个API实现热点话题挖掘等。
]

== 个人项目

#entry(
  title: "SmartDataFlow",
  subtitle: "独立开发",
  date: "2024年2月",
)[
  基于大模型的智能数据处理平台，AI将调用相应工具帮助用户完成数据分析和可视化任务。
  - *多Agent协同架构*: 构建了数据分析Agent、可视化Agent及代码生成Agent的#strongtext("分布式Agent系统")。
  - *智能上下文管理*: 引入#strongtext("层次化知识图谱")机制。DataFlow.yaml作为全局配置，定义数据源和处理规则。
  - *交互式执行环境*: 集成#strongtext("Jupyter")内核实现代码实时执行和结果展示。
]
