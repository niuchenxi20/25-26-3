import sys
import os

OUT = r'C:\Users\Ncx63\Desktop\16\Summary - 16_Superscalar'

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_LEFT, TA_CENTER
from reportlab.lib.colors import HexColor, black, white
from reportlab.lib.units import mm, cm
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer,
                                 PageBreak, Table, TableStyle, KeepTogether)
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase.cidfonts import UnicodeCIDFont

# Register Chinese font
pdfmetrics.registerFont(TTFont('SimSun', r'C:\Windows\Fonts\simsun.ttc'))
pdfmetrics.registerFont(TTFont('SimHei', r'C:\Windows\Fonts\simhei.ttf'))
pdfmetrics.registerFont(TTFont('STSong', r'C:\Windows\Fonts\STSONG.TTF'))

pdfmetrics.registerFont(UnicodeCIDFont('STSong-Light'))

# Register font families
from reportlab.pdfbase import pdfmetrics
pdfmetrics.registerFont(TTFont('SimSun', r'C:\Windows\Fonts\simsun.ttc', subfontIndex=0))
pdfmetrics.registerFont(TTFont('SimHei', r'C:\Windows\Fonts\simhei.ttf'))

# Styles
styles = getSampleStyleSheet()

title_style = ParagraphStyle('ChTitle', parent=styles['Title'],
    fontName='SimHei', fontSize=20, leading=28,
    spaceAfter=6*mm, alignment=TA_CENTER,
    textColor=HexColor('#1a1a2e'))

h1_style = ParagraphStyle('H1', parent=styles['Heading1'],
    fontName='SimHei', fontSize=14, leading=20,
    spaceBefore=5*mm, spaceAfter=3*mm,
    textColor=HexColor('#16213e'),
    borderPadding=(0,0,2,0))

h2_style = ParagraphStyle('H2', parent=styles['Heading2'],
    fontName='SimHei', fontSize=12, leading=17,
    spaceBefore=4*mm, spaceAfter=2*mm,
    textColor=HexColor('#0f3460'))

body_style = ParagraphStyle('ChBody', parent=styles['Normal'],
    fontName='SimSun', fontSize=10, leading=16,
    spaceBefore=1*mm, spaceAfter=1.5*mm,
    leftIndent=2*mm)

bullet_style = ParagraphStyle('ChBullet', parent=body_style,
    bulletIndent=4*mm, leftIndent=10*mm)

formula_style = ParagraphStyle('Formula', parent=body_style,
    fontName='SimSun', fontSize=10, leading=16,
    leftIndent=8*mm, textColor=HexColor('#c0392b'),
    backColor=HexColor('#fdf2e9'))

table_style_def = TableStyle([
    ('BACKGROUND', (0,0), (-1,0), HexColor('#16213e')),
    ('TEXTCOLOR', (0,0), (-1,0), white),
    ('FONTNAME', (0,0), (-1,0), 'SimHei'),
    ('FONTSIZE', (0,0), (-1,0), 10),
    ('FONTNAME', (0,1), (-1,-1), 'SimSun'),
    ('FONTSIZE', (0,1), (-1,-1), 9),
    ('ALIGN', (0,0), (-1,-1), 'LEFT'),
    ('VALIGN', (0,0), (-1,-1), 'TOP'),
    ('GRID', (0,0), (-1,-1), 0.5, HexColor('#bdc3c7')),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [white, HexColor('#f8f9fa')]),
    ('TOPPADDING', (0,0), (-1,-1), 4),
    ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ('LEFTPADDING', (0,0), (-1,-1), 6),
    ('RIGHTPADDING', (0,0), (-1,-1), 6),
])

def make_heading(text, style=h1_style):
    return Paragraph(text, style)

def make_body(text):
    return Paragraph(text, body_style)

def make_bullet(text):
    return Paragraph(f"• {text}", bullet_style)

def make_table(headers, rows, col_widths=None):
    data = [headers] + rows
    t = Table(data, colWidths=col_widths, repeatRows=1)
    t.setStyle(table_style_def)
    return t

# Helper for bilingual terms
def b(key, en=""):
    if en:
        return f"{key}（{en}）"
    return key

# Build story
story = []

# ===== TITLE PAGE =====
story.append(Spacer(1, 25*mm))
story.append(Paragraph("计算机组成与体系结构", title_style))
story.append(Paragraph("第16章  指令级并行与超标量处理器", ParagraphStyle('Sub', parent=title_style,
    fontName='SimHei', fontSize=16, leading=24, alignment=TA_CENTER)))
