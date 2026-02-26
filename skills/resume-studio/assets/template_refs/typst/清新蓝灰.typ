#let primary-color = rgb("6c85a1")
#let text-color-dark = rgb("333333")
#let text-color-light = rgb("555555")
#let bg-color = rgb("f5f5f5")
#let border-color = rgb("e0e0e0")

#let resume(
  name: "",
  title: "",
  motto: "",
  photo: none,
  basic-info: (),
  body
) = {
  set document(title: name + " - 简历", author: name)
  set text(font: ("Noto Sans SC", "PingFang SC", "Microsoft YaHei", "sans-serif"), size: 10.5pt, fill: text-color-dark, lang: "zh")
  set page(
    paper: "a4",
    margin: (x: 2cm, y: 2.5cm),
    fill: bg-color
  )
  set par(justify: true, leading: 0.6em)

  // Header
  box(
    fill: primary-color,
    radius: (right: 35pt),
    inset: (x: 24pt, y: 16pt)
  )[
    #grid(
      columns: (auto, auto, auto),
      align: (center, horizon),
      column-gutter: 16pt,
      text(size: 24pt, weight: "medium", fill: white, tracking: 2pt)[#name],
      line(length: 24pt, angle: 90deg, stroke: 1pt + color.mix((white, 50%), (primary-color, 50%))),
      [
        #text(size: 10pt, fill: white)[#title]
        #v(4pt)
        #text(size: 9.5pt, fill: white)[#motto]
      ]
    )
  ]
  v(16pt)

  show heading.where(level: 2): it => {
    v(12pt)
    grid(
      columns: (auto, 1fr),
      align: (center, horizon),
      column-gutter: 10pt,
      box(
        fill: primary-color,
        radius: 15pt,
        inset: (x: 14pt, y: 5pt),
        text(size: 11pt, weight: "medium", fill: white)[#it.body]
      ),
      line(length: 100%, stroke: 1pt + border-color)
    )
    v(8pt)
  }

  set list(indent: 12pt, marker: text(fill: primary-color, weight: "bold")[•])

  body
}

#let basic-info-section(info: (), photo: none) = {
  v(12pt)
  grid(
    columns: (auto, 1fr),
    align: (center, horizon),
    column-gutter: 10pt,
    text(size: 11pt, weight: "medium", fill: primary-color)[基本信息],
    line(length: 100%, stroke: 1pt + border-color)
  )
  v(8pt)
  
  box(width: 100%)[
    #grid(
      columns: if photo != none { (1fr, 80pt) } else { (1fr) },
      column-gutter: 20pt,
      [
        #grid(
          columns: (1fr, 1fr),
          row-gutter: 8pt,
          ..info.map(i => text(fill: text-color-light)[#i])
        )
      ],
      if photo != none [
         #box(
           clip: true,
           image(photo, width: 80pt, height: 100pt, fit: "cover")
         )
      ] else []
    )
  ]
}

#let entry(
  title: "",
  subtitle: "",
  date: "",
  highlight: "",
  content
) = {
  v(8pt)
  grid(
    columns: (auto, 1fr),
    column-gutter: 12pt,
    align: (left, horizon),
    text(size: 10.5pt, weight: "bold")[#date],
    text(size: 10.5pt, weight: "bold")[#title]
  )
  v(6pt)
  text(size: 11.5pt, weight: "bold")[#subtitle]
  if highlight != "" [
    #v(4pt)
    #text(fill: primary-color, weight: "bold")[#highlight]
  ]
  v(6pt)
  set text(fill: text-color-light)
  content
}

// ==========================================
// 示例内容
// ==========================================

#show: resume.with(
  name: "李明轩",
  title: "AI应用开发工程师",
  motto: "希望打造有趣又有用的AI产品",
  photo: none
)

#basic-info-section(
  photo: none,
  info: (
    [*姓       名：*李明轩],
    [*年       龄：*22岁],
    [*在读状态：*25届毕业生],
    [*求职岗位：*AI应用开发工程师],
    [*意向城市：*北京],
    [*期望薪资：*面议],
    [*入职时间：*毕业后到岗],
    [*联系电话：*13812345678],
    [*邮       箱：*limingxuan@example.com],
    [*最高学历：*北京理工大学（本科）]
  )
)

== 教育背景

#entry(
  title: "计算机科学与技术（本科）",
  subtitle: "北京理工大学（985）",
  date: "2021.09 ~ 2025.07",
  highlight: "绩点3.85（8/45），CET-6 578；竞赛表现优秀。"
)[
  - 学业成绩：绩点3.85（8/45）/ CET-6：578
  - 美国大学生数学建模竞赛M奖
  - 全国大学生数学竞赛省二等奖
  - 北京市计算机应用技术大赛省一等奖
]

== 实习经历

#entry(
  title: "AI产品开发实习生",
  subtitle: "字节跳动（抖音）",
  date: "2024-07 ~ 至今",
  highlight: ""
)[
  - 作为核心成员参与抖音推荐算法优化项目：
  - *问题分析与方案设计*：发现用户停留时长下降痛点，提出“多模态内容理解”个性化推荐策略，行为预测准确率提升15%。
  - *技术实现与创新*：主导开发A/B测试平台，构建“内容质量评估”与“用户兴趣建模”相结合的双层过滤体系。
  - *成果与影响*：项目在技术总监汇报中获高度认可，成功完成全量上线，算法服务日活用户1000万以上。
]

#entry(
  title: "产品策划实习生",
  subtitle: "腾讯",
  date: "2024-03 ~ 2024-06",
  highlight: ""
)[
  - *微信小程序AI助手*：主导微信生态AI助手小程序的产品设计与原型开发，设计多轮对话管理、智能任务分解等核心模块，使用React完成前端原型开发。
  - *社交媒体数据分析工具*：基于Python开发趋势分析工具，累计服务500+内部用户。
]

== 技能特长

- 掌握Python/JavaScript技术栈，擅长推荐系统与前端开发；熟悉React、Redis/MySQL、Docker等。
- 熟悉TensorFlow/PyTorch框架，具备推荐算法与多模态模型实践经验。
- 掌握知识图谱与向量检索技术，能使用Jupyter搭建数据分析流水线。
- 擅长Agent架构设计与Chain-of-Thought，熟悉LangChain、OpenAI API等框架。
- 具备扎实算法与数据结构基础，熟悉分布式系统设计，具备A/B测试平台开发经验。
