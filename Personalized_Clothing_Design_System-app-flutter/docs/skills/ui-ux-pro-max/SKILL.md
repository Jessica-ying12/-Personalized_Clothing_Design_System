---
name: ui-ux-pro-max
description: >
  UI/UX 设计智能技能。当用户涉及任何 UI 结构、视觉设计决策、交互模式或用户体验质量控制时，必须调用本技能。
  包含 67 种 UI 风格、161 套配色方案、57 种字体搭配、99 条 UX 准则、25 种图表类型，覆盖 15+ 技术栈。
  本文件完全自包含，无需任何外部脚本或依赖，直接复制到其他项目的 .kiro/steering/ 目录即可使用。
---

# UI/UX Pro Max 设计技能

AI 驱动的设计智能工具包。本文件内嵌了完整的设计数据库，AI 可直接读取并推理，无需执行任何脚本。

## 何时使用

**必须使用：**
- 设计新页面（Landing Page、Dashboard、Admin、SaaS、Mobile App）
- 创建或重构 UI 组件（按钮、弹窗、表单、表格、图表等）
- 选择配色方案、字体系统、间距规范或布局体系
- 审查 UI 代码的用户体验、可访问性或视觉一致性
- 实现导航结构、动效或响应式行为
- 做产品层级的设计决策（风格、信息层级、品牌表达）

**跳过：** 纯后端逻辑、API/数据库设计、基础设施、DevOps

**判断准则**：如果任务会改变某个功能**看起来如何、使用起来如何、如何运动或如何被交互**，就应该使用此技能。

---

## 设计决策工作流

### Step 1：识别产品类型
从下方「产品类型推理规则表」找到最匹配的行，获取推荐的风格、配色、字体方向。

### Step 2：选择 UI 风格
从「UI 风格数据库」中按推荐风格选择，结合 Best For / Do Not Use For 做最终判断。

### Step 3：选择配色方案
从「配色方案数据库」找到对应产品类型的色值，直接使用。

### Step 4：选择字体搭配
从「字体搭配数据库」按情绪关键词匹配，获取 Google Fonts 导入链接。

### Step 5：应用 UX 准则
按优先级（CRITICAL → HIGH → MEDIUM）检查对应规则，交付前过一遍检查清单。

---

## 产品类型推理规则表