story.append(Spacer(1, 8*mm))
story.append(Paragraph("Chapter 16  Instruction Level Parallelism<br/>and Superscalar Processors",
    ParagraphStyle('EnSub', parent=body_style, fontSize=12, leading=18, alignment=TA_CENTER,
    fontName='SimSun', textColor=HexColor('#7f8c8d'))))
story.append(Spacer(1, 12*mm))
story.append(Paragraph("William Stallings, 10th Edition", ParagraphStyle('Author', parent=body_style,
    fontSize=10, alignment=TA_CENTER, textColor=HexColor('#95a5a6'))))
story.append(Spacer(1, 6*mm))

# Meta info table
meta_data = [
    ["用途", "考前复习资料 / Exam Review Cheat Sheet"],
    ["范围", "16.1 Overview ~ 16.2 Design Issues（至Branch Prediction之前）"],
    ["语言", "中文为主，关键术语附英文"],
    ["页码引用", "每条要点标注来源幻灯片页码"],
    ["生成日期", "2026-06-03"],
]
meta_table = Table(meta_data, colWidths=[35*mm, 120*mm])
meta_table.setStyle(TableStyle([
    ('FONTNAME', (0,0), (0,-1), 'SimHei'),
    ('FONTNAME', (1,0), (1,-1), 'SimSun'),
    ('FONTSIZE', (0,0), (-1,-1), 9),
    ('LEADING', (0,0), (-1,-1), 14),
    ('TOPPADDING', (0,0), (-1,-1), 3),
    ('BOTTOMPADDING', (0,0), (-1,-1), 3),
    ('LEFTPADDING', (0,0), (-1,-1), 8),
    ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ('GRID', (0,0), (-1,-1), 0.5, HexColor('#ddd')),
    ('BACKGROUND', (0,0), (0,-1), HexColor('#ecf0f1')),
]))
story.append(meta_table)

story.append(PageBreak())

# ===== SECTION 1: OVERVIEW =====
story.append(make_heading("一、超标量概述 / Superscalar Overview（p.1–10）"))

story.append(make_heading("1.1 什么是超标量？", h2_style))
story.append(make_bullet(b("定义", "Superscalar")))
story.append(make_body(
    "超标量（Superscalar）一词于1987年首次提出，指一种通过执行标量指令来提升性能的机器设计方法。"
    "其核心是<B>让多条指令在不同流水线中独立、并发地执行</B>，且允许指令以不同于程序顺序的次序执行。（p.6）"))
story.append(make_bullet(b("关键能力", "Key Capabilities")))
story.append(make_bullet("常见指令（算术、加载/存储、条件分支）可被<b>同时发起</b>并<b>独立执行</b>（p.5）"))
story.append(make_bullet("对 RISC 和 CISC 同样适用（p.5）"))
story.append(make_bullet("已成为高性能微处理器的标准方法（p.5）"))

story.append(make_heading("1.2 超标量 vs 超级流水线（Superscalar vs Superpipeline）（p.7–10）", h2_style))
story.append(make_bullet(b("超级流水线", "Superpipeline")))
story.append(make_bullet("许多流水级用时少于半个时钟周期；双倍内部时钟速度，每个外部时钟周期完成两个任务（p.9）"))
story.append(make_bullet(b("超标量", "Superscalar")))
story.append(make_bullet("允许并行取指和执行。在程序开始和每个分支目标处，超级流水线处理器落后于超标量处理器（p.10）"))

story.append(make_bullet(b("标量", "Scalar")))
story.append(make_bullet("单一流水线功能单元，允许多条指令同时处于不同流水级（p.7）"))
story.append(make_bullet(b("超标量", "Superscalar")))
story.append(make_bullet("多个功能单元，每个功能单元本身也是流水线实现的，每个单元提供一定的并行度（p.8）"))

story.append(PageBreak())

# ===== SECTION 2: ILP & LIMITATIONS =====
story.append(make_heading("二、指令级并行及其限制 / ILP and Its Limitations（p.11–17）"))

story.append(make_heading("2.1 指令级并行（ILP）", h2_style))
story.append(make_bullet(b("指令级并行", "Instruction Level Parallelism — ILP")))
story.append(make_bullet("程序中的指令在平均意义上能够被并行执行的程度（p.11）"))
story.append(make_bullet("由代码中<b>真数据依赖</b>和<b>过程依赖</b>的频率决定（p.19）"))
story.append(make_bullet("还受<b>操作延迟</b>（Operation Latency）支配：指令结果可用作后续指令操作数所需的时间（p.19）"))

story.append(make_heading("2.2 提高 ILP 的方法", h2_style))
story.append(make_bullet(b("编译器优化", "Compiler-based Optimization")))
story.append(make_bullet(b("硬件技术", "Hardware Techniques")))

story.append(make_heading("2.3 五大限制因素（p.11, p.45）", h2_style))

lim_headers = ["限制类型", "英文名称", "别名", "说明", "页码"]
lim_rows = [
    ["真数据依赖", "True Data Dependency", "RAW（Read-After-Write）/ 流依赖", "后一条指令使用前一条指令产生的结果，无法并行执行", "p.11-13"],
    ["过程依赖", "Procedural Dependency", "分支依赖", "条件分支后的指令不能与分支前的指令并行执行；CISC中可变指令长度阻止同时取指", "p.14"],
    ["资源冲突", "Resource Conflict", "结构冲突", "两条以上指令同时需要同一资源（如ALU），可通过复制资源解决", "p.15"],
    ["输出依赖", "Output Dependency", "WAW（Write-After-Write）", "后一条指令先于前一条指令写回结果，导致寄存器值错误", "p.17, 34"],
    ["反依赖", "Antidependency", "WAR（Write-After-Read）", "后一条指令先于前一条指令读取之前写回，破坏了源操作数值", "p.17, 34"],
]
story.append(make_table(lim_headers, lim_rows, [28*mm, 34*mm, 32*mm, 50*mm, 14*mm]))

story.append(Spacer(1, 3*mm))

story.append(make_heading("2.4 依赖详解", h2_style))
story.append(make_bullet(b("真数据依赖 / RAW", "True Data Dependency / Flow Dependency")))
story.append(make_body(
    "ADD EAX, ECX ; MOV EBX, EAX —— 第二条指令<b>可以</b>与第一条并行取指和译码，但<b>不能</b>在第一条完成之前执行。（p.12）"))
story.append(make_bullet("涉及内存访问时延迟更长（LOAD/STORE可能需2个以上时钟周期）（p.13）"))
story.append(make_bullet("对RISC：重排序指令可加速流水线；对超标量：重排序的效果不如RISC流水线显著（p.13）"))

story.append(make_bullet(b("过程依赖", "Procedural Dependency")))
story.append(make_bullet("条件分支后的指令不能与分支前的指令并行执行（p.14）"))
story.append(make_bullet("CISC中指令长度不固定，需先译码确定取指次数——阻止同时取指，这是超标量更适用于RISC的原因之一（p.14）"))

story.append(make_bullet(b("输出依赖与反依赖", "Output & Anti Dependency")))
story.append(make_bullet("两者不同于真数据依赖和资源冲突，都属于<b>存储冲突</b>（Storage Conflicts）的实例（p.34）"))
story.append(make_bullet("本质原因：寄存器内容可能无法反映程序正确的执行顺序（p.35）"))

story.append(PageBreak())

# ===== SECTION 3: DESIGN ISSUES =====
story.append(make_heading("三、设计问题 / Design Issues（p.18–41）"))

story.append(make_heading("3.1 指令级并行 vs 机器并行", h2_style))
story.append(make_bullet(b("机器并行", "Machine Parallelism")))
story.append(make_bullet("CPU 利用指令级并行的<b>能力</b>（p.21）"))
story.append(make_bullet("受限于：(1) 寻找独立指令的机制的速度和复杂度；(2) 可并行取指和执行的流水线数量（p.21）"))

story.append(Spacer(1, 2*mm))

story.append(make_heading("3.2 指令发射策略（Instruction Issue Policy）（p.22–33）", h2_style))
story.append(make_bullet(b("指令发射", "Instruction Issue")))
story.append(make_bullet("在处理器功能单元中<b>发起指令执行</b>的过程（p.22）"))
story.append(make_bullet(b("指令发射策略", "Instruction Issue Policy")))
story.append(make_bullet("用于发射指令的<b>协议</b>。CPU必须「向前看」（look ahead）以寻找可并行执行的指令（p.22）"))