| 产品类型 | 推荐模式 | 风格优先级 | 配色情绪 | 字体情绪 | 避免 |
|----------|----------|------------|----------|----------|------|
| SaaS (General) | Hero + Features + CTA | Glassmorphism + Flat Design | Trust blue + Accent contrast | Professional + Hierarchy | Excessive animation + Dark mode by default |
| Micro SaaS | Hero-Centric + Trust | Motion-Driven + Vibrant & Block | Bold primaries + Accent contrast | Modern + Energetic typography | Static design + No video + Poor mobile |
| E-commerce | Feature-Rich Showcase | Vibrant & Block-based | Brand primary + Success green | Engaging + Clear hierarchy | Flat design without depth + Text-heavy pages |
| E-commerce Luxury | Feature-Rich Showcase | Liquid Glass + Glassmorphism | Premium colors + Minimal accent | Elegant + Refined typography | Vibrant & Block-based + Playful colors |
| B2B Service | Feature-Rich Showcase + Trust | Trust & Authority + Minimalism | Professional blue + Neutral grey | Formal + Clear typography | Playful design + Hidden credentials + AI purple/pink gradients |
| Financial Dashboard | Data-Dense Dashboard | Dark Mode (OLED) + Data-Dense | Dark bg + Red/Green alerts + Trust blue | Clear + Readable typography | Light mode default + Slow rendering |
| Analytics Dashboard | Data-Dense + Drill-Down | Data-Dense + Heat Map | Cool→Hot gradients + Neutral grey | Clear + Functional typography | Ornate design + No filtering |
| Healthcare App | Social Proof-Focused | Neumorphism + Accessible & Ethical | Calm blue + Health green | Readable + Large type (16px+) | Bright neon colors + Motion-heavy animations + AI purple/pink gradients |
| Educational App | Feature-Rich Showcase | Claymorphism + Micro-interactions | Playful colors + Clear hierarchy | Friendly + Engaging typography | Dark modes + Complex jargon |
| Creative Agency | Storytelling-Driven | Brutalism + Motion-Driven | Bold primaries + Artistic freedom | Bold + Expressive typography | Corporate minimalism + Hidden portfolio |
| Portfolio/Personal | Storytelling-Driven | Motion-Driven + Minimalism | Brand primary + Artistic | Expressive + Variable typography | Corporate templates + Generic layouts |
| Gaming | Feature-Rich Showcase | 3D & Hyperrealism + Retro-Futurism | Vibrant + Neon + Immersive | Bold + Impactful typography | Minimalist design + Static assets |
| Government/Public Service | Minimal & Direct | Accessible & Ethical + Minimalism | Professional blue + High contrast | Clear + Large typography | Ornate design + Low contrast + Motion effects + AI purple/pink gradients |
| Fintech/Crypto | Trust & Authority | Minimalism + Accessible & Ethical | Navy + Trust Blue + Gold | Professional + Trustworthy | Playful design + Unclear fees + AI purple/pink gradients |
| Social Media App | Feature-Rich Showcase | Vibrant & Block-based + Motion-Driven | Vibrant + Engagement colors | Modern + Bold typography | Heavy skeuomorphism + Accessibility ignored |
| Productivity Tool | Interactive Demo + Feature-Rich | Flat Design + Micro-interactions | Clear hierarchy + Functional colors | Clean + Efficient typography | Complex onboarding + Slow performance |
| Design System/Component Library | Feature-Rich + Documentation | Minimalism + Accessible & Ethical | Clear hierarchy + Code-like structure | Monospace + Clear typography | Poor documentation + No live preview |
| AI/Chatbot Platform | Interactive Demo + Minimal | AI-Native UI + Minimalism | Neutral + AI Purple (#6366F1) | Modern + Clear typography | Heavy chrome + Slow response feedback |
| NFT/Web3 Platform | Feature-Rich Showcase | Cyberpunk UI + Glassmorphism | Dark + Neon + Gold (#FFD700) | Bold + Modern typography | Light mode default + No transaction status |
| Creator Economy Platform | Social Proof + Feature-Rich | Vibrant & Block-based + Bento Box Grid | Vibrant + Brand colors | Modern + Bold typography | Generic layout + Hidden earnings |
| Remote Work/Collaboration Tool | Feature-Rich + Real-Time | Soft UI Evolution + Minimalism | Calm Blue + Neutral grey | Clean + Readable typography | Cluttered interface + No presence |
| Mental Health App | Social Proof-Focused | Neumorphism + Accessible & Ethical | Calm Pastels + Trust colors | Calming + Readable typography | Bright neon + Motion overload |
| Pet Tech App | Storytelling + Feature-Rich | Claymorphism + Vibrant & Block-based | Playful + Warm colors | Friendly + Playful typography | Generic design + No personality |
| Smart Home/IoT Dashboard | Real-Time Monitoring | Glassmorphism + Dark Mode (OLED) | Dark + Status indicator colors | Clear + Functional typography | Slow updates + No automation |
| EV/Charging Ecosystem | Hero-Centric + Feature-Rich | Minimalism + Aurora UI | Electric Blue (#009CD1) + Green | Modern + Clear typography | Poor map UX + Hidden costs |
| Subscription Box Service | Feature-Rich + Conversion | Vibrant & Block-based + Motion-Driven | Brand + Excitement colors | Engaging + Clear typography | Confusing pricing + No unboxing preview |
| Podcast Platform | Storytelling + Feature-Rich | Dark Mode (OLED) + Minimalism | Dark + Audio waveform accents | Modern + Clear typography | Poor audio player + Cluttered layout |
| Dating App | Social Proof + Feature-Rich | Vibrant & Block-based + Motion-Driven | Warm + Romantic (Pink/Red gradients) | Modern + Friendly typography | Generic profiles + No safety |
| Micro-Credentials/Badges Platform | Trust & Authority + Feature | Minimalism + Flat Design | Trust Blue + Gold (#FFD700) | Professional + Clear typography | No verification + Hidden progress |
| Knowledge Base/Documentation | FAQ + Minimal | Minimalism + Accessible & Ethical | Clean hierarchy + Minimal color | Clear + Readable typography | Poor navigation + No search |
| Hyperlocal Services | Conversion + Feature-Rich | Minimalism + Vibrant & Block-based | Location markers + Trust colors | Clear + Functional typography | No map + Hidden reviews |
| Beauty/Spa/Wellness Service | Hero-Centric + Social Proof | Soft UI Evolution + Neumorphism | Soft pastels (Pink Sage Cream) + Gold accents | Elegant + Calming typography | Bright neon colors + Harsh animations + Dark mode |
| Luxury/Premium Brand | Storytelling + Feature-Rich | Liquid Glass + Glassmorphism | Black + Gold (#FFD700) + White | Elegant + Refined typography | Cheap visuals + Fast animations |
| Restaurant/Food Service | Hero-Centric + Conversion | Vibrant & Block-based + Motion-Driven | Warm colors (Orange Red Brown) | Appetizing + Clear typography | Low-quality imagery + Outdated hours |
| Fitness/Gym App | Feature-Rich + Data | Vibrant & Block-based + Dark Mode (OLED) | Energetic (Orange #FF6B35) + Dark bg | Bold + Motivational typography | Static design + No gamification |
| Real Estate/Property | Hero-Centric + Feature-Rich | Glassmorphism + Minimalism | Trust Blue + Gold + White | Professional + Confident | Poor photos + No virtual tours |
| Travel/Tourism Agency | Storytelling-Driven + Hero | Aurora UI + Motion-Driven | Vibrant destination + Sky Blue | Inspirational + Engaging | Generic photos + Complex booking |
| Hotel/Hospitality | Hero-Centric + Social Proof | Liquid Glass + Minimalism | Warm neutrals + Gold (#D4AF37) | Elegant + Welcoming typography | Poor photos + Complex booking |
| Wedding/Event Planning | Storytelling + Social Proof | Soft UI Evolution + Aurora UI | Soft Pink (#FFD6E0) + Gold + Cream | Elegant + Romantic typography | Generic templates + No portfolio |
| Legal Services | Trust & Authority + Minimal | Trust & Authority + Minimalism | Navy Blue (#1E3A5F) + Gold + White | Professional + Authoritative typography | Outdated design + Hidden credentials + AI purple/pink gradients |
| Insurance Platform | Conversion + Trust | Trust & Authority + Flat Design | Trust Blue (#0066CC) + Green + Neutral | Clear + Professional typography | Confusing pricing + No trust signals + AI purple/pink gradients |
| Banking/Traditional Finance | Trust & Authority + Feature | Minimalism + Accessible & Ethical | Navy (#0A1628) + Trust Blue + Gold | Professional + Trustworthy typography | Playful design + Poor security UX + AI purple/pink gradients |
| Online Course/E-learning | Feature-Rich + Social Proof | Claymorphism + Vibrant & Block-based | Vibrant learning colors + Progress green | Friendly + Engaging typography | Boring design + No gamification |
| Non-profit/Charity | Storytelling + Trust | Accessible & Ethical + Organic Biophilic | Cause-related colors + Trust + Warm | Heartfelt + Readable typography | No impact data + Hidden financials |
| Music Streaming | Feature-Rich Showcase | Dark Mode (OLED) + Vibrant & Block-based | Dark (#121212) + Vibrant accents + Album art colors | Modern + Bold typography | Cluttered layout + Poor audio player UX |
| Video Streaming/OTT | Hero-Centric + Feature-Rich | Dark Mode (OLED) + Motion-Driven | Dark bg + Poster colors + Brand accent | Bold + Engaging typography | Static layout + Slow video player |
| Job Board/Recruitment | Conversion-Optimized + Feature-Rich | Flat Design + Minimalism | Professional Blue + Success Green + Neutral | Clear + Professional typography | Outdated forms + Hidden filters |
| Marketplace (P2P) | Feature-Rich Showcase + Social Proof | Vibrant & Block-based + Flat Design | Trust colors + Category colors + Success green | Modern + Engaging typography | Low trust signals + Confusing layout |
| Logistics/Delivery | Feature-Rich Showcase + Real-Time | Minimalism + Flat Design | Blue (#2563EB) + Orange (tracking) + Green | Clear + Functional typography | Static tracking + No map integration + AI purple/pink gradients |
| Agriculture/Farm Tech | Feature-Rich Showcase | Organic Biophilic + Flat Design | Earth Green (#4A7C23) + Brown + Sky Blue | Clear + Informative typography | Generic design + Ignored accessibility + AI purple/pink gradients |
| Construction/Architecture | Hero-Centric + Feature-Rich | Minimalism + 3D & Hyperrealism | Grey (#4A4A4A) + Orange (safety) + Blueprint Blue | Professional + Bold typography | 2D-only layouts + Poor image quality + AI purple/pink gradients |
| Automotive/Car Dealership | Hero-Centric + Feature-Rich | Motion-Driven + 3D & Hyperrealism | Brand colors + Metallic + Dark/Light | Bold + Confident typography | Static product pages + Poor UX |
| Photography Studio | Storytelling-Driven + Hero-Centric | Motion-Driven + Minimalism | Black + White + Minimal accent | Elegant + Minimal typography | Heavy text + Poor image showcase |
| Coworking Space | Hero-Centric + Feature-Rich | Vibrant & Block-based + Glassmorphism | Energetic colors + Wood tones + Brand | Modern + Engaging typography | Outdated photos + Confusing layout |
| Home Services (Plumber/Electrician) | Conversion-Optimized + Trust | Flat Design + Trust & Authority | Trust Blue + Safety Orange + Grey | Professional + Clear typography | Hidden contact info + No certifications |
| Childcare/Daycare | Social Proof-Focused + Trust | Claymorphism + Vibrant & Block-based | Playful pastels + Safe colors + Warm | Friendly + Playful typography | Generic design + Hidden safety info |
| Senior Care/Elderly | Trust & Authority + Accessible | Accessible & Ethical + Soft UI Evolution | Calm Blue + Warm neutrals + Large text | Large + Clear typography (18px+) | Small text + Complex navigation + AI purple/pink gradients |
| Medical Clinic | Trust & Authority + Conversion | Accessible & Ethical + Minimalism | Medical Blue (#0077B6) + Trust White | Professional + Readable typography | Outdated interface + Confusing booking + AI purple/pink gradients |
| Pharmacy/Drug Store | Conversion-Optimized + Trust | Flat Design + Accessible & Ethical | Pharmacy Green + Trust Blue + Clean White | Clear + Functional typography | Confusing layout + Privacy concerns + AI purple/pink gradients |
| Dental Practice | Social Proof-Focused + Conversion | Soft UI Evolution + Minimalism | Fresh Blue + White + Smile Yellow | Friendly + Professional typography | Poor imagery + No testimonials |
| Veterinary Clinic | Social Proof-Focused + Trust | Claymorphism + Accessible & Ethical | Caring Blue + Pet colors + Warm | Friendly + Welcoming typography | Generic design + Hidden services |
| Florist/Plant Shop | Hero-Centric + Conversion | Organic Biophilic + Vibrant & Block-based | Natural Green + Floral pinks/purples | Elegant + Natural typography | Poor imagery + No seasonal content |
| Bakery/Cafe | Hero-Centric + Conversion | Vibrant & Block-based + Soft UI Evolution | Warm Brown + Cream + Appetizing accents | Warm + Inviting typography | Poor food photos + Hidden hours |
| Brewery/Winery | Storytelling + Hero-Centric | Motion-Driven + Storytelling-Driven | Deep amber/burgundy + Gold + Craft | Artisanal + Heritage typography | Generic product pages + No story |
| Airline | Conversion + Feature-Rich | Minimalism + Glassmorphism | Sky Blue + Brand colors + Trust | Clear + Professional typography | Complex booking + Poor mobile |
| News/Media Platform | Hero-Centric + Feature-Rich | Minimalism + Flat Design | Brand colors + High contrast | Clear + Readable typography | Cluttered layout + Slow loading |
| Magazine/Blog | Storytelling + Hero-Centric | Swiss Modernism 2.0 + Motion-Driven | Editorial colors + Brand + Clean white | Editorial + Elegant typography | Poor typography + Slow loading |
| Freelancer Platform | Feature-Rich + Conversion | Flat Design + Minimalism | Professional Blue + Success Green | Clear + Professional typography | Poor profiles + No reviews |
| Marketing Agency | Storytelling + Feature-Rich | Brutalism + Motion-Driven | Bold brand colors + Creative freedom | Bold + Expressive typography | Boring design + Hidden work |
| Event Management | Hero-Centric + Feature-Rich | Vibrant & Block-based + Motion-Driven | Event theme colors + Excitement accents | Bold + Engaging typography | Confusing registration + No countdown |
| Membership/Community | Social Proof + Conversion | Vibrant & Block-based + Soft UI Evolution | Community brand colors + Engagement | Friendly + Engaging typography | Hidden benefits + No community proof |
| Newsletter Platform | Minimal + Conversion | Minimalism + Flat Design | Brand primary + Clean white + CTA | Clean + Readable typography | Complex signup + No preview |
| Digital Products/Downloads | Feature-Rich + Conversion | Vibrant & Block-based + Motion-Driven | Product colors + Brand + Success green | Modern + Clear typography | No preview + Slow delivery |
| Church/Religious Organization | Hero-Centric + Social Proof | Accessible & Ethical + Soft UI Evolution | Warm Gold + Deep Purple/Blue + White | Welcoming + Clear typography | Outdated design + Hidden info |
| Sports Team/Club | Hero-Centric + Feature-Rich | Vibrant & Block-based + Motion-Driven | Team colors + Energetic accents | Bold + Impactful typography | Static content + Poor fan engagement |
| Museum/Gallery | Storytelling + Feature-Rich | Minimalism + Motion-Driven | Art-appropriate neutrals + Exhibition accents | Elegant + Minimal typography | Cluttered layout + No online access |
| Theater/Cinema | Hero-Centric + Conversion | Dark Mode (OLED) + Motion-Driven | Dark + Spotlight accents + Gold | Dramatic + Bold typography | Poor booking UX + No trailers |
| Language Learning App | Feature-Rich + Social Proof | Claymorphism + Vibrant & Block-based | Playful colors + Progress indicators | Friendly + Clear typography | Boring design + No motivation |
| Coding Bootcamp | Feature-Rich + Social Proof | Dark Mode (OLED) + Minimalism | Code editor colors + Brand + Success | Technical + Clear typography | Light mode only + Hidden results |
| Cybersecurity Platform | Trust & Authority + Real-Time | Cyberpunk UI + Dark Mode (OLED) | Matrix Green (#00FF00) + Deep Black | Technical + Clear typography | Light mode + Poor data viz |
| Developer Tool / IDE | Minimal + Documentation | Dark Mode (OLED) + Minimalism | Dark syntax theme + Blue focus | Monospace + Functional typography | Light mode default + Slow performance |
| Biotech / Life Sciences | Storytelling + Data | Glassmorphism + Clean Science | Sterile White + DNA Blue + Life Green | Scientific + Clear typography | Cluttered data + Poor credibility |
| Space Tech / Aerospace | Immersive + Feature-Rich | Holographic/HUD + Dark Mode | Deep Space Black + Star White + Metallic | Futuristic + Precise typography | Generic design + No immersion |
| Architecture / Interior | Portfolio + Hero-Centric | Exaggerated Minimalism + High Imagery | Monochrome + Gold Accent + High Imagery | Architectural + Elegant typography | Poor imagery + Cluttered layout |
| Quantum Computing Interface | Immersive + Interactive | Holographic/HUD + Dark Mode | Quantum Blue (#00FFFF) + Deep Black | Futuristic + Scientific typography | Generic tech design + No viz |
| Biohacking / Longevity App | Data-Dense + Storytelling | Biomimetic/Organic 2.0 + Minimalism | Cellular Pink/Red + DNA Blue + White | Scientific + Clear typography | Generic health app + No privacy |
| Autonomous Drone Fleet Manager | Real-Time + Feature-Rich | HUD/Sci-Fi FUI + Real-Time | Tactical Green + Alert Red + Map Dark | Technical + Functional typography | Slow updates + Poor spatial viz |
| Generative Art Platform | Showcase + Feature-Rich | Minimalism + Gen Z Chaos | Neutral (#F5F5F5) + User Content | Minimal + Content-focused typography | Heavy chrome + Slow loading |
| Spatial Computing OS / App | Immersive + Interactive | Spatial UI (VisionOS) + Glassmorphism | Frosted Glass + System Colors + Depth | Spatial + Readable typography | 2D design + No spatial depth |
| Sustainable Energy / Climate Tech | Data + Trust | Organic Biophilic + E-Ink/Paper | Earth Green + Sky Blue + Solar Yellow | Clear + Informative typography | Greenwashing + No real data |
| Personal Finance Tracker | Interactive Product Demo | Glassmorphism + Dark Mode (OLED) | Calm blue + success green + alert red + chart accents | Modern + Clear hierarchy | Pure white backgrounds |
| Chat & Messaging App | Feature-Rich Showcase + Demo | Minimalism + Micro-interactions | Brand primary + bubble contrast (sender/receiver) + typing grey | Professional + Clean hierarchy | Excessive decoration |
| Notes & Writing App | Minimal & Direct | Minimalism + Flat Design | Clean white/cream + minimal accent + editor syntax colors | Professional + Clean hierarchy | Excessive decoration + Complex shadows + 3D effects |
| Habit Tracker | Social Proof-Focused + Demo | Claymorphism + Vibrant & Block-based | Streak warm (amber/orange) + progress green + motivational accents | Playful + Rounded + Friendly | Muted colors + Low energy |
| Food Delivery / On-Demand | Hero-Centric Design + Feature-Rich | Vibrant & Block-based + Motion-Driven | Appetizing warm (orange/red) + trust blue + map accent | Energetic + Bold + Large | Muted colors + Low energy |
| Ride Hailing / Transportation | Conversion-Optimized + Demo | Minimalism + Glassmorphism | Brand primary + map neutral + status indicator colors | Professional + Clean hierarchy | Excessive decoration |
| Recipe & Cooking App | Hero-Centric Design + Feature-Rich | Claymorphism + Vibrant & Block-based | Warm food tones (terracotta/sage/cream) + appetizing imagery | Playful + Rounded + Friendly | Muted colors + Low energy |
| Meditation & Mindfulness | Storytelling-Driven + Social Proof | Neumorphism + Soft UI Evolution | Ultra-calm pastels (lavender/sage/sky) + breathing animation gradient | Subtle + Soft + Monochromatic | Inconsistent styling + Poor contrast ratios |
| Weather App | Hero-Centric Design | Glassmorphism + Aurora UI | Atmospheric gradients (sky blue → sunset → storm grey) + temp scale | Modern + Clear hierarchy | Inconsistent styling + Poor contrast ratios |
| Diary & Journal App | Storytelling-Driven | Soft UI Evolution + Minimalism | Warm paper tones (cream/linen) + muted ink + mood-coded accents | Professional + Clean hierarchy | Excessive decoration |
| CRM & Client Management | Feature-Rich Showcase + Demo | Flat Design + Minimalism | Professional blue + pipeline stage colors + closed-won green | Professional + Clean hierarchy | Excessive decoration + Complex shadows + 3D effects |
| Inventory & Stock Management | Feature-Rich Showcase | Flat Design + Minimalism | Functional neutral + status traffic-light (green/amber/red) + scanner accent | Professional + Clean hierarchy | Excessive decoration + Complex shadows + 3D effects |
| Flashcard & Study Tool | Feature-Rich Showcase + Demo | Claymorphism + Micro-interactions | Playful primary + correct green + incorrect red + progress blue | Playful + Rounded + Friendly | Inconsistent styling + Poor contrast ratios |
| Booking & Appointment App | Conversion-Optimized | Soft UI Evolution + Flat Design | Trust blue + available green + booked grey + confirm accent | Bold + Clean + Sans-serif | Complex shadows + 3D effects |
| Invoice & Billing Tool | Conversion-Optimized + Trust | Minimalism + Flat Design | Professional navy + paid green + overdue red + neutral grey | Professional + Clean hierarchy | Excessive decoration + Complex shadows + 3D effects |
| Grocery & Shopping List | Minimal & Direct + Demo | Flat Design + Vibrant & Block-based | Fresh green + food-category colors + checkmark accent | Bold + Clean + Sans-serif | Complex shadows + 3D effects + Muted colors + Low energy |
| Timer & Pomodoro | Minimal & Direct | Minimalism + Neumorphism | High-contrast on dark + focus red/amber + break green | Professional + Clean hierarchy | Excessive decoration |
| Parenting & Baby Tracker | Social Proof-Focused + Trust | Claymorphism + Soft UI Evolution | Soft pastels (baby pink/sky blue/mint/peach) + warm accents | Playful + Rounded + Friendly | Inconsistent styling + Poor contrast ratios |
| Scanner & Document Manager | Feature-Rich Showcase + Demo | Minimalism + Flat Design | Clean white + camera viewfinder accent + file-type color coding | Professional + Clean hierarchy | Excessive decoration + Complex shadows + 3D effects |
| Calendar & Scheduling App | Feature-Rich Showcase + Demo | Flat Design + Micro-interactions | Clean blue + event category accent colors + success green | Bold + Clean + Sans-serif | Complex shadows + 3D effects |
| Password Manager | Trust & Authority + Feature-Rich | Minimalism + Accessible & Ethical | Trust blue + security green + dark neutral | Professional + Clean hierarchy | Excessive decoration + Color-only indicators |
| Expense Splitter / Bill Split | Minimal & Direct + Demo | Flat Design + Vibrant & Block-based | Success green + alert red + neutral grey + avatar accent colors | Bold + Clean + Sans-serif | Complex shadows + 3D effects + Muted colors + Low energy |
| Voice Recorder & Memo | Interactive Product Demo + Minimal | Minimalism + AI-Native UI | Clean white + recording red + waveform accent | Professional + Clean hierarchy | Excessive decoration |
| Bookmark & Read-Later | Minimal & Direct + Demo | Minimalism + Flat Design | Paper warm white + ink neutral + minimal accent + tag colors | Professional + Clean hierarchy | Excessive decoration + Complex shadows + 3D effects |
| Translator App | Feature-Rich Showcase + Interactive Demo | Flat Design + AI-Native UI | Global blue + neutral grey + language flag accent | Bold + Clean + Sans-serif | Complex shadows + 3D effects |
| Calculator & Unit Converter | Minimal & Direct | Neumorphism + Minimalism | Dark functional + orange operation keys + clear button hierarchy | Professional + Clean hierarchy | Excessive decoration |
| Alarm & World Clock | Minimal & Direct | Dark Mode (OLED) + Minimalism | Deep dark + ambient glow accent + timezone gradient | Professional + Clean hierarchy | Excessive decoration + Pure white backgrounds |
| File Manager & Transfer | Feature-Rich Showcase + Demo | Flat Design + Minimalism | Functional neutral + file type color coding (PDF orange, doc blue, image purple) | Professional + Clean hierarchy | Excessive decoration + Complex shadows + 3D effects |
| Email Client | Feature-Rich Showcase + Demo | Flat Design + Minimalism | Clean white + brand primary + priority red + snooze amber | Professional + Clean hierarchy | Excessive decoration + Complex shadows + 3D effects |
| Casual Puzzle Game | Feature-Rich Showcase + Social Proof | Claymorphism + Vibrant & Block-based | Cheerful pastels + progression gradient + reward gold + bright accent | Playful + Rounded + Friendly | Muted colors + Low energy |
| Trivia & Quiz Game | Feature-Rich Showcase + Social Proof | Vibrant & Block-based + Micro-interactions | Energetic blue + correct green + incorrect red + leaderboard gold | Energetic + Bold + Large | Muted colors + Low energy |
| Card & Board Game | Feature-Rich Showcase | 3D & Hyperrealism + Flat Design | Game-theme felt green + dark wood + card back patterns | Bold + Clean + Sans-serif | Complex shadows + 3D effects |
| Idle & Clicker Game | Feature-Rich Showcase | Vibrant & Block-based + Motion-Driven | Coin gold + upgrade blue + prestige purple + progress green | Energetic + Bold + Large | Muted colors + Low energy |
| Word & Crossword Game | Minimal & Direct + Demo | Minimalism + Flat Design | Clean white + warm letter tiles + success green + shake red | Professional + Clean hierarchy | Excessive decoration + Complex shadows + 3D effects |
| Arcade & Retro Game | Feature-Rich Showcase + Hero-Centric | Pixel Art + Retro-Futurism | Neon on black + pixel palette + score gold + danger red | Nostalgic + Monospace + Neon | Inconsistent styling + Poor contrast ratios |
| Photo Editor & Filters | Feature-Rich Showcase + Interactive Demo | Minimalism + Dark Mode (OLED) | Dark editor background + vibrant filter preview strip + tool icon accent | Professional + Clean hierarchy | Excessive decoration + Pure white backgrounds |
| Short Video Editor | Feature-Rich Showcase + Hero-Centric | Dark Mode (OLED) + Motion-Driven | Dark background + timeline track accent colors + effect preview vivid | High contrast + Light on dark | Pure white backgrounds |
| Drawing & Sketching Canvas | Interactive Product Demo + Storytelling | Minimalism + Dark Mode (OLED) | Neutral canvas + full-spectrum color picker + tool panel dark | Professional + Clean hierarchy | Excessive decoration + Pure white backgrounds |
| Music Creation & Beat Maker | Interactive Product Demo + Storytelling | Dark Mode (OLED) + Motion-Driven | Dark studio background + track colors rainbow + waveform accent + BPM pulse | High contrast + Light on dark | Pure white backgrounds |
| Meme & Sticker Maker | Feature-Rich Showcase + Social Proof | Vibrant & Block-based + Flat Design | Bold primary + comedic yellow + viral red + high saturation accent | Bold + Clean + Sans-serif | Complex shadows + 3D effects + Muted colors + Low energy |
| AI Photo & Avatar Generator | Feature-Rich Showcase + Social Proof | AI-Native UI + Aurora UI | AI purple + aurora gradients + before/after neutral | Elegant + Gradient-friendly | Inconsistent styling + Poor contrast ratios |
| Link-in-Bio Page Builder | Conversion-Optimized + Social Proof | Vibrant & Block-based + Bento Box Grid | Brand-customizable + accent link color + clean white canvas | Energetic + Bold + Large | Muted colors + Low energy |
| Wardrobe & Outfit Planner | Storytelling-Driven + Feature-Rich | Minimalism + Motion-Driven | Clean fashion neutral + full clothes color palette + accent | Professional + Clean hierarchy | Excessive decoration |
| Plant Care Tracker | Storytelling-Driven + Social Proof | Organic Biophilic + Soft UI Evolution | Nature greens + earth brown + sunny yellow reminder + water blue | Warm + Humanist + Natural | Inconsistent styling + Poor contrast ratios |
| Book & Reading Tracker | Social Proof-Focused + Feature-Rich | Swiss Modernism 2.0 + Minimalism | Warm paper white + ink brown + reading progress green + book cover colors | Professional + Clean hierarchy | Excessive decoration |
| Couple & Relationship App | Storytelling-Driven + Social Proof | Aurora UI + Soft UI Evolution | Warm romantic pink/rose + soft gradient + memory photo tones | Elegant + Gradient-friendly | Inconsistent styling + Poor contrast ratios |
| Family Calendar & Chores | Feature-Rich Showcase + Social Proof | Flat Design + Claymorphism | Warm playful + member color coding + chore completion green | Playful + Rounded + Friendly | Complex shadows + 3D effects |
| Mood Tracker | Storytelling-Driven + Social Proof | Soft UI Evolution + Minimalism | Emotion gradient (blue sad to yellow happy) + pastel per mood + insight accent | Professional + Clean hierarchy | Excessive decoration |
| Gift & Wishlist | Minimal & Direct + Conversion | Vibrant & Block-based + Soft UI Evolution | Celebration warm pink/gold/red + category colors + surprise accent | Energetic + Bold + Large | Muted colors + Low energy |
| Running & Cycling GPS | Feature-Rich Showcase + Social Proof | Dark Mode (OLED) + Vibrant & Block-based | Energetic orange + map accent + pace zones (green/yellow/red) | High contrast + Light on dark | Pure white backgrounds + Muted colors + Low energy |
| Yoga & Stretching Guide | Storytelling-Driven + Social Proof | Organic Biophilic + Soft UI Evolution | Earth calming sage/terracotta/cream + breathing gradient + warm accent | Warm + Humanist + Natural | Inconsistent styling + Poor contrast ratios |
| Sleep Tracker | Feature-Rich Showcase + Social Proof | Dark Mode (OLED) + Neumorphism | Deep midnight blue + stars/moon accent + sleep quality gradient (poor red to great green) | High contrast + Light on dark | Pure white backgrounds |
| Calorie & Nutrition Counter | Feature-Rich Showcase + Social Proof | Flat Design + Vibrant & Block-based | Healthy green + macro colors (protein blue, carb orange, fat yellow) + progress circle | Bold + Clean + Sans-serif | Complex shadows + 3D effects + Muted colors + Low energy |
| Period & Cycle Tracker | Social Proof-Focused + Trust | Soft UI Evolution + Aurora UI | Rose/blush + lavender + fertility green + soft calendar tones | Elegant + Gradient-friendly | Inconsistent styling + Poor contrast ratios |
| Medication & Pill Reminder | Trust & Authority + Feature-Rich | Accessible & Ethical + Flat Design | Medical trust blue + missed alert red + taken green + clean white | Bold + Clean + Sans-serif | Complex shadows + 3D effects + Color-only indicators |
| Water & Hydration Reminder | Minimal & Direct + Demo | Claymorphism + Vibrant & Block-based | Refreshing blue + water wave animation + goal progress accent | Playful + Rounded + Friendly | Muted colors + Low energy |
| Fasting & Intermittent Timer | Feature-Rich Showcase + Social Proof | Minimalism + Dark Mode (OLED) | Fasting deep blue/purple + eating window green + timeline neutral | Professional + Clean hierarchy | Excessive decoration + Pure white backgrounds |
| Anonymous Community / Confession | Social Proof-Focused + Feature-Rich | Dark Mode (OLED) + Minimalism | Dark protective + subtle gradient + upvote green + empathy warm accent | Professional + Clean hierarchy | Excessive decoration + Pure white backgrounds |
| Local Events & Discovery | Hero-Centric Design + Feature-Rich | Vibrant & Block-based + Motion-Driven | City vibrant + event category colors + map accent + date highlight | Energetic + Bold + Large | Muted colors + Low energy |
| Study Together / Virtual Coworking | Social Proof-Focused + Feature-Rich | Minimalism + Soft UI Evolution | Calm focus blue + session progress indicator + ambient warm neutrals | Professional + Clean hierarchy | Excessive decoration |
| Coding Challenge & Practice | Feature-Rich Showcase + Social Proof | Dark Mode (OLED) + Cyberpunk UI | Code editor dark + success green + difficulty gradient (easy green / medium amber / hard red) | High contrast + Light on dark | Pure white backgrounds |
| Kids Learning (ABC & Math) | Social Proof-Focused + Trust | Claymorphism + Vibrant & Block-based | Bright primary + child-safe pastels + reward gold + interactive accent | Playful + Rounded + Friendly | Muted colors + Low energy |
| Music Instrument Learning | Interactive Product Demo + Social Proof | Vibrant & Block-based + Motion-Driven | Musical warm deep red/brown + note color system + skill progress bar | Energetic + Bold + Large | Muted colors + Low energy |
| Parking Finder | Conversion-Optimized + Feature-Rich | Minimalism + Glassmorphism | Trust blue + available green + occupied red + map neutral | Professional + Clean hierarchy | Excessive decoration |
| Public Transit Guide | Feature-Rich Showcase + Interactive Demo | Flat Design + Accessible & Ethical | Transit brand line colors + real-time indicator green/red + map neutral | Bold + Clean + Sans-serif | Complex shadows + 3D effects + Color-only indicators |
| Road Trip Planner | Storytelling-Driven + Hero-Centric | Aurora UI + Organic Biophilic | Adventure warm sunset orange + map teal + stop markers + road neutral | Elegant + Gradient-friendly | Inconsistent styling + Poor contrast ratios |
| VPN & Privacy Tool | Trust & Authority + Conversion-Optimized | Minimalism + Dark Mode (OLED) | Dark shield blue + connected green + disconnected red + trust accent | Professional + Clean hierarchy | Excessive decoration + Pure white backgrounds |
| Emergency SOS & Safety | Trust & Authority + Social Proof | Accessible & Ethical + Flat Design | Alert red + safety blue + location green + high contrast critical | Bold + Clean + Sans-serif | Complex shadows + 3D effects + Color-only indicators |
| Wallpaper & Theme App | Feature-Rich Showcase + Social Proof | Vibrant & Block-based + Aurora UI | Content-driven + trending aesthetic palettes + download accent | Energetic + Bold + Large | Muted colors + Low energy |
| White Noise & Ambient Sound | Minimal & Direct + Social Proof | Minimalism + Dark Mode (OLED) | Calming dark + ambient texture visual + subtle sound wave + sleep blue | Professional + Clean hierarchy | Excessive decoration + Pure white backgrounds |
| Home Decoration & Interior Design | Storytelling-Driven + Feature-Rich | Minimalism + 3D Product Preview | Neutral interior palette + material texture accent + AR blue | Professional + Clean hierarchy | Excessive decoration |

---


## UI 风格数据库（67 种）

| # | 风格名称 | 类型 | 关键词 | 适用场景 | 不适用场景 |
|---|----------|------|--------|----------|------------|
| 1 | Minimalism & Swiss Style | General | Clean, simple, spacious, functional, white space, high contrast, geometric, s... | Enterprise apps, dashboards, documentation sites, SaaS platforms, professiona... | Creative portfolios, entertainment, playful brands, artistic experiments |
| 2 | Neumorphism | General | Soft UI, embossed, debossed, convex, concave, light source, subtle depth, rou... | Health/wellness apps, meditation platforms, fitness trackers, minimal interac... | Complex apps, critical accessibility, data-heavy dashboards, high-contrast re... |
| 3 | Glassmorphism | General | Frosted glass, transparent, blurred background, layered, vibrant background, ... | Modern SaaS, financial dashboards, high-end corporate, lifestyle apps, modal ... | Low-contrast backgrounds, critical accessibility, performance-limited, dark t... |
| 4 | Brutalism | General | Raw, unpolished, stark, high contrast, plain text, default fonts, visible bor... | Design portfolios, artistic projects, counter-culture brands, editorial/media... | Corporate environments, conservative industries, critical accessibility, cust... |
| 5 | 3D & Hyperrealism | General | Depth, realistic textures, 3D models, spatial navigation, tactile, skeuomorph... | Gaming, product showcase, immersive experiences, high-end e-commerce, archite... | Low-end mobile, performance-limited, critical accessibility, data tables/forms |
| 6 | Vibrant & Block-based | General | Bold, energetic, playful, block layout, geometric shapes, high color contrast... | Startups, creative agencies, gaming, social media, youth-focused, entertainme... | Financial institutions, healthcare, formal business, government, conservative... |
| 7 | Dark Mode (OLED) | General | Dark theme, low light, high contrast, deep black, midnight blue, eye-friendly... | Night-mode apps, coding platforms, entertainment, eye-strain prevention, OLED... | Print-first content, high-brightness outdoor, color-accuracy-critical |
| 8 | Accessible & Ethical | General | High contrast, large text (16px+), keyboard navigation, screen reader friendl... | Government, healthcare, education, inclusive products, large audience, legal ... | None - accessibility universal |
| 9 | Claymorphism | General | Soft 3D, chunky, playful, toy-like, bubbly, thick borders (3-4px), double sha... | Educational apps, children's apps, SaaS platforms, creative tools, fun-focuse... | Formal corporate, professional services, data-critical, serious/medical, lega... |
| 10 | Aurora UI | General | Vibrant gradients, smooth blend, Northern Lights effect, mesh gradient, lumin... | Modern SaaS, creative agencies, branding, music platforms, lifestyle, premium... | Data-heavy dashboards, critical accessibility, content-heavy where distractio... |
| 11 | Retro-Futurism | General | Vintage sci-fi, 80s aesthetic, neon glow, geometric patterns, CRT scanlines, ... | Gaming, entertainment, music platforms, tech brands, artistic projects, nosta... | Conservative industries, critical accessibility, professional/corporate, elde... |
| 12 | Flat Design | General | 2D, minimalist, bold colors, no shadows, clean lines, simple shapes, typograp... | Web apps, mobile apps, cross-platform, startup MVPs, user-friendly, SaaS, das... | Complex 3D, premium/luxury, artistic portfolios, immersive experiences, high-... |
| 13 | Skeuomorphism | General | Realistic, texture, depth, 3D appearance, real-world metaphors, shadows, grad... | Legacy apps, gaming, immersive storytelling, premium products, luxury, realis... | Modern enterprise, critical accessibility, low-performance, web (use Flat/Mod... |
| 14 | Liquid Glass | General | Flowing glass, morphing, smooth transitions, fluid effects, translucent, anim... | Premium SaaS, high-end e-commerce, creative platforms, branding experiences, ... | Performance-limited, critical accessibility, complex data, budget projects |
| 15 | Motion-Driven | General | Animation-heavy, microinteractions, smooth transitions, scroll effects, paral... | Portfolio sites, storytelling platforms, interactive experiences, entertainme... | Data dashboards, critical accessibility, low-power devices, content-heavy, mo... |
| 16 | Micro-interactions | General | Small animations, gesture-based, tactile feedback, subtle animations, context... | Mobile apps, touchscreen UIs, productivity tools, user-friendly, consumer app... | Desktop-only, critical performance, accessibility-first (alternatives needed) |
| 17 | Inclusive Design | General | Accessible, color-blind friendly, high contrast, haptic feedback, voice inter... | Public services, education, healthcare, finance, government, accessible consu... | None - accessibility universal |
| 18 | Zero Interface | General | Minimal visible UI, voice-first, gesture-based, AI-driven, invisible controls... | Voice assistants, AI platforms, future-forward UX, smart home, contextual com... | Complex workflows, data-entry heavy, traditional systems, legacy support, exp... |
| 19 | Soft UI Evolution | General | Evolved soft UI, better contrast, modern aesthetics, subtle depth, accessibil... | Modern enterprise apps, SaaS platforms, health/wellness, modern business tool... | Extreme minimalism, critical performance, systems without modern OS |
| 20 | Hero-Centric Design | Landing Page | Large hero section, compelling headline, high-contrast CTA, product showcase,... | SaaS landing pages, product launches, service landing pages, B2B platforms, t... | Complex navigation, multi-page experiences, data-heavy applications |
| 21 | Conversion-Optimized | Landing Page | Form-focused, minimalist design, single CTA focus, high contrast, urgency ele... | E-commerce product pages, free trial signups, lead generation, SaaS pricing p... | Complex feature explanations, multi-product showcases, technical documentation |
| 22 | Feature-Rich Showcase | Landing Page | Multiple feature sections, grid layout, benefit cards, visual feature demonst... | Enterprise SaaS, software tools landing pages, platform services, complex pro... | Simple product pages, early-stage startups with few features, entertainment l... |
| 23 | Minimal & Direct | Landing Page | Minimal text, white space heavy, single column layout, direct messaging, clea... | Simple service landing pages, indie products, consulting services, micro SaaS... | Feature-heavy products, complex explanations, multi-product showcases |
| 24 | Social Proof-Focused | Landing Page | Testimonials prominent, client logos displayed, case studies sections, review... | B2B SaaS, professional services, premium products, e-commerce conversion page... | Startup MVPs, products without users, niche/experimental products |
| 25 | Interactive Product Demo | Landing Page | Embedded product mockup/video, interactive elements, product walkthrough, ste... | SaaS platforms, tool/software products, productivity apps landing pages, deve... | Simple services, consulting, non-digital products, complexity-averse audiences |
| 26 | Trust & Authority | Landing Page | Certificates/badges displayed, expert credentials, case studies with metrics,... | Healthcare/medical landing pages, financial services, enterprise software, pr... | Casual products, entertainment, viral/social-first products |
| 27 | Storytelling-Driven | Landing Page | Narrative flow, visual story progression, section transitions, consistent cha... | Brand/startup stories, mission-driven products, premium/lifestyle brands, doc... | Technical/complex products (unless narrative-driven), traditional enterprise ... |
| 28 | Data-Dense Dashboard | BI/Analytics | Multiple charts/widgets, data tables, KPI cards, minimal padding, grid layout... | Business intelligence dashboards, financial analytics, enterprise reporting, ... | Marketing dashboards, consumer-facing analytics, simple reporting |
| 29 | Heat Map & Heatmap Style | BI/Analytics | Color-coded grid/matrix, data intensity visualization, geographical heat maps... | Geographical analysis, performance matrices, correlation analysis, user behav... | Linear data representation, categorical comparisons (use bar charts), small d... |
| 30 | Executive Dashboard | BI/Analytics | High-level KPIs, large key metrics, minimal detail, summary view, trend indic... | C-suite dashboards, business summary reports, decision-maker dashboards, stra... | Detailed analyst dashboards, technical deep-dives, operational monitoring |
| 31 | Real-Time Monitoring | BI/Analytics | Live data updates, status indicators, alert notifications, streaming data vis... | System monitoring dashboards, DevOps dashboards, real-time analytics, stock m... | Historical analysis, long-term trend reports, archived data dashboards |
| 32 | Drill-Down Analytics | BI/Analytics | Hierarchical data exploration, expandable sections, interactive drill-down pa... | Sales analytics, product analytics, funnel analysis, multi-dimensional data e... | Simple linear data, single-metric dashboards, streaming real-time dashboards |
| 33 | Comparative Analysis Dashboard | BI/Analytics | Side-by-side comparisons, period-over-period metrics, A/B test results, regio... | Period-over-period reporting, A/B test dashboards, market comparison, competi... | Single metric dashboards, future projections (use forecasting), real-time onl... |
| 34 | Predictive Analytics | BI/Analytics | Forecast lines, confidence intervals, trend projections, scenario modeling, A... | Forecasting dashboards, anomaly detection systems, trend prediction dashboard... | Historical-only dashboards, simple reporting, real-time operational dashboards |
| 35 | User Behavior Analytics | BI/Analytics | Funnel visualization, user flow diagrams, conversion tracking, engagement met... | Conversion funnel analysis, user journey tracking, engagement analytics, coho... | Real-time operational metrics, technical system monitoring, financial transac... |
| 36 | Financial Dashboard | BI/Analytics | Revenue metrics, profit/loss visualization, budget tracking, financial ratios... | Financial reporting, accounting dashboards, portfolio tracking, budget monito... | Simple business dashboards, entertainment/social metrics, non-financial data |
| 37 | Sales Intelligence Dashboard | BI/Analytics | Deal pipeline, sales metrics, territory performance, sales rep leaderboard, w... | CRM dashboards, sales management, opportunity tracking, performance managemen... | Marketing analytics, customer support metrics, HR dashboards |
| 38 | Neubrutalism | General | Bold borders, black outlines, primary colors, thick shadows, no gradients, fl... | Gen Z brands, startups, creative agencies, Figma-style apps, Notion-style int... | Luxury brands, finance, healthcare, conservative industries (too playful) |
| 39 | Bento Box Grid | General | Modular cards, asymmetric grid, varied sizes, Apple-style, dashboard tiles, n... | Dashboards, product pages, portfolios, Apple-style marketing, feature showcas... | Dense data tables, text-heavy content, real-time monitoring |
| 40 | Y2K Aesthetic | General | Neon pink, chrome, metallic, bubblegum, iridescent, glossy, retro-futurism, 2... | Fashion brands, music platforms, Gen Z brands, nostalgia marketing, entertain... | B2B enterprise, healthcare, finance, conservative industries, elderly users |
| 41 | Cyberpunk UI | General | Neon, dark mode, terminal, HUD, sci-fi, glitch, dystopian, futuristic, matrix... | Gaming platforms, tech products, crypto apps, sci-fi applications, developer ... | Corporate enterprise, healthcare, family apps, conservative brands, elderly u... |
| 42 | Organic Biophilic | General | Nature, organic shapes, green, sustainable, rounded, flowing, wellness, earth... | Wellness apps, sustainability brands, eco products, health apps, meditation, ... | Tech-focused products, gaming, industrial, urban brands |
| 43 | AI-Native UI | General | Chatbot, conversational, voice, assistant, agentic, ambient, minimal chrome, ... | AI products, chatbots, voice assistants, copilots, AI-powered tools, conversa... | Traditional forms, data-heavy dashboards, print-first content |
| 44 | Memphis Design | General | 80s, geometric, playful, postmodern, shapes, patterns, squiggles, triangles, ... | Creative agencies, music sites, youth brands, event promotion, artistic portf... | Corporate finance, healthcare, legal, elderly users, conservative brands |
| 45 | Vaporwave | General | Synthwave, retro-futuristic, 80s-90s, neon, glitch, nostalgic, sunset gradien... | Music platforms, gaming, creative portfolios, tech startups, entertainment, a... | Business apps, e-commerce, education, healthcare, enterprise software |
| 46 | Dimensional Layering | General | Depth, overlapping, z-index, layers, 3D, shadows, elevation, floating, cards,... | Dashboards, card layouts, modals, navigation, product showcases, SaaS interfaces | Print-style layouts, simple blogs, low-end devices, flat design requirements |
| 47 | Exaggerated Minimalism | General | Bold minimalism, oversized typography, high contrast, negative space, loud mi... | Fashion, architecture, portfolios, agency landing pages, luxury brands, edito... | E-commerce catalogs, dashboards, forms, data-heavy, elderly users, complex apps |
| 48 | Kinetic Typography | General | Motion text, animated type, moving letters, dynamic, typing effect, morphing,... | Hero sections, marketing sites, video platforms, storytelling, creative portf... | Long-form content, accessibility-critical, data interfaces, forms, elderly users |
| 49 | Parallax Storytelling | General | Scroll-driven, narrative, layered scrolling, immersive, progressive disclosur... | Brand storytelling, product launches, case studies, portfolios, annual report... | E-commerce, dashboards, mobile-first, SEO-critical, accessibility-required |
| 50 | Swiss Modernism 2.0 | General | Grid system, Helvetica, modular, asymmetric, international style, rational, c... | Corporate sites, architecture, editorial, SaaS, museums, professional service... | Playful brands, children's sites, entertainment, gaming, emotional storytelling |
| 51 | HUD / Sci-Fi FUI | General | Futuristic, technical, wireframe, neon, data, transparency, iron man, sci-fi,... | Sci-fi games, space tech, cybersecurity, movie props, immersive dashboards | Standard corporate, reading heavy content, accessible public services |
| 52 | Pixel Art | General | Retro, 8-bit, 16-bit, gaming, blocky, nostalgic, pixelated, arcade | Indie games, retro tools, creative portfolios, nostalgia marketing, Web3/NFT | Professional corporate, modern SaaS, high-res photography sites |
| 53 | Bento Grids | General | Apple-style, modular, cards, organized, clean, hierarchy, grid, rounded, soft | Product features, dashboards, personal sites, marketing summaries, galleries | Long-form reading, data tables, complex forms |
| 55 | Spatial UI (VisionOS) | General | Glass, depth, immersion, spatial, translucent, gaze, gesture, apple, vision-pro | Spatial computing apps, VR/AR interfaces, immersive media, futuristic dashboards | Text-heavy documents, high-contrast requirements, non-3D capable devices |
| 56 | E-Ink / Paper | General | Paper-like, matte, high contrast, texture, reading, calm, slow tech, monochrome | Reading apps, digital newspapers, minimal journals, distraction-free writing,... | Gaming, video platforms, high-energy marketing, dark mode dependent apps |
| 57 | Gen Z Chaos / Maximalism | General | Chaos, clutter, stickers, raw, collage, mixed media, loud, internet culture, ... | Gen Z lifestyle brands, music artists, creative portfolios, viral marketing, ... | Corporate, government, healthcare, banking, serious tools |
| 58 | Biomimetic / Organic 2.0 | General | Nature-inspired, cellular, fluid, breathing, generative, algorithms, life-like | Sustainability tech, biotech, advanced health, meditation, generative art pla... | Standard SaaS, data grids, strict corporate, accounting |
| 59 | Anti-Polish / Raw Aesthetic | General | Hand-drawn, collage, scanned textures, unfinished, imperfect, authentic, huma... | Creative portfolios, artist sites, indie brands, handmade products, authentic... | Corporate enterprise, fintech, healthcare, government, polished SaaS |
| 60 | Tactile Digital / Deformable UI | General | Jelly buttons, chrome, clay, squishy, deformable, bouncy, physical, tactile f... | Modern mobile apps, playful brands, entertainment, gaming UI, consumer produc... | Enterprise software, data dashboards, accessibility-critical, professional tools |
| 61 | Nature Distilled | General | Muted earthy, skin tones, wood, soil, sand, terracotta, warmth, organic mater... | Wellness brands, sustainable products, artisan goods, organic food, spa/beaut... | Tech startups, gaming, nightlife, corporate finance, high-energy brands |
| 62 | Interactive Cursor Design | General | Custom cursor, cursor as tool, hover effects, cursor feedback, pointer transf... | Creative portfolios, interactive experiences, agency sites, product showcases... | Mobile-first (no cursor), accessibility-critical, data-heavy dashboards, forms |
| 63 | Voice-First Multimodal | General | Voice UI, multimodal, audio feedback, conversational, hands-free, ambient, co... | Voice assistants, accessibility apps, hands-free tools, smart home, automotiv... | Visual-heavy content, data entry, complex forms, noisy environments |
| 64 | 3D Product Preview | General | 360 product view, rotatable, zoomable, touch-to-spin, AR preview, product con... | E-commerce, furniture, fashion, automotive, electronics, jewelry, product con... | Content-heavy sites, blogs, dashboards, low-bandwidth, accessibility-critical |
| 65 | Gradient Mesh / Aurora Evolved | General | Complex gradients, mesh gradients, multi-color blend, aurora effect, flowing ... | Hero sections, backgrounds, creative brands, music platforms, fashion, lifest... | Data interfaces, text-heavy content, accessibility-critical, conservative brands |
| 66 | Editorial Grid / Magazine | General | Magazine layout, asymmetric grid, editorial typography, pull quotes, drop cap... | News sites, blogs, magazines, editorial content, long-form articles, journali... | Dashboards, apps, e-commerce catalogs, real-time data, short-form content |
| 67 | Chromatic Aberration / RGB Split | General | RGB split, color fringing, glitch, retro tech, VHS, analog error, distortion,... | Music platforms, gaming, tech brands, creative portfolios, nightlife, enterta... | Corporate, healthcare, finance, accessibility-critical, elderly users |
| 68 | Vintage Analog / Retro Film | General | Film grain, VHS, cassette tape, polaroid, analog warmth, faded colors, light ... | Photography portfolios, music/vinyl brands, vintage fashion, nostalgia market... | Modern tech, SaaS, healthcare, children's apps, corporate enterprise |
| 69 | Bauhaus (包豪斯) | Mobile | bauhaus, geometric, constructivist, primary colors, hard shadow, bold, tactil... | Mobile-first apps needing high personality, onboarding flows, branding-forwar... | Enterprise dashboards, accessibility-critical contexts (requires extra a11y w... |
| 70 | Minimalist Monochrome | Mobile | monochrome, black white, editorial, austere, typographic, sharp, zero radius,... | Luxury fashion e-commerce mobile, editorial publications, high-end portfolio ... | Entertainment, colorful brands, friendly consumer apps, anything requiring vi... |
| 71 | Modern Dark (Cinema Mobile) | Mobile | dark mode, cinematic, ambient light, glassmorphism, deep black, indigo, glow,... | Developer tools, pro productivity apps, fintech/trading dashboards, media/str... | Consumer apps needing warmth, children's apps, health/medical contexts where ... |
| 72 | SaaS Mobile (High-Tech Boutique) | Mobile | saas, electric blue, gradient, fintech, spring animation, dual font, glassmor... | B2B SaaS mobile dashboards, fintech apps, developer tool mobile companions, m... | Pure consumer entertainment, children's apps, highly decorative lifestyle app... |
| 73 | Terminal CLI (Mobile) | Mobile | terminal, cli, matrix green, monospace, hacker, ascii, command line, develope... | Developer tools, Web3/blockchain apps, geek-culture apps, ARG games, sci-fi/n... | Consumer products, health apps, anything requiring approachability or warmth,... |
| 74 | Kinetic Brutalism (Mobile) | Mobile | kinetic, brutalism, motion, marquee, acid yellow, uppercase, oversized, aggre... | Immersive storytelling apps, brand flagship mobile, music/culture platforms, ... | Calm informational apps, healthcare, finance contexts needing trust, children... |
| 75 | Flat Design Mobile (Touch-First) | Mobile | flat, 2D, no shadow, color blocking, geometric, bold, poster, icon, touch-fir... | Cross-platform apps (iOS+Android parity), information-dense dashboards, syste... | Ultra-premium contexts needing depth/shadow, dark-mode-first products, contex... |
| 76 | Material You (MD3 Mobile) | Mobile | material design 3, md3, tonal surfaces, pills, soft curves, android, md3 easi... | Android ecosystem apps, cross-platform productivity tools, MD3-based admin pa... | Ultra-minimal brutalist brands, terminal/hacker aesthetics, monochrome editor... |
| 77 | Neo Brutalism (Mobile) | Mobile | neo brutalism, pop art, stickers, thick borders, cream background, hot red, v... | Creative tools, collab platforms, Gen Z marketing & e-commerce, portfolio sit... | Serious enterprise apps, conservative industries, sober fintech, accessibilit... |
| 78 | Bold Typography (Mobile Poster) | Mobile | bold typography, editorial, poster, broadsheet, vermillion, negative space, e... | Creative brand heroes, reading-focused apps, event/exhibition pages, editoria... | Utility dashboards, kids apps, playful consumer products, contexts needing ma... |
| 79 | Academia (Scholarly Mobile) | Mobile | academia, library, mahogany, parchment, brass, crimson, serif, drop cap, arch... | Knowledge management apps, deep reading tools, ritual-heavy personal brands, ... | Hyper-modern tech dashboards, neon/glassmorphism, playful Gen Z branding |
| 80 | Cyberpunk Mobile HUD | Mobile | cyberpunk, neon, glitch, chamfered, orbitron, jetbrains, scanlines, crt, hud,... | Gaming dashboards, crypto/cyberpunk apps, sci-fi companion tools, hacker OS s... | Serious enterprise, health/finance requiring calm trust, minimal editorial apps |
| 81 | Bitcoin DeFi (Mobile) | Mobile | web3, bitcoin, defi, digital gold, fintech, wallet, orange, glassmorphism, gr... | DeFi dashboards, wallets, NFT marketplaces, Web3 social, metaverse utilities,... | Playful casual apps, low-tech brands, ultra-minimal editorial apps |
| 82 | Claymorphism (Mobile) | Mobile | claymorphism, clay, 3d, soft, bubbly, candy, playful, rounded, squish, tactil... | Children education apps, teen social products, crypto gamification, creative ... | Serious enterprise, high-density data, editorial reading apps, fintech trust ... |
| 83 | Enterprise SaaS (Mobile) | Mobile | enterprise, saas, b2b, professional, indigo, violet, gradient, polished, trus... | B2B backend management, productivity tools, government and finance mobile app... | Pure consumer entertainment, Gen-Z youth apps, gaming UI, ultra-minimal edito... |
| 84 | Sketch Hand-Drawn (Mobile) | Mobile | sketch, hand-drawn, handwriting, wobbly, imperfect, paper, kalam, organic, co... | Low-fidelity prototyping, creative brands, children/picturebook apps, educati... | Enterprise dashboards, high-density data tables, fintech precision tools, med... |
| 85 | Neumorphism (Mobile) | Mobile | neumorphism, soft ui, dual shadow, extruded, inset, clay surface, monochromat... | Minimal hardware controls, smart home apps, aesthetic utility tools, health m... | High-density data, bright multi-color apps, apps needing strong visual hierar... |

---


## 配色方案数据库（161 套）

| 产品类型 | Primary | Secondary | Accent | Background | Foreground | Card |
|----------|---------|-----------|--------|------------|------------|------|
| SaaS (General) | #2563EB | #3B82F6 | #EA580C | #F8FAFC | #1E293B | #FFFFFF |
| Micro SaaS | #6366F1 | #818CF8 | #059669 | #F5F3FF | #1E1B4B | #FFFFFF |
| E-commerce | #059669 | #10B981 | #EA580C | #ECFDF5 | #064E3B | #FFFFFF |
| E-commerce Luxury | #1C1917 | #44403C | #A16207 | #FAFAF9 | #0C0A09 | #FFFFFF |
| B2B Service | #0F172A | #334155 | #0369A1 | #F8FAFC | #020617 | #FFFFFF |
| Financial Dashboard | #0F172A | #1E293B | #22C55E | #020617 | #F8FAFC | #0E1223 |
| Analytics Dashboard | #1E40AF | #3B82F6 | #D97706 | #F8FAFC | #1E3A8A | #FFFFFF |
| Healthcare App | #0891B2 | #22D3EE | #059669 | #ECFEFF | #164E63 | #FFFFFF |
| Educational App | #4F46E5 | #818CF8 | #EA580C | #EEF2FF | #1E1B4B | #FFFFFF |
| Creative Agency | #EC4899 | #F472B6 | #0891B2 | #FDF2F8 | #831843 | #FFFFFF |
| Portfolio/Personal | #18181B | #3F3F46 | #2563EB | #FAFAFA | #09090B | #FFFFFF |
| Gaming | #7C3AED | #A78BFA | #F43F5E | #0F0F23 | #E2E8F0 | #1E1C35 |
| Government/Public Service | #0F172A | #334155 | #0369A1 | #F8FAFC | #020617 | #FFFFFF |
| Fintech/Crypto | #F59E0B | #FBBF24 | #8B5CF6 | #0F172A | #F8FAFC | #222735 |
| Social Media App | #E11D48 | #FB7185 | #2563EB | #FFF1F2 | #881337 | #FFFFFF |
| Productivity Tool | #0D9488 | #14B8A6 | #EA580C | #F0FDFA | #134E4A | #FFFFFF |
| Design System/Component Library | #4F46E5 | #6366F1 | #EA580C | #EEF2FF | #312E81 | #FFFFFF |
| AI/Chatbot Platform | #7C3AED | #A78BFA | #0891B2 | #FAF5FF | #1E1B4B | #FFFFFF |
| NFT/Web3 Platform | #8B5CF6 | #A78BFA | #FBBF24 | #0F0F23 | #F8FAFC | #1E1D35 |
| Creator Economy Platform | #EC4899 | #F472B6 | #EA580C | #FDF2F8 | #831843 | #FFFFFF |
| Remote Work/Collaboration Tool | #6366F1 | #818CF8 | #059669 | #F5F3FF | #312E81 | #FFFFFF |
| Mental Health App | #8B5CF6 | #C4B5FD | #059669 | #FAF5FF | #4C1D95 | #FFFFFF |
| Pet Tech App | #F97316 | #FB923C | #2563EB | #FFF7ED | #9A3412 | #FFFFFF |
| Smart Home/IoT Dashboard | #1E293B | #334155 | #22C55E | #0F172A | #F8FAFC | #1B2336 |
| EV/Charging Ecosystem | #0891B2 | #22D3EE | #16A34A | #ECFEFF | #164E63 | #FFFFFF |
| Subscription Box Service | #D946EF | #E879F9 | #EA580C | #FDF4FF | #86198F | #FFFFFF |
| Podcast Platform | #1E1B4B | #312E81 | #F97316 | #0F0F23 | #F8FAFC | #1B1B30 |
| Dating App | #E11D48 | #FB7185 | #EA580C | #FFF1F2 | #881337 | #FFFFFF |
| Micro-Credentials/Badges Platform | #0369A1 | #0EA5E9 | #A16207 | #F0F9FF | #0C4A6E | #FFFFFF |
| Knowledge Base/Documentation | #475569 | #64748B | #2563EB | #F8FAFC | #1E293B | #FFFFFF |
| Hyperlocal Services | #059669 | #10B981 | #EA580C | #ECFDF5 | #064E3B | #FFFFFF |
| Beauty/Spa/Wellness Service | #EC4899 | #F9A8D4 | #8B5CF6 | #FDF2F8 | #831843 | #FFFFFF |
| Luxury/Premium Brand | #1C1917 | #44403C | #A16207 | #FAFAF9 | #0C0A09 | #FFFFFF |
| Restaurant/Food Service | #DC2626 | #F87171 | #A16207 | #FEF2F2 | #450A0A | #FFFFFF |
| Fitness/Gym App | #F97316 | #FB923C | #22C55E | #1F2937 | #F8FAFC | #313742 |
| Real Estate/Property | #0F766E | #14B8A6 | #0369A1 | #F0FDFA | #134E4A | #FFFFFF |
| Travel/Tourism Agency | #0EA5E9 | #38BDF8 | #EA580C | #F0F9FF | #0C4A6E | #FFFFFF |
| Hotel/Hospitality | #1E3A8A | #3B82F6 | #A16207 | #F8FAFC | #1E40AF | #FFFFFF |
| Wedding/Event Planning | #DB2777 | #F472B6 | #A16207 | #FDF2F8 | #831843 | #FFFFFF |
| Legal Services | #1E3A8A | #1E40AF | #B45309 | #F8FAFC | #0F172A | #FFFFFF |
| Insurance Platform | #0369A1 | #0EA5E9 | #16A34A | #F0F9FF | #0C4A6E | #FFFFFF |
| Banking/Traditional Finance | #0F172A | #1E3A8A | #A16207 | #F8FAFC | #020617 | #FFFFFF |
| Online Course/E-learning | #0D9488 | #2DD4BF | #EA580C | #F0FDFA | #134E4A | #FFFFFF |
| Non-profit/Charity | #0891B2 | #22D3EE | #EA580C | #ECFEFF | #164E63 | #FFFFFF |
| Music Streaming | #1E1B4B | #4338CA | #22C55E | #0F0F23 | #F8FAFC | #1B1B30 |
| Video Streaming/OTT | #0F0F23 | #1E1B4B | #E11D48 | #000000 | #F8FAFC | #0C0C0D |
| Job Board/Recruitment | #0369A1 | #0EA5E9 | #16A34A | #F0F9FF | #0C4A6E | #FFFFFF |
| Marketplace (P2P) | #7C3AED | #A78BFA | #16A34A | #FAF5FF | #4C1D95 | #FFFFFF |
| Logistics/Delivery | #2563EB | #3B82F6 | #EA580C | #EFF6FF | #1E40AF | #FFFFFF |
| Agriculture/Farm Tech | #15803D | #22C55E | #A16207 | #F0FDF4 | #14532D | #FFFFFF |
| Construction/Architecture | #64748B | #94A3B8 | #EA580C | #F8FAFC | #334155 | #FFFFFF |
| Automotive/Car Dealership | #1E293B | #334155 | #DC2626 | #F8FAFC | #0F172A | #FFFFFF |
| Photography Studio | #18181B | #27272A | #F8FAFC | #000000 | #FAFAFA | #0C0C0C |
| Coworking Space | #F59E0B | #FBBF24 | #2563EB | #FFFBEB | #78350F | #FFFFFF |
| Home Services (Plumber/Electrician) | #1E40AF | #3B82F6 | #EA580C | #EFF6FF | #1E3A8A | #FFFFFF |
| Childcare/Daycare | #F472B6 | #FBCFE8 | #16A34A | #FDF2F8 | #9D174D | #FFFFFF |
| Senior Care/Elderly | #0369A1 | #38BDF8 | #16A34A | #F0F9FF | #0C4A6E | #FFFFFF |
| Medical Clinic | #0891B2 | #22D3EE | #16A34A | #F0FDFA | #134E4A | #FFFFFF |
| Pharmacy/Drug Store | #15803D | #22C55E | #0369A1 | #F0FDF4 | #14532D | #FFFFFF |
| Dental Practice | #0EA5E9 | #38BDF8 | #0EA5E9 | #F0F9FF | #0C4A6E | #FFFFFF |
| Veterinary Clinic | #0D9488 | #14B8A6 | #EA580C | #F0FDFA | #134E4A | #FFFFFF |
| Florist/Plant Shop | #15803D | #22C55E | #EC4899 | #F0FDF4 | #14532D | #FFFFFF |
| Bakery/Cafe | #92400E | #B45309 | #92400E | #FEF3C7 | #78350F | #FFFFFF |
| Brewery/Winery | #7C2D12 | #B91C1C | #A16207 | #FEF2F2 | #450A0A | #FFFFFF |
| Airline | #1E3A8A | #3B82F6 | #EA580C | #EFF6FF | #1E40AF | #FFFFFF |
| News/Media Platform | #DC2626 | #EF4444 | #1E40AF | #FEF2F2 | #450A0A | #FFFFFF |
| Magazine/Blog | #18181B | #3F3F46 | #EC4899 | #FAFAFA | #09090B | #FFFFFF |
| Freelancer Platform | #6366F1 | #818CF8 | #16A34A | #EEF2FF | #312E81 | #FFFFFF |
| Marketing Agency | #EC4899 | #F472B6 | #0891B2 | #FDF2F8 | #831843 | #FFFFFF |
| Event Management | #7C3AED | #A78BFA | #EA580C | #FAF5FF | #4C1D95 | #FFFFFF |
| Membership/Community | #7C3AED | #A78BFA | #16A34A | #FAF5FF | #4C1D95 | #FFFFFF |
| Newsletter Platform | #0369A1 | #0EA5E9 | #EA580C | #F0F9FF | #0C4A6E | #FFFFFF |
| Digital Products/Downloads | #6366F1 | #818CF8 | #16A34A | #EEF2FF | #312E81 | #FFFFFF |
| Church/Religious Organization | #7C3AED | #A78BFA | #A16207 | #FAF5FF | #4C1D95 | #FFFFFF |
| Sports Team/Club | #DC2626 | #EF4444 | #DC2626 | #FEF2F2 | #7F1D1D | #FFFFFF |
| Museum/Gallery | #18181B | #27272A | #18181B | #FAFAFA | #09090B | #FFFFFF |
| Theater/Cinema | #1E1B4B | #312E81 | #CA8A04 | #0F0F23 | #F8FAFC | #1B1B30 |
| Language Learning App | #4F46E5 | #818CF8 | #16A34A | #EEF2FF | #312E81 | #FFFFFF |
| Coding Bootcamp | #0F172A | #1E293B | #22C55E | #020617 | #F8FAFC | #0E1223 |
| Cybersecurity Platform | #00FF41 | #0D0D0D | #FF3333 | #000000 | #E0E0E0 | #0C130E |
| Developer Tool / IDE | #1E293B | #334155 | #22C55E | #0F172A | #F8FAFC | #1B2336 |
| Biotech / Life Sciences | #0EA5E9 | #0284C7 | #059669 | #F0F9FF | #0C4A6E | #FFFFFF |
| Space Tech / Aerospace | #F8FAFC | #94A3B8 | #3B82F6 | #0B0B10 | #F8FAFC | #1E1E23 |
| Architecture / Interior | #171717 | #404040 | #A16207 | #FFFFFF | #171717 | #FFFFFF |
| Quantum Computing Interface | #00FFFF | #7B61FF | #FF00FF | #050510 | #E0E0FF | #101823 |
| Biohacking / Longevity App | #FF4D4D | #4D94FF | #059669 | #F5F5F7 | #1C1C1E | #FFFFFF |
| Autonomous Drone Fleet Manager | #00FF41 | #008F11 | #FF3333 | #0D1117 | #E6EDF3 | #182424 |
| Generative Art Platform | #18181B | #3F3F46 | #EC4899 | #FAFAFA | #09090B | #FFFFFF |
| Spatial Computing OS / App | #FFFFFF | #E5E5E5 | #FFFFFF | #888888 | #000000 | #999999 |
| Sustainable Energy / Climate Tech | #059669 | #10B981 | #059669 | #ECFDF5 | #064E3B | #FFFFFF |
| Personal Finance Tracker | #1E40AF | #3B82F6 | #059669 | #0F172A | #FFFFFF | #192134 |
| Chat & Messaging App | #2563EB | #6366F1 | #059669 | #FFFFFF | #0F172A | #FFFFFF |
| Notes & Writing App | #78716C | #A8A29E | #D97706 | #FFFBEB | #0F172A | #FFFFFF |
| Habit Tracker | #D97706 | #F59E0B | #059669 | #FFFBEB | #0F172A | #FFFFFF |
| Food Delivery / On-Demand | #EA580C | #F97316 | #2563EB | #FFF7ED | #0F172A | #FFFFFF |
| Ride Hailing / Transportation | #1E293B | #334155 | #2563EB | #0F172A | #FFFFFF | #192134 |
| Recipe & Cooking App | #9A3412 | #C2410C | #059669 | #FFFBEB | #0F172A | #FFFFFF |
| Meditation & Mindfulness | #7C3AED | #8B5CF6 | #059669 | #FAF5FF | #0F172A | #FFFFFF |
| Weather App | #0284C7 | #0EA5E9 | #F59E0B | #F0F9FF | #0F172A | #FFFFFF |
| Diary & Journal App | #92400E | #A16207 | #6366F1 | #FFFBEB | #0F172A | #FFFFFF |
| CRM & Client Management | #2563EB | #3B82F6 | #059669 | #F8FAFC | #0F172A | #FFFFFF |
| Inventory & Stock Management | #334155 | #475569 | #059669 | #F8FAFC | #0F172A | #FFFFFF |
| Flashcard & Study Tool | #7C3AED | #8B5CF6 | #059669 | #FAF5FF | #0F172A | #FFFFFF |
| Booking & Appointment App | #0284C7 | #0EA5E9 | #059669 | #F0F9FF | #0F172A | #FFFFFF |
| Invoice & Billing Tool | #1E3A5F | #2563EB | #059669 | #F8FAFC | #0F172A | #FFFFFF |
| Grocery & Shopping List | #059669 | #10B981 | #D97706 | #ECFDF5 | #0F172A | #FFFFFF |
| Timer & Pomodoro | #DC2626 | #EF4444 | #059669 | #0F172A | #FFFFFF | #192134 |
| Parenting & Baby Tracker | #EC4899 | #F472B6 | #0284C7 | #FDF2F8 | #0F172A | #FFFFFF |
| Scanner & Document Manager | #1E293B | #334155 | #2563EB | #F8FAFC | #0F172A | #FFFFFF |
| Calendar & Scheduling App | #2563EB | #3B82F6 | #059669 | #F8FAFC | #0F172A | #FFFFFF |
| Password Manager | #1E3A5F | #334155 | #059669 | #0F172A | #FFFFFF | #192134 |
| Expense Splitter / Bill Split | #059669 | #10B981 | #DC2626 | #F8FAFC | #0F172A | #FFFFFF |
| Voice Recorder & Memo | #DC2626 | #EF4444 | #2563EB | #FFFFFF | #0F172A | #FFFFFF |
| Bookmark & Read-Later | #D97706 | #F59E0B | #2563EB | #FFFBEB | #0F172A | #FFFFFF |
| Translator App | #2563EB | #0891B2 | #EA580C | #F8FAFC | #0F172A | #FFFFFF |
| Calculator & Unit Converter | #EA580C | #F97316 | #2563EB | #1C1917 | #FFFFFF | #262321 |
| Alarm & World Clock | #D97706 | #F59E0B | #6366F1 | #0F172A | #FFFFFF | #192134 |
| File Manager & Transfer | #2563EB | #3B82F6 | #D97706 | #F8FAFC | #0F172A | #FFFFFF |
| Email Client | #2563EB | #3B82F6 | #DC2626 | #FFFFFF | #0F172A | #FFFFFF |
| Casual Puzzle Game | #EC4899 | #8B5CF6 | #F59E0B | #FDF2F8 | #0F172A | #FFFFFF |
| Trivia & Quiz Game | #2563EB | #7C3AED | #F59E0B | #EFF6FF | #0F172A | #FFFFFF |
| Card & Board Game | #15803D | #166534 | #D97706 | #0F172A | #FFFFFF | #192134 |
| Idle & Clicker Game | #D97706 | #F59E0B | #7C3AED | #FFFBEB | #0F172A | #FFFFFF |
| Word & Crossword Game | #15803D | #059669 | #D97706 | #FFFFFF | #0F172A | #FFFFFF |
| Arcade & Retro Game | #DC2626 | #2563EB | #22C55E | #0F172A | #FFFFFF | #192134 |
| Photo Editor & Filters | #7C3AED | #6366F1 | #0891B2 | #0F172A | #FFFFFF | #192134 |
| Short Video Editor | #EC4899 | #DB2777 | #2563EB | #0F172A | #FFFFFF | #192134 |
| Drawing & Sketching Canvas | #7C3AED | #8B5CF6 | #0891B2 | #1C1917 | #FFFFFF | #262321 |
| Music Creation & Beat Maker | #7C3AED | #6366F1 | #22C55E | #0F172A | #FFFFFF | #192134 |
| Meme & Sticker Maker | #EC4899 | #F59E0B | #2563EB | #FFFFFF | #0F172A | #FFFFFF |
| AI Photo & Avatar Generator | #7C3AED | #6366F1 | #EC4899 | #FAF5FF | #0F172A | #FFFFFF |
| Link-in-Bio Page Builder | #2563EB | #7C3AED | #EC4899 | #FFFFFF | #0F172A | #FFFFFF |
| Wardrobe & Outfit Planner | #BE185D | #EC4899 | #D97706 | #FDF2F8 | #0F172A | #FFFFFF |
| Plant Care Tracker | #15803D | #059669 | #D97706 | #F0FDF4 | #0F172A | #FFFFFF |
| Book & Reading Tracker | #78716C | #92400E | #D97706 | #FFFBEB | #0F172A | #FFFFFF |
| Couple & Relationship App | #BE185D | #EC4899 | #DC2626 | #FDF2F8 | #0F172A | #FFFFFF |
| Family Calendar & Chores | #2563EB | #059669 | #D97706 | #F8FAFC | #0F172A | #FFFFFF |
| Mood Tracker | #7C3AED | #6366F1 | #D97706 | #FAF5FF | #0F172A | #FFFFFF |
| Gift & Wishlist | #DC2626 | #D97706 | #EC4899 | #FFF1F2 | #0F172A | #FFFFFF |
| Running & Cycling GPS | #EA580C | #F97316 | #059669 | #0F172A | #FFFFFF | #192134 |
| Yoga & Stretching Guide | #6B7280 | #78716C | #0891B2 | #F5F5F0 | #0F172A | #FFFFFF |
| Sleep Tracker | #4338CA | #6366F1 | #7C3AED | #0F172A | #FFFFFF | #192134 |
| Calorie & Nutrition Counter | #059669 | #10B981 | #EA580C | #ECFDF5 | #0F172A | #FFFFFF |
| Period & Cycle Tracker | #BE185D | #EC4899 | #7C3AED | #FDF2F8 | #0F172A | #FFFFFF |
| Medication & Pill Reminder | #0284C7 | #0891B2 | #DC2626 | #F0F9FF | #0F172A | #FFFFFF |
| Water & Hydration Reminder | #0284C7 | #06B6D4 | #0891B2 | #F0F9FF | #0F172A | #FFFFFF |
| Fasting & Intermittent Timer | #6366F1 | #4338CA | #059669 | #0F172A | #FFFFFF | #192134 |
| Anonymous Community / Confession | #475569 | #334155 | #0891B2 | #0F172A | #FFFFFF | #192134 |
| Local Events & Discovery | #EA580C | #F97316 | #2563EB | #FFF7ED | #0F172A | #FFFFFF |
| Study Together / Virtual Coworking | #2563EB | #3B82F6 | #059669 | #F8FAFC | #0F172A | #FFFFFF |
| Coding Challenge & Practice | #22C55E | #059669 | #D97706 | #0F172A | #FFFFFF | #192134 |
| Kids Learning (ABC & Math) | #2563EB | #F59E0B | #EC4899 | #EFF6FF | #0F172A | #FFFFFF |
| Music Instrument Learning | #DC2626 | #9A3412 | #D97706 | #FFFBEB | #0F172A | #FFFFFF |
| Parking Finder | #2563EB | #059669 | #DC2626 | #F0F9FF | #0F172A | #FFFFFF |
| Public Transit Guide | #2563EB | #0891B2 | #EA580C | #F8FAFC | #0F172A | #FFFFFF |
| Road Trip Planner | #EA580C | #0891B2 | #D97706 | #FFF7ED | #0F172A | #FFFFFF |
| VPN & Privacy Tool | #1E3A5F | #334155 | #22C55E | #0F172A | #FFFFFF | #192134 |
| Emergency SOS & Safety | #DC2626 | #EF4444 | #2563EB | #FFF1F2 | #0F172A | #FFFFFF |
| Wallpaper & Theme App | #7C3AED | #EC4899 | #2563EB | #FAF5FF | #0F172A | #FFFFFF |
| White Noise & Ambient Sound | #475569 | #334155 | #4338CA | #0F172A | #FFFFFF | #192134 |
| Home Decoration & Interior Design | #78716C | #A8A29E | #D97706 | #FAF5F2 | #0F172A | #FFFFFF |

---


## 字体搭配数据库（57 套）

| # | 搭配名称 | 标题字体 | 正文字体 | 情绪关键词 | 适用场景 | Google Fonts URL |
|---|----------|----------|----------|------------|----------|-----------------|
| 1 | Classic Elegant | Playfair Display | Inter | elegant, luxury, sophisticated, timeless, premium, editorial | Luxury brands, fashion, spa, beauty, editorial, magazines, high-end... | https://fonts.google.com/share?selection.family=Inter:wght@300;400;500;600;700/Playfair+Display:wght@400;500;600;700 |
| 2 | Modern Professional | Poppins | Open Sans | modern, professional, clean, corporate, friendly, approac... | SaaS, corporate sites, business apps, startups, professional services | https://fonts.google.com/share?selection.family=Open+Sans:wght@300;400;500;600;700/Poppins:wght@400;500;600;700 |
| 3 | Tech Startup | Space Grotesk | DM Sans | tech, startup, modern, innovative, bold, futuristic | Tech companies, startups, SaaS, developer tools, AI products | https://fonts.google.com/share?selection.family=DM+Sans:wght@400;500;700/Space+Grotesk:wght@400;500;600;700 |
| 4 | Editorial Classic | Cormorant Garamond | Libre Baskerville | editorial, classic, literary, traditional, refined, bookish | Publishing, blogs, news sites, literary magazines, book covers | https://fonts.google.com/share?selection.family=Cormorant+Garamond:wght@400;500;600;700/Libre+Baskerville:wght@400;700 |
| 5 | Minimal Swiss | Inter | Inter | minimal, clean, swiss, functional, neutral, professional | Dashboards, admin panels, documentation, enterprise apps, design sy... | https://fonts.google.com/share?selection.family=Inter:wght@300;400;500;600;700 |
| 6 | Playful Creative | Fredoka | Nunito | playful, friendly, fun, creative, warm, approachable | Children's apps, educational, gaming, creative tools, entertainment | https://fonts.google.com/share?selection.family=Fredoka:wght@400;500;600;700/Nunito:wght@300;400;500;600;700 |
| 7 | Bold Statement | Bebas Neue | Source Sans 3 | bold, impactful, strong, dramatic, modern, headlines | Marketing sites, portfolios, agencies, event pages, sports | https://fonts.google.com/share?selection.family=Bebas+Neue/Source+Sans+3:wght@300;400;500;600;700 |
| 8 | Wellness Calm | Lora | Raleway | calm, wellness, health, relaxing, natural, organic | Health apps, wellness, spa, meditation, yoga, organic brands | https://fonts.google.com/share?selection.family=Lora:wght@400;500;600;700/Raleway:wght@300;400;500;600;700 |
| 9 | Developer Mono | JetBrains Mono | IBM Plex Sans | code, developer, technical, precise, functional, hacker | Developer tools, documentation, code editors, tech blogs, CLI apps | https://fonts.google.com/share?selection.family=IBM+Plex+Sans:wght@300;400;500;600;700/JetBrains+Mono:wght@400;500;600;700 |
| 10 | Retro Vintage | Abril Fatface | Merriweather | retro, vintage, nostalgic, dramatic, decorative, bold | Vintage brands, breweries, restaurants, creative portfolios, posters | https://fonts.google.com/share?selection.family=Abril+Fatface/Merriweather:wght@300;400;700 |
| 11 | Geometric Modern | Outfit | Work Sans | geometric, modern, clean, balanced, contemporary, versatile | General purpose, portfolios, agencies, modern brands, landing pages | https://fonts.google.com/share?selection.family=Outfit:wght@300;400;500;600;700/Work+Sans:wght@300;400;500;600;700 |
| 12 | Luxury Serif | Cormorant | Montserrat | luxury, high-end, fashion, elegant, refined, premium | Fashion brands, luxury e-commerce, jewelry, high-end services | https://fonts.google.com/share?selection.family=Cormorant:wght@400;500;600;700/Montserrat:wght@300;400;500;600;700 |
| 13 | Friendly SaaS | Plus Jakarta Sans | Plus Jakarta Sans | friendly, modern, saas, clean, approachable, professional | SaaS products, web apps, dashboards, B2B, productivity tools | https://fonts.google.com/share?selection.family=Plus+Jakarta+Sans:wght@300;400;500;600;700 |
| 14 | News Editorial | Newsreader | Roboto | news, editorial, journalism, trustworthy, readable, infor... | News sites, blogs, magazines, journalism, content-heavy sites | https://fonts.google.com/share?selection.family=Newsreader:wght@400;500;600;700/Roboto:wght@300;400;500;700 |
| 15 | Handwritten Charm | Caveat | Quicksand | handwritten, personal, friendly, casual, warm, charming | Personal blogs, invitations, creative portfolios, lifestyle brands | https://fonts.google.com/share?selection.family=Caveat:wght@400;500;600;700/Quicksand:wght@300;400;500;600;700 |
| 16 | Corporate Trust | Lexend | Source Sans 3 | corporate, trustworthy, accessible, readable, professiona... | Enterprise, government, healthcare, finance, accessibility-focused | https://fonts.google.com/share?selection.family=Lexend:wght@300;400;500;600;700/Source+Sans+3:wght@300;400;500;600;700 |
| 17 | Brutalist Raw | Space Mono | Space Mono | brutalist, raw, technical, monospace, minimal, stark | Brutalist designs, developer portfolios, experimental, tech art | https://fonts.google.com/share?selection.family=Space+Mono:wght@400;700 |
| 18 | Fashion Forward | Syne | Manrope | fashion, avant-garde, creative, bold, artistic, edgy | Fashion brands, creative agencies, art galleries, design studios | https://fonts.google.com/share?selection.family=Manrope:wght@300;400;500;600;700/Syne:wght@400;500;600;700 |
| 19 | Soft Rounded | Varela Round | Nunito Sans | soft, rounded, friendly, approachable, warm, gentle | Children's products, pet apps, friendly brands, wellness, soft UI | https://fonts.google.com/share?selection.family=Nunito+Sans:wght@300;400;500;600;700/Varela+Round |
| 20 | Premium Sans | Satoshi | General Sans | premium, modern, clean, sophisticated, versatile, balanced | Premium brands, modern agencies, SaaS, portfolios, startups | https://fonts.google.com/share?selection.family=DM+Sans:wght@400;500;700 |
| 21 | Vietnamese Friendly | Be Vietnam Pro | Noto Sans | vietnamese, international, readable, clean, multilingual,... | Vietnamese sites, multilingual apps, international products | https://fonts.google.com/share?selection.family=Be+Vietnam+Pro:wght@300;400;500;600;700/Noto+Sans:wght@300;400;500;600;700 |
| 22 | Japanese Elegant | Noto Serif JP | Noto Sans JP | japanese, elegant, traditional, modern, multilingual, rea... | Japanese sites, Japanese restaurants, cultural sites, anime/manga | https://fonts.google.com/share?selection.family=Noto+Sans+JP:wght@300;400;500;700/Noto+Serif+JP:wght@400;500;600;700 |
| 23 | Korean Modern | Noto Sans KR | Noto Sans KR | korean, modern, clean, professional, multilingual, readable | Korean sites, K-beauty, K-pop, Korean businesses, multilingual | https://fonts.google.com/share?selection.family=Noto+Sans+KR:wght@300;400;500;700 |
| 24 | Chinese Traditional | Noto Serif TC | Noto Sans TC | chinese, traditional, elegant, cultural, multilingual, re... | Traditional Chinese sites, cultural content, Taiwan/Hong Kong markets | https://fonts.google.com/share?selection.family=Noto+Sans+TC:wght@300;400;500;700/Noto+Serif+TC:wght@400;500;600;700 |
| 25 | Chinese Simplified | Noto Sans SC | Noto Sans SC | chinese, simplified, modern, professional, multilingual, ... | Simplified Chinese sites, mainland China market, business apps | https://fonts.google.com/share?selection.family=Noto+Sans+SC:wght@300;400;500;700 |
| 26 | Arabic Elegant | Noto Naskh Arabic | Noto Sans Arabic | arabic, elegant, traditional, cultural, RTL, readable | Arabic sites, Middle East market, Islamic content, bilingual sites | https://fonts.google.com/share?selection.family=Noto+Naskh+Arabic:wght@400;500;600;700/Noto+Sans+Arabic:wght@300;400;500;700 |
| 27 | Thai Modern | Noto Sans Thai | Noto Sans Thai | thai, modern, readable, clean, multilingual, accessible | Thai sites, Southeast Asia, tourism, Thai restaurants | https://fonts.google.com/share?selection.family=Noto+Sans+Thai:wght@300;400;500;700 |
| 28 | Hebrew Modern | Noto Sans Hebrew | Noto Sans Hebrew | hebrew, modern, RTL, clean, professional, readable | Hebrew sites, Israeli market, Jewish content, bilingual sites | https://fonts.google.com/share?selection.family=Noto+Sans+Hebrew:wght@300;400;500;700 |
| 29 | Legal Professional | EB Garamond | Lato | legal, professional, traditional, trustworthy, formal, au... | Law firms, legal services, contracts, formal documents, government | https://fonts.google.com/share?selection.family=EB+Garamond:wght@400;500;600;700/Lato:wght@300;400;700 |
| 30 | Medical Clean | Figtree | Noto Sans | medical, clean, accessible, professional, healthcare, tru... | Healthcare, medical clinics, pharma, health apps, accessibility | https://fonts.google.com/share?selection.family=Figtree:wght@300;400;500;600;700/Noto+Sans:wght@300;400;500;700 |
| 31 | Financial Trust | IBM Plex Sans | IBM Plex Sans | financial, trustworthy, professional, corporate, banking,... | Banks, finance, insurance, investment, fintech, enterprise | https://fonts.google.com/share?selection.family=IBM+Plex+Sans:wght@300;400;500;600;700 |
| 32 | Real Estate Luxury | Cinzel | Josefin Sans | real estate, luxury, elegant, sophisticated, property, pr... | Real estate, luxury properties, architecture, interior design | https://fonts.google.com/share?selection.family=Cinzel:wght@400;500;600;700/Josefin+Sans:wght@300;400;500;600;700 |
| 33 | Restaurant Menu | Playfair Display SC | Karla | restaurant, menu, culinary, elegant, foodie, hospitality | Restaurants, cafes, food blogs, culinary, hospitality | https://fonts.google.com/share?selection.family=Karla:wght@300;400;500;600;700/Playfair+Display+SC:wght@400;700 |
| 34 | Art Deco | Poiret One | Didact Gothic | art deco, vintage, 1920s, elegant, decorative, gatsby | Vintage events, art deco themes, luxury hotels, classic cocktails | https://fonts.google.com/share?selection.family=Didact+Gothic/Poiret+One |
| 35 | Magazine Style | Libre Bodoni | Public Sans | magazine, editorial, publishing, refined, journalism, print | Magazines, online publications, editorial content, journalism | https://fonts.google.com/share?selection.family=Libre+Bodoni:wght@400;500;600;700/Public+Sans:wght@300;400;500;600;700 |
| 36 | Crypto/Web3 | Orbitron | Exo 2 | crypto, web3, futuristic, tech, blockchain, digital | Crypto platforms, NFT, blockchain, web3, futuristic tech | https://fonts.google.com/share?selection.family=Exo+2:wght@300;400;500;600;700/Orbitron:wght@400;500;600;700 |
| 37 | Gaming Bold | Russo One | Chakra Petch | gaming, bold, action, esports, competitive, energetic | Gaming, esports, action games, competitive sports, entertainment | https://fonts.google.com/share?selection.family=Chakra+Petch:wght@300;400;500;600;700/Russo+One |
| 38 | Indie/Craft | Amatic SC | Cabin | indie, craft, handmade, artisan, organic, creative | Craft brands, indie products, artisan, handmade, organic products | https://fonts.google.com/share?selection.family=Amatic+SC:wght@400;700/Cabin:wght@400;500;600;700 |
| 39 | Startup Bold | Clash Display | Satoshi | startup, bold, modern, innovative, confident, dynamic | Startups, pitch decks, product launches, bold brands | https://fonts.google.com/share?selection.family=Outfit:wght@400;500;600;700/Rubik:wght@300;400;500;600;700 |
| 40 | E-commerce Clean | Rubik | Nunito Sans | ecommerce, clean, shopping, product, retail, conversion | E-commerce, online stores, product pages, retail, shopping | https://fonts.google.com/share?selection.family=Nunito+Sans:wght@300;400;500;600;700/Rubik:wght@300;400;500;600;700 |
| 41 | Academic/Research | Crimson Pro | Atkinson Hyperlegible | academic, research, scholarly, accessible, readable, educ... | Universities, research papers, academic journals, educational | https://fonts.google.com/share?selection.family=Atkinson+Hyperlegible:wght@400;700/Crimson+Pro:wght@400;500;600;700 |
| 42 | Dashboard Data | Fira Code | Fira Sans | dashboard, data, analytics, code, technical, precise | Dashboards, analytics, data visualization, admin panels | https://fonts.google.com/share?selection.family=Fira+Code:wght@400;500;600;700/Fira+Sans:wght@300;400;500;600;700 |
| 43 | Music/Entertainment | Righteous | Poppins | music, entertainment, fun, energetic, bold, performance | Music platforms, entertainment, events, festivals, performers | https://fonts.google.com/share?selection.family=Poppins:wght@300;400;500;600;700/Righteous |
| 44 | Minimalist Portfolio | Archivo | Space Grotesk | minimal, portfolio, designer, creative, clean, artistic | Design portfolios, creative professionals, minimalist brands | https://fonts.google.com/share?selection.family=Archivo:wght@300;400;500;600;700/Space+Grotesk:wght@300;400;500;600;700 |
| 45 | Kids/Education | Baloo 2 | Comic Neue | kids, education, playful, friendly, colorful, learning | Children's apps, educational games, kid-friendly content | https://fonts.google.com/share?selection.family=Baloo+2:wght@400;500;600;700/Comic+Neue:wght@300;400;700 |
| 46 | Wedding/Romance | Great Vibes | Cormorant Infant | wedding, romance, elegant, script, invitation, feminine | Wedding sites, invitations, romantic brands, bridal | https://fonts.google.com/share?selection.family=Cormorant+Infant:wght@300;400;500;600;700/Great+Vibes |
| 47 | Science/Tech | Exo | Roboto Mono | science, technology, research, data, futuristic, precise | Science, research, tech documentation, data-heavy sites | https://fonts.google.com/share?selection.family=Exo:wght@300;400;500;600;700/Roboto+Mono:wght@300;400;500;700 |
| 48 | Accessibility First | Atkinson Hyperlegible | Atkinson Hyperlegible | accessible, readable, inclusive, WCAG, dyslexia-friendly,... | Accessibility-critical sites, government, healthcare, inclusive design | https://fonts.google.com/share?selection.family=Atkinson+Hyperlegible:wght@400;700 |
| 49 | Sports/Fitness | Barlow Condensed | Barlow | sports, fitness, athletic, energetic, condensed, action | Sports, fitness, gyms, athletic brands, competition | https://fonts.google.com/share?selection.family=Barlow+Condensed:wght@400;500;600;700/Barlow:wght@300;400;500;600;700 |
| 50 | Luxury Minimalist | Bodoni Moda | Jost | luxury, minimalist, high-end, sophisticated, refined, pre... | Luxury minimalist brands, high-end fashion, premium products | https://fonts.google.com/share?selection.family=Bodoni+Moda:wght@400;500;600;700/Jost:wght@300;400;500;600;700 |
| 51 | Tech/HUD Mono | Share Tech Mono | Fira Code | tech, futuristic, hud, sci-fi, data, monospaced, precise | Sci-fi interfaces, developer tools, cybersecurity, dashboards | https://fonts.google.com/share?selection.family=Fira+Code:wght@300;400;500;600;700/Share+Tech+Mono |
| 52 | Pixel Retro | Press Start 2P | VT323 | pixel, retro, gaming, 8-bit, nostalgic, arcade | Pixel art games, retro websites, creative portfolios | https://fonts.google.com/share?selection.family=Press+Start+2P/VT323 |
| 53 | Neubrutalist Bold | Lexend Mega | Public Sans | bold, neubrutalist, loud, strong, geometric, quirky | Neubrutalist designs, Gen Z brands, bold marketing | https://fonts.google.com/share?selection.family=Lexend+Mega:wght@100..900/Public+Sans:wght@100..900 |
| 54 | Academic/Archival | EB Garamond | Crimson Text | academic, old-school, university, research, serious, trad... | University sites, archives, research papers, history | https://fonts.google.com/share?selection.family=Crimson+Text:wght@400;600;700/EB+Garamond:wght@400;500;600;700;800 |
| 55 | Spatial Clear | Inter | Inter | spatial, legible, glass, system, clean, neutral | Spatial computing, AR/VR, glassmorphism interfaces | https://fonts.google.com/share?selection.family=Inter:wght@300;400;500;600 |
| 56 | Kinetic Motion | Syncopate | Space Mono | kinetic, motion, futuristic, speed, wide, tech | Music festivals, automotive, high-energy brands | https://fonts.google.com/share?selection.family=Space+Mono:wght@400;700/Syncopate:wght@400;700 |
| 57 | Gen Z Brutal | Anton | Epilogue | brutal, loud, shouty, meme, internet, bold | Gen Z marketing, streetwear, viral campaigns | https://fonts.google.com/share?selection.family=Anton/Epilogue:wght@400;500;600;700 |
| 58 | Minimalist Monochrome Editorial | Playfair Display | Source Serif 4 | monochrome, editorial, austere, typographic, pocket manif... | Luxury fashion mobile apps, editorial publications, digital exhibit... | https://fonts.google.com/share?selection.family=JetBrains+Mono:wght@400;500/Playfair+Display:ital,wght@0,400;0,700;0,900;1,400/Source+Serif+4:ital,wght@0,300;0,400;0,600;1,300 |
| 59 | Modern Dark Cinema (Inter System) | Inter | Inter | dark, cinematic, technical, precision, clean, premium, de... | Developer tools, fintech/trading, AI dashboards, streaming platform... | https://fonts.google.com/share?selection.family=Inter:wght@300;400;500;600;700 |
| 60 | SaaS Mobile Boutique (Calistoga + Inter) | Calistoga | Inter | saas, boutique, electric, warm, editorial, bold, premium,... | B2B SaaS mobile, fintech apps, analytics dashboards, marketing tool... | https://fonts.google.com/share?selection.family=Calistoga:ital@0;1/Inter:wght@300;400;500;600;700/JetBrains+Mono:wght@400;500 |
| 61 | Terminal CLI Monospace | JetBrains Mono | JetBrains Mono | terminal, cli, hacker, monospace, matrix, developer, retr... | Developer tools, Web3/blockchain apps, hacker aesthetic, sci-fi gam... | https://fonts.google.com/share?selection.family=JetBrains+Mono:ital,wght@0,400;0,500;1,400 |
| 62 | Kinetic Brutalism (Space Grotesk) | Space Grotesk | Space Grotesk | kinetic, brutalist, aggressive, uppercase, oversized, dis... | Music/culture apps, sports platforms, brand flagship mobile, perfor... | https://fonts.google.com/share?selection.family=Space+Grotesk:wght@400;500;600;700 |
| 63 | Flat Design Mobile (System Bold) | Inter | Inter | flat, clean, system, bold, geometric, cross-platform, ico... | Cross-platform apps, dashboards, system UI, onboarding, marketing p... | https://fonts.google.com/share?selection.family=Inter:wght@400;600;700;800 |
| 64 | Material You MD3 (Roboto System) | Roboto | Roboto | material design 3, md3, android, google, tonal, friendly,... | Android apps, cross-platform tools, productivity software, data-hea... | https://fonts.google.com/share?selection.family=Roboto:ital,wght@0,300;0,400;0,500;0,700;1,400 |
| 65 | Neo Brutalism Mobile (Space Grotesk Heavy) | Space Grotesk | Space Grotesk | neo brutalism, pop art, loud, bold, heavy, stickers, mech... | Creative tools, Gen-Z marketing, e-commerce for youth culture, cont... | https://fonts.google.com/share?selection.family=Space+Grotesk:wght@700 |
| 66 | Bold Typography Mobile (Inter-Tight Poster) | Inter | Playfair Display | bold typography, editorial, poster, near-black, vermillio... | Creative brand flagships, reading platforms, event apps, flash page... | https://fonts.google.com/share?selection.family=Inter:ital,wght@0,400;0,500;0,600;0,700;0,800;1,400/JetBrains+Mono:wght@400/Playfair+Display:ital@1 |
| 67 | Academia Mobile (Cormorant + Crimson + Cinzel) | Cormorant Garamond | Crimson Pro | academia, library, mahogany, parchment, brass, scholarly,... | Knowledge management apps, scholarly reading tools, personal brand ... | https://fonts.google.com/share?selection.family=Cinzel:wght@400;500;600/Cormorant+Garamond:ital,wght@0,300;0,500;0,700;1,300;1,500/Crimson+Pro:ital,wght@0,300;0,400;0,600;1,300;1,400 |
| 68 | Cyberpunk Mobile (Orbitron + JetBrains Mono) | Orbitron | JetBrains Mono | cyberpunk, neon, glitch, hud, sci-fi, dark, matrix green,... | Gaming companion apps, fintech/crypto, data visualization, dark bra... | https://fonts.google.com/share?selection.family=JetBrains+Mono:wght@400;500/Orbitron:wght@700;900 |
| 69 | Web3 Bitcoin DeFi (Space Grotesk + Inter + Mono) | Space Grotesk | Inter | web3, bitcoin, defi, digital gold, fintech, crypto, trust... | DeFi protocols and wallets, NFT platforms, metaverse social apps, h... | https://fonts.google.com/share?selection.family=Inter:wght@400;500;600;700/JetBrains+Mono:wght@400;500/Space+Grotesk:wght@500;600;700 |
| 70 | Claymorphism Mobile (Nunito + DM Sans) | Nunito | DM Sans | claymorphism, clay, rounded, playful, candy, bubbly, soft... | Children education apps, teen social, brand mascot apps, creative t... | https://fonts.google.com/share?selection.family=DM+Sans:ital,wght@0,400;0,500;0,700;1,400/Nunito:ital,wght@0,700;0,800;0,900;1,700 |
| 71 | Enterprise SaaS Mobile (Plus Jakarta Sans) | Plus Jakarta Sans | Plus Jakarta Sans | enterprise, saas, b2b, professional, indigo, modern, appr... | B2B SaaS apps, productivity tools, government and finance mobile ap... | https://fonts.google.com/share?selection.family=Plus+Jakarta+Sans:ital,wght@0,400;0,600;0,700;0,800;1,400 |
| 72 | Sketch Hand-Drawn Mobile (Kalam + Patrick Hand) | Kalam | Patrick Hand | sketch, hand-drawn, handwriting, human, imperfect, organi... | Journaling apps, prototype tools, children's picturebook apps, crea... | https://fonts.google.com/share?selection.family=Kalam:wght@400;700/Patrick+Hand |
| 73 | Neumorphism Mobile (Plus Jakarta Sans + System) | Plus Jakarta Sans | Plus Jakarta Sans | neumorphism, soft ui, monochromatic, cool grey, minimal, ... | Smart home controls, minimal tools, aesthetic dashboards, health mo... | https://fonts.google.com/share?selection.family=Plus+Jakarta+Sans:ital,wght@0,400;0,500;0,700;1,400 |

---


## UX 准则数据库（99 条）

| # | 分类 | 问题 | 平台 | 做 | 不做 | 严重度 |
|---|------|------|------|----|----- |--------|
| 1 | Navigation | Smooth Scroll | Web | Use scroll-behavior: smooth on html element | Jump directly without transition | High |
| 2 | Navigation | Sticky Navigation | Web | Add padding-top to body equal to nav height | Let nav overlap first section content | Medium |
| 3 | Navigation | Active State | All | Highlight active nav item with color/underline | No visual feedback on current location | Medium |
| 4 | Navigation | Back Button | Mobile | Preserve navigation history properly | Break browser/app back button behavior | High |
| 5 | Navigation | Deep Linking | All | Update URL on state/view changes | Static URLs for dynamic content | Medium |
| 6 | Navigation | Breadcrumbs | Web | Use for sites with 3+ levels of depth | Use for flat single-level sites | Low |
| 7 | Animation | Excessive Motion | All | Animate 1-2 key elements per view maximum | Animate everything that moves | High |
| 8 | Animation | Duration Timing | All | Use 150-300ms for micro-interactions | Use animations longer than 500ms for UI | Medium |
| 9 | Animation | Reduced Motion | All | Check prefers-reduced-motion media query | Ignore accessibility motion settings | High |
| 10 | Animation | Loading States | All | Use skeleton screens or spinners | Leave UI frozen with no feedback | High |
| 11 | Animation | Hover vs Tap | All | Use click/tap for primary interactions | Rely only on hover for important actions | High |
| 12 | Animation | Continuous Animation | All | Use for loading indicators only | Use for decorative elements | Medium |
| 13 | Animation | Transform Performance | Web | Use transform and opacity for animations | Animate width/height/top/left properties | Medium |
| 14 | Animation | Easing Functions | All | Use ease-out for entering ease-in for exiting | Use linear for UI transitions | Low |
| 15 | Layout | Z-Index Management | Web | Define z-index scale system (10 20 30 50) | Use arbitrary large z-index values | High |
| 16 | Layout | Overflow Hidden | Web | Test all content fits within containers | Blindly apply overflow-hidden | Medium |
| 17 | Layout | Fixed Positioning | Web | Account for safe areas and other fixed elements | Stack multiple fixed elements carelessly | Medium |
| 18 | Layout | Stacking Context | Web | Understand what creates new stacking context | Expect z-index to work across contexts | Medium |
| 19 | Layout | Content Jumping | Web | Reserve space for async content | Let images/content push layout around | High |
| 20 | Layout | Viewport Units | Web | Use dvh or account for mobile browser chrome | Use 100vh for full-screen mobile layouts | Medium |
| 21 | Layout | Container Width | Web | Limit max-width for text content (65-75ch) | Let text span full viewport width | Medium |
| 22 | Touch | Touch Target Size | Mobile | Minimum 44x44px touch targets | Tiny clickable areas | High |
| 23 | Touch | Touch Spacing | Mobile | Minimum 8px gap between touch targets | Tightly packed clickable elements | Medium |
| 24 | Touch | Gesture Conflicts | Mobile | Avoid horizontal swipe on main content | Override system gestures | Medium |
| 25 | Touch | Tap Delay | Mobile | Use touch-action CSS or fastclick | Default mobile tap handling | Medium |
| 26 | Touch | Pull to Refresh | Mobile | Disable where not needed | Enable by default everywhere | Low |
| 27 | Touch | Haptic Feedback | Mobile | Use for confirmations and important actions | Overuse vibration feedback | Low |
| 28 | Interaction | Focus States | All | Use visible focus rings on interactive elements | Remove focus outline without replacement | High |
| 29 | Interaction | Hover States | Web | Change cursor and add subtle visual change | No hover feedback on clickable elements | Medium |
| 30 | Interaction | Active States | All | Add pressed/active state visual change | No feedback during interaction | Medium |
| 31 | Interaction | Disabled States | All | Reduce opacity and change cursor | Confuse disabled with normal state | Medium |
| 32 | Interaction | Loading Buttons | All | Disable button and show loading state | Allow multiple clicks during processing | High |
| 33 | Interaction | Error Feedback | All | Show clear error messages near problem | Silent failures with no feedback | High |
| 34 | Interaction | Success Feedback | All | Show success message or visual change | No confirmation of completed action | Medium |
| 35 | Interaction | Confirmation Dialogs | All | Confirm before delete/irreversible actions | Delete without confirmation | High |
| 36 | Accessibility | Color Contrast | All | Minimum 4.5:1 ratio for normal text | Low contrast text | High |
| 37 | Accessibility | Color Only | All | Use icons/text in addition to color | Red/green only for error/success | High |
| 38 | Accessibility | Alt Text | All | Descriptive alt text for meaningful images | Empty or missing alt attributes | High |
| 39 | Accessibility | Heading Hierarchy | Web | Use sequential heading levels h1-h6 | Skip heading levels or misuse for styling | Medium |
| 40 | Accessibility | ARIA Labels | All | Add aria-label for icon-only buttons | Icon buttons without labels | High |
| 41 | Accessibility | Keyboard Navigation | Web | Tab order matches visual order | Keyboard traps or illogical tab order | High |
| 42 | Accessibility | Screen Reader | All | Use semantic HTML and ARIA properly | Div soup with no semantics | Medium |
| 43 | Accessibility | Form Labels | All | Use label with for attribute or wrap input | Placeholder-only inputs | High |
| 44 | Accessibility | Error Messages | All | Use aria-live or role=alert for errors | Visual-only error indication | High |
| 45 | Accessibility | Skip Links | Web | Provide skip to main content link | No skip link on nav-heavy pages | Medium |
| 46 | Performance | Image Optimization | All | Use appropriate size and format (WebP) | Unoptimized full-size images | High |
| 47 | Performance | Lazy Loading | All | Lazy load below-fold images and content | Load everything upfront | Medium |
| 48 | Performance | Code Splitting | Web | Split code by route/feature | Single large bundle | Medium |
| 49 | Performance | Caching | Web | Set appropriate cache headers | No caching strategy | Medium |
| 50 | Performance | Font Loading | Web | Use font-display swap or optional | Invisible text during font load | Medium |
| 51 | Performance | Third Party Scripts | Web | Load non-critical scripts async/defer | Synchronous third-party scripts | Medium |
| 52 | Performance | Bundle Size | Web | Monitor and minimize bundle size | Ignore bundle size growth | Medium |
| 53 | Performance | Render Blocking | Web | Inline critical CSS defer non-critical | Large blocking CSS files | Medium |
| 54 | Forms | Input Labels | All | Always show label above or beside input | Placeholder as only label | High |
| 55 | Forms | Error Placement | All | Show error below related input | Single error message at top of form | Medium |
| 56 | Forms | Inline Validation | All | Validate on blur for most fields | Validate only on submit | Medium |
| 57 | Forms | Input Types | All | Use email tel number url etc | Text input for everything | Medium |
| 58 | Forms | Autofill Support | Web | Use autocomplete attribute properly | Block or ignore autofill | Medium |
| 59 | Forms | Required Indicators | All | Use asterisk or (required) text | No indication of required fields | Medium |
| 60 | Forms | Password Visibility | All | Toggle to show/hide password | No visibility toggle | Medium |
| 61 | Forms | Submit Feedback | All | Show loading then success/error state | No feedback after submit | High |
| 62 | Forms | Input Affordance | All | Use distinct input styling | Inputs that look like plain text | Medium |
| 63 | Forms | Mobile Keyboards | Mobile | Use inputmode attribute | Default keyboard for all inputs | Medium |
| 64 | Responsive | Mobile First | Web | Start with mobile styles then add breakpoints | Desktop-first causing mobile issues | Medium |
| 65 | Responsive | Breakpoint Testing | Web | Test at 320 375 414 768 1024 1440 | Only test on your device | Medium |
| 66 | Responsive | Touch Friendly | Web | Increase touch targets on mobile | Same tiny buttons on mobile | High |
| 67 | Responsive | Readable Font Size | All | Minimum 16px body text on mobile | Tiny text on mobile | High |
| 68 | Responsive | Viewport Meta | Web | Use width=device-width initial-scale=1 | Missing or incorrect viewport | High |
| 69 | Responsive | Horizontal Scroll | Web | Ensure content fits viewport width | Content wider than viewport | High |
| 70 | Responsive | Image Scaling | Web | Use max-width: 100% on images | Fixed width images overflow | Medium |
| 71 | Responsive | Table Handling | Web | Use horizontal scroll or card layout | Wide tables breaking layout | Medium |
| 72 | Typography | Line Height | All | Use 1.5-1.75 for body text | Cramped or excessive line height | Medium |
| 73 | Typography | Line Length | Web | Limit to 65-75 characters per line | Full-width text on large screens | Medium |
| 74 | Typography | Font Size Scale | All | Use consistent modular scale | Random font sizes | Medium |
| 75 | Typography | Font Loading | Web | Reserve space with fallback font | Layout shift when fonts load | Medium |
| 76 | Typography | Contrast Readability | All | Use darker text on light backgrounds | Gray text on gray background | High |
| 77 | Typography | Heading Clarity | All | Clear size/weight difference | Headings similar to body text | Medium |
| 78 | Feedback | Loading Indicators | All | Show spinner/skeleton for operations > 300ms | No feedback during loading | High |
| 79 | Feedback | Empty States | All | Show helpful message and action | Blank empty screens | Medium |
| 80 | Feedback | Error Recovery | All | Provide clear next steps | Error without recovery path | Medium |
| 81 | Feedback | Progress Indicators | All | Step indicators or progress bar | No indication of progress | Medium |
| 82 | Feedback | Toast Notifications | All | Auto-dismiss after 3-5 seconds | Toasts that never disappear | Medium |
| 83 | Feedback | Confirmation Messages | All | Brief success message | Silent success | Medium |
| 84 | Content | Truncation | All | Truncate with ellipsis and expand option | Overflow or broken layout | Medium |
| 85 | Content | Date Formatting | All | Use relative or locale-aware dates | Ambiguous date formats | Low |
| 86 | Content | Number Formatting | All | Use thousand separators or abbreviations | Long unformatted numbers | Low |
| 87 | Content | Placeholder Content | All | Use realistic sample data | Lorem ipsum everywhere | Low |
| 88 | Onboarding | User Freedom | All | Provide Skip and Back buttons | Force linear unskippable tour | Medium |
| 89 | Search | Autocomplete | Web | Show predictions as user types | Require full type and enter | Medium |
| 90 | Search | No Results | Web | Show 'No results' with suggestions | Blank screen or '0 results' | Medium |
| 91 | Data Entry | Bulk Actions | Web | Allow multi-select and bulk edit | Single row actions only | Low |
| 92 | AI Interaction | Disclaimer | All | Clearly label AI generated content | Present AI as human | High |
| 93 | AI Interaction | Streaming | All | Stream text response token by token | Show loading spinner for 10s+ | Medium |
| 94 | Spatial UI | Gaze Hover | VisionOS | Scale/highlight element on look | Static element until pinch | High |
| 95 | Spatial UI | Depth Layering | VisionOS | Use glass material and z-offset | Flat opaque panels blocking view | Medium |
| 96 | Sustainability | Auto-Play Video | Web | Click-to-play or pause when off-screen | Auto-play high-res video loops | Medium |
| 97 | Sustainability | Asset Weight | Web | Compress and lazy load 3D models | Load 50MB textures | Medium |
| 98 | AI Interaction | Feedback Loop | All | Thumps up/down or 'Regenerate' | Static output only | Low |
| 99 | Accessibility | Motion Sensitivity | All | Respect prefers-reduced-motion | Force scroll effects | High |

---


## 图表类型数据库（25 种）

| # | 数据类型 | 关键词 | 最佳图表 | 备选 | 推荐库 |
|---|----------|--------|----------|------|--------|
| 1 | Trend Over Time | trend, time-series, line, growth, timeline, progress | Line Chart | Area Chart, Smooth Area | Chart.js, Recharts, ApexCharts |
| 2 | Compare Categories | compare, categories, bar, comparison, ranking | Bar Chart (Horizontal or Vertical) | Column Chart, Grouped Bar | Chart.js, Recharts, D3.js |
| 3 | Part-to-Whole | part-to-whole, pie, donut, percentage, proportion, share | Pie Chart or Donut | Stacked Bar, Waffle Chart | Chart.js, Recharts, D3.js |
| 4 | Correlation / Distribution | correlation, distribution, scatter, relationship, pattern, cluster | Scatter Plot or Bubble Chart | Heat Map, Matrix | D3.js, Plotly, Recharts |
| 5 | Heatmap / Intensity | heatmap, heat-map, intensity, density, matrix, calendar | Heat Map or Choropleth | Grid Heat Map, Bubble Heat | D3.js, Plotly, ApexCharts |
| 6 | Geographic Data | geographic, map, location, region, geo, spatial, choropleth | Choropleth Map or Bubble Map | Geographic Heat Map | D3.js, Mapbox, Leaflet |
| 7 | Funnel / Flow | funnel, flow, conversion, drop-off, pipeline, stages | Funnel Chart or Sankey | Waterfall (for flows) | D3.js, Recharts, Custom SVG |
| 8 | Performance vs Target | performance, target, kpi, gauge, goal, threshold, progress | Gauge Chart or Bullet Chart | Dial, Thermometer | D3.js, ApexCharts, Custom SVG |
| 9 | Time-Series Forecast | forecast, prediction, confidence, band, projection, estimate | Line with Confidence Band | Ribbon Chart | Chart.js, ApexCharts, Plotly |
| 10 | Anomaly Detection | anomaly, outlier, spike, alert, detection, monitoring, deviation | Line Chart with Highlights | Scatter with Alert | D3.js, Plotly, ApexCharts |
| 11 | Hierarchical / Nested Data | hierarchy, nested, treemap, parent, children, breakdown, drill | Treemap | Sunburst, Nested Donut, Icicle | D3.js, Recharts, ApexCharts |
| 12 | Flow / Process Data | flow, process, sankey, distribution, source, target, transfer | Sankey Diagram | Alluvial, Chord Diagram | D3.js (d3-sankey), Plotly |
| 13 | Cumulative Changes | waterfall, cumulative, variance, incremental, bridge, delta | Waterfall Chart | Stacked Bar, Cascade | ApexCharts, Highcharts, Plotly |
| 14 | Multi-Variable Comparison | radar, spider, multi-variable, attributes, dimensions, comparison | Radar / Spider Chart | Parallel Coordinates, Grouped Bar | Chart.js, Recharts, ApexCharts |
| 15 | Stock / Trading OHLC | stock, trading, ohlc, candlestick, finance, price, volume | Candlestick Chart | OHLC Bar, Heikin-Ashi | Lightweight Charts (TradingView), ApexCharts |
| 16 | Relationship / Connection Data | network, graph, nodes, edges, connections, relationships, force | Network Graph | Hierarchical Tree, Adjacency Matrix | D3.js (d3-force), Vis.js, Cytoscape.js |
| 17 | Distribution / Statistical | distribution, statistical, spread, median, outlier, quartile, boxplot | Box Plot | Violin Plot, Beeswarm | Plotly, D3.js, Chart.js (plugin) |
| 18 | Performance vs Target (Compact) | bullet, compact, kpi, dashboard, target, benchmark, range | Bullet Chart | Gauge, Progress Bar | D3.js, Plotly, Custom SVG |
| 19 | Proportional / Percentage | waffle, percentage, proportion, progress, filled, grid | Waffle Chart | Pictogram, Stacked Bar 100% | D3.js, React-Waffle, Custom CSS Grid |
| 20 | Hierarchical Proportional | sunburst, hierarchy, nested, proportion, radial, circle | Sunburst Chart | Treemap, Icicle, Circle Packing | D3.js (d3-hierarchy), Recharts, ApexCharts |
| 21 | Root Cause Analysis | root cause, decomposition, tree, hierarchy, drill-down, ai-split, attribution | Decomposition Tree | Decision Tree, Flow Chart | Power BI (native), React-Flow, Custom D3.js |
| 22 | 3D Spatial Data | 3d, spatial, immersive, terrain, molecular, volumetric, point-cloud | 3D Scatter / Surface Plot | Volumetric Rendering, Point Cloud | Three.js, Deck.gl, Plotly 3D |
| 23 | Real-Time Streaming | streaming, real-time, ticker, live, velocity, pulse, monitoring | Streaming Area Chart | Ticker Tape, Moving Gauge | Smoothed D3.js, CanvasJS |
| 24 | Sentiment / Emotion | sentiment, emotion, nlp, opinion, feeling, text-analysis | Word Cloud with Sentiment | Sentiment Arc, Radar Chart | D3-cloud, Highcharts, Nivo |
| 25 | Process Mining | process, mining, variants, path, bottleneck, log, event | Process Map / Graph | Directed Acyclic Graph (DAG), Petri Net | React-Flow, Cytoscape.js, Recharts |

---


## 交付前检查清单

### 视觉质量
- [ ] 未使用 emoji 作为图标（使用 SVG：Heroicons/Lucide/Phosphor）
- [ ] 所有图标来自同一图标家族和风格（描边宽度、圆角风格一致）
- [ ] 使用官方品牌资产，比例和留白正确
- [ ] 按压状态不会导致布局偏移或抖动
- [ ] 全局使用语义主题 token（无页面级硬编码颜色）

### 交互
- [ ] 所有可点击元素提供清晰的按压反馈（涟漪/透明度/阴影），80-150ms 内响应
- [ ] 触控目标满足最小尺寸（iOS >=44x44pt，Android >=48x48dp）
- [ ] 微交互时长在 150-300ms 范围内，使用原生感缓动
- [ ] 禁用状态视觉清晰（降低透明度 0.38-0.5）且不可交互
- [ ] 屏幕阅读器焦点顺序与视觉顺序一致，交互标签描述清晰
- [ ] 手势区域避免嵌套/冲突（点击/拖拽/返回滑动冲突）

### 亮色/暗色模式
- [ ] 亮色和暗色模式下主要文本对比度 >=4.5:1
- [ ] 亮色和暗色模式下次要文本对比度 >=3:1
- [ ] 分割线/边框和交互状态在两种模式下均可区分
- [ ] 模态/抽屉遮罩透明度足够（通常 40-60% 黑色）
- [ ] 两种主题均在交付前测试（不能从单一主题推断）

### 布局
- [ ] 固定头部、Tab 栏和底部 CTA 栏遵守安全区域
- [ ] 滚动内容不被固定/粘性栏遮挡
- [ ] 在小手机（375px）、大手机、平板（竖屏+横屏）上验证
- [ ] 水平内边距/间距按设备尺寸和方向正确适配
- [ ] 组件、区块和页面级别保持 4/8dp 间距节奏
- [ ] 长文本在大屏设备上保持可读性（无全宽段落）

### 无障碍
- [ ] 所有有意义的图片/图标有无障碍标签（alt text / accessibilityLabel）
- [ ] 表单字段有标签、提示和清晰的错误信息（错误靠近字段，不只在顶部）
- [ ] 颜色不是唯一的信息传达方式（加图标/文字辅助）
- [ ] 支持 prefers-reduced-motion 和动态字体大小，不破坏布局
- [ ] 无障碍特征/角色/状态（选中、禁用、展开）正确播报

---

## 常见专业 UI 规则

### 图标规范

| 规则 | 标准 | 避免 |
|------|------|------|
| 不用 Emoji 做结构图标 | 使用矢量图标（Phosphor、Heroicons、Lucide） | 用 emoji 做导航、设置或系统控件 |
| 仅用矢量资产 | SVG 或平台矢量图标，支持主题化 | 模糊或像素化的光栅 PNG 图标 |
| 一致的图标尺寸 | 定义为设计 token（icon-sm/md=24pt/lg） | 随意混用 20pt/24pt/28pt |
| 描边一致性 | 同一视觉层级内统一描边宽度（1.5px 或 2px） | 随意混用粗细描边 |
| 填充与轮廓纪律 | 同一层级使用一种图标风格 | 同一层级混用填充和轮廓图标 |
| 触控目标最小值 | >=44x44pt 交互区域（图标小时用 hitSlop 扩展） | 无内边距的小触控目标 |

### 间距系统

使用 4/8dp 基础网格：
- 组件内边距：8/12/16/24px
- 组件间距：8/16/24px
- 区块间距：24/32/48px
- 页面边距：16/24px（移动端）/ 32/48px（桌面端）

### 颜色语义 Token

`
--color-primary        主操作色
--color-secondary      次要操作色
--color-accent         强调/CTA 色
--color-background     页面背景
--color-surface        卡片/面板背景
--color-foreground     主要文本
--color-muted          次要文本
--color-border         边框/分割线
--color-destructive    危险/删除操作
--color-success        成功状态
--color-warning        警告状态
`

---

## 使用说明

本文件完全自包含，复制到任何项目的 .kiro/steering/ 目录即可使用：

`
your-project/
└── .kiro/
    └── steering/
        └── ui-ux-pro-max.md   <- 复制此文件（重命名为 .md）
`

AI 会自动读取本文件中的所有数据表，在设计决策时直接推理，无需执行任何脚本。