story.append(Spacer(1, 2*mm))
story.append(make_bullet(b("三种重要顺序", "Three Important Orders")))
story.append(make_bullet("(1) 取指顺序（Fetch Order）"))
story.append(make_bullet("(2) 执行顺序（Execution Order）"))
story.append(make_bullet("(3) 写回（更改寄存器和内存）顺序（Write Order）（p.22）"))

story.append(Spacer(1, 3*mm))

# Three policies comparison
pol_headers = ["策略", "取指/译码", "执行", "写回", "效率", "停顿原因", "页码"]
pol_rows = [
    ["按序发射\n按序完成\n(In-Order Issue\nIn-Order Completion)",
     "按序", "按序", "按序",
     "效率不高",
     "资源冲突、真数据依赖、过程依赖、功能单元需要多周期",
     "p.23–27"],
    ["按序发射\n乱序完成\n(In-Order Issue\nOut-of-Order Completion)",
     "按序", "乱序", "乱序",
     "中等",
     "资源冲突、真数据依赖、过程依赖\n（执行阶段空闲即可执行）",
     "p.28–29"],
    ["乱序发射\n乱序完成\n(Out-of-Order Issue\nOut-of-Order Completion)",
     "乱序", "乱序", "乱序",
     "最高",
     "使用指令窗口解耦译码和执行，\n降低流水级停顿概率",
     "p.30–33"],
]
story.append(make_table(pol_headers, pol_rows, [30*mm, 18*mm, 14*mm, 14*mm, 18*mm, 52*mm, 14*mm]))

story.append(Spacer(1, 4*mm))

story.append(make_heading("3.3 指令窗口（Instruction Window）（p.31–33）", h2_style))
story.append(make_bullet(b("指令窗口", "Instruction Window")))
story.append(make_bullet("解耦译码流水线和执行流水线的关键机制（p.31）"))
story.append(make_bullet("允许持续取指和译码直到缓冲区满（p.32）"))
story.append(make_bullet("当功能单元可用时，窗口中无冲突/无依赖的指令即可执行（p.32）"))
story.append(make_bullet("<B>不是一个额外的流水段</B>（p.32）"))
story.append(make_bullet("使处理器能<b>向前看</b>（look ahead），从窗口中识别独立指令（p.32）"))
story.append(make_bullet("乱序发射减少了流水级停顿的概率（p.33）"))

story.append(PageBreak())

# ===== SECTION 4: REGISTER RENAMING =====
story.append(make_heading("四、寄存器重命名 / Register Renaming（p.34–37）"))

story.append(make_heading("4.1 为什么需要寄存器重命名？", h2_style))
story.append(make_bullet("输出依赖和反依赖本质上是<b>存储冲突</b>（Storage Conflicts），原因是寄存器内容可能无法反映正确的程序顺序（p.35）"))
story.append(make_bullet("可能导致流水线停顿（p.35）"))
story.append(make_bullet("编译器对寄存器的优化（第15章中讨论）可能使冲突更加尖锐（p.35）"))

story.append(make_heading("4.2 寄存器重命名机制", h2_style))
story.append(make_bullet(b("寄存器重命名", "Register Renaming")))
story.append(make_bullet("本质是<b>资源的复制</b>（Duplication of Resources）（p.35）"))
story.append(make_bullet("由处理器硬件<b>动态分配</b>寄存器（p.35）"))
story.append(make_bullet("使用下标区分逻辑寄存器（无下标）和硬件分配的物理寄存器（有下标），减少不必要的输出/反依赖（p.36）"))

story.append(Spacer(1, 3*mm))

story.append(make_bullet("重命名示例（p.36–37）："))
story.append(make_body(
    "I1: R3b ← R3a op R5a  （真数据依赖：I1→I2）<br/>"
    "I2: R4b ← R3b + 1      （真数据依赖：I2→I4）<br/>"
    "I3: R3c ← R5a + 1      （真数据依赖：I3→I4）<br/>"
    "I4: R7b ← R3c op R4b<br/>"
    "重命名后消除了 I1-I3（WAW）和 I2-I3（WAR）的伪依赖。"))

story.append(Spacer(1, 3*mm))

story.append(make_heading("4.3 机器并行性评估（p.38–39）", h2_style))
story.append(make_bullet("三种提升性能的硬件技术（p.38）："))
story.append(make_bullet("(1) <b>复制资源</b>（Duplication of Resources）：加载/存储/ALU等功能单元"))
story.append(make_bullet("(2) <b>乱序发射</b>（Out-of-Order Issue）：指令窗口"))
story.append(make_bullet("(3) <b>寄存器重命名</b>（Register Renaming）：重复寄存器"))

story.append(Spacer(1, 2*mm))
story.append(make_bullet("仿真结论（Simulation Conclusions）（p.38–39）："))
story.append(make_bullet("<B>没有寄存器重命名的情况下，增加功能单元是不值得的</B>（Not worthwhile to add function units without register renaming）"))
story.append(make_bullet("<B>需要足够大的指令窗口</B>（more than 8）（Need instruction window large enough）"))

story.append(PageBreak())

# ===== SECTION 5: BRANCH PREDICTION =====
story.append(make_heading("五、分支预测 / Branch Prediction（p.40–41）"))

story.append(make_bullet("高性能流水线机器必须处理分支问题（p.40）"))
story.append(make_bullet("80486（CISC）：同时取分支后下一条顺序指令<b>和</b>分支目标指令（p.40）"))
story.append(make_bullet("RISC 机器使用<b>延迟分支</b>（Delayed Branch）策略（p.40）："))
story.append(make_bullet("在不可用指令被预取之前计算分支结果（p.40）"))
story.append(make_bullet("始终执行分支后的单条指令，在取新指令流的同时保持流水线充满（p.40）"))

story.append(Spacer(1, 2*mm))
story.append(make_bullet(b("延迟分支对超标量的局限性", "Delayed Branch Limitations for Superscalar")))
story.append(make_bullet("延迟分支策略对超标量机器<b>吸引力较小</b>（p.41）"))
story.append(make_bullet("原因：(1) 延迟槽中需执行多条指令；(2) 指令依赖问题（p.41）"))

story.append(Spacer(1, 2*mm))
story.append(make_bullet(b("分支预测技术回归", "Return of Branch Prediction")))
story.append(make_bullet(b("静态分支预测", "Static Branch Prediction") + "：PowerPC 601（p.41）"))
story.append(make_bullet(b("动态分支预测", "Dynamic Branch Prediction") + "：PowerPC 620 和 Pentium 4（p.41）"))

story.append(PageBreak())

# ===== SECTION 6: SUPERSCALAR EXECUTION =====
story.append(make_heading("六、超标量执行与实现 / Superscalar Execution &amp; Implementation（p.42–43）"))

story.append(make_heading("6.1 超标量执行流程（p.42, Fig 16.7）", h2_style))
story.append(make_bullet("顺序取指（Sequential Fetch）→ 顺序译码（Sequential Inst. Decode）→ 按序重排（In-order Reorder）→ 乱序执行（Out-of-order Execute）"))
story.append(make_bullet("基于<b>数据依赖</b>和<b>资源冲突</b>来决定执行顺序（p.42）"))

story.append(make_heading("6.2 超标量实现关键要素（p.43）", h2_style))
story.append(make_bullet("(1) <b>同时取多条指令</b>（Simultaneously fetch multiple instructions）"))
story.append(make_bullet("(2) <b>判断寄存器值的真依赖</b>的逻辑，以及<b>传递这些值的机制</b>"))
story.append(make_bullet("(3) <b>并行发起多条指令</b>的机制"))
story.append(make_bullet("(4) <b>并行执行多条指令</b>的资源"))
story.append(make_bullet("(5) <b>按正确顺序提交</b>（commit）处理状态的机制"))

story.append(Spacer(1, 5*mm))

# ===== TERMINOLOGY TABLE =====
story.append(make_heading("七、关键术语速查表 / Key Terminology（全章）"))

term_headers = ["中文术语", "English Term", "缩写", "页码"]
term_rows = [
    ["超标量", "Superscalar", "", "p.5-6"],
    ["超级流水线", "Superpipeline", "", "p.9-10"],
    ["指令级并行", "Instruction Level Parallelism", "ILP", "p.11,19"],
    ["机器并行", "Machine Parallelism", "", "p.21"],
    ["操作延迟", "Operation Latency", "", "p.19"],
    ["真数据依赖", "True Data Dependency / Flow Dependency", "RAW", "p.11-13"],
    ["过程依赖", "Procedural Dependency", "", "p.14"],
    ["资源冲突", "Resource Conflict", "", "p.15"],
    ["输出依赖", "Output Dependency", "WAW", "p.17,34"],
    ["反依赖", "Antidependency", "WAR", "p.17,34"],
    ["存储冲突", "Storage Conflict", "", "p.34"],
    ["指令发射", "Instruction Issue", "", "p.22"],
    ["指令发射策略", "Instruction Issue Policy", "", "p.22"],
    ["按序发射", "In-Order Issue", "", "p.23"],
    ["乱序完成", "Out-of-Order Completion", "", "p.28"],
    ["乱序发射", "Out-of-Order Issue", "", "p.30-31"],
    ["指令窗口", "Instruction Window", "", "p.31-33"],
    ["寄存器重命名", "Register Renaming", "", "p.35-37"],
    ["延迟分支", "Delayed Branch", "", "p.40-41"],
    ["分支预测", "Branch Prediction", "", "p.40-41"],
    ["静态分支预测", "Static Branch Prediction", "", "p.41"],
    ["动态分支预测", "Dynamic Branch Prediction", "", "p.41"],
]
story.append(make_table(term_headers, term_rows, [38*mm, 66*mm, 22*mm, 16*mm]))

story.append(Spacer(1, 5*mm))

story.append(make_heading("八、核心公式与速记 / Key Formulas &amp; Memory Hooks"))

story.append(make_bullet("ILP 程度 ∝ 1 /（真数据依赖频率 + 过程依赖频率）—— 依赖越多，并行度越低（p.19）"))
story.append(make_bullet("机器并行能力上限 = min（寻找独立指令的机制能力，可并行执行的功能单元数量）（p.21）"))
story.append(make_bullet("寄存器重命名 = 资源复制 + 动态分配 —— 消除伪依赖（WAR/WAW）但<b>不消除真依赖（RAW）</b>（p.35）"))
story.append(make_bullet("三大硬件优化：复制资源 → 乱序发射 → 寄存器重命名（按效果递增）（p.38）"))
story.append(make_bullet("经验法则：无寄存器重命名 = 加功能单元无意义；指令窗口大小 &gt; 8 才有效（p.38-39）"))

story.append(PageBreak())

story.append(make_heading("九、典型例题提示 / Problem-Solving Hints"))

story.append(make_bullet(b("例题类型", "Typical Exam Questions")))
story.append(make_bullet("(1) 给定指令序列，识别依赖类型（RAW/WAW/WAR）（参考p.17,34示例）"))
story.append(make_bullet("(2) 给定指令序列和功能单元配置，画出不同发射策略下的时空图（参考p.24-27按序完成、p.29乱序完成、p.33乱序发射的执行图）"))
story.append(make_bullet("(3) 对给定代码段进行寄存器重命名，消除伪依赖（参考p.36-37示例）"))
story.append(make_bullet("(4) 比较超标量与超级流水线的性能差异（参考p.9-10）"))

story.append(make_bullet(b("易错点", "Common Pitfalls")))
story.append(make_bullet("混淆 RAW 和 WAW：RAW 是真依赖（不能消除），WAW/WAR 是伪依赖（可通过寄存器重命名消除）"))
story.append(make_bullet("指令窗口不是一个流水段——它是一个缓冲区，用于解耦译码和执行"))
story.append(make_bullet("乱序执行 ≠ 结果乱序 —— 必须按正确顺序提交（commit）过程状态"))
story.append(make_bullet("延迟分支在超标量中效果有限，因为延迟槽需要填充多条指令"))

story.append(Spacer(1, 10*mm))
story.append(Paragraph("— 祝考试顺利 —", ParagraphStyle('End', parent=body_style,
    fontSize=12, alignment=TA_CENTER, textColor=HexColor('#7f8c8d'),
    fontName='SimHei')))

# ===== BUILD PDF =====
pdf_path = os.path.join(OUT, 'Summary - 16_Superscalar.pdf')
doc = SimpleDocTemplate(
    pdf_path,
    pagesize=A4,
    topMargin=18*mm,
    bottomMargin=18*mm,
    leftMargin=18*mm,
    rightMargin=18*mm,
    title='Chapter 16 指令级并行与超标量处理器 - 考前复习资料',
    author='Study Notes Generator',
)

doc.build(story)
print(f'PDF created: {pdf_path}')
print(f'Size: {os.path.getsize(pdf_path)} bytes')
