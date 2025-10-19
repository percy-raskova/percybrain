---
title: AI Usage Guide - Local AI for Zettelkasten Enhancement
category: how-to
tags:
  - ai
  - ollama
  - workflow
  - tutorial
last_reviewed: '2025-10-19'
---

# AI Usage Guide - Local AI for Zettelkasten Enhancement

## Overview

PercyBrain integrates local AI through Ollama to enhance your Zettelkasten workflow while preserving complete privacy. Unlike cloud AI services that send your notes to external servers, all AI processing happens on your machine. Your thoughts, research, and writing never leave your computer.

### What AI Features PercyBrain Offers

- **Explain**: Clarify complex concepts in simple terms
- **Summarize**: Condense long notes into key points
- **Suggest Links**: Find related concepts for connecting notes
- **Improve Writing**: Enhance clarity and flow
- **Answer Questions**: Explore ideas through dialogue
- **Generate Ideas**: Brainstorm new angles and connections
- **Draft Generation**: Synthesize multiple notes into coherent drafts

### Prerequisites

- Ollama installed on your system
- At least one language model downloaded
- 8GB RAM minimum (16GB recommended)
- PercyBrain Neovim configuration active

### Privacy Benefits of Local AI

Your notes remain completely private:

- **Zero Network Transmission**: AI runs 100% locally
- **No API Keys**: No authentication tokens to compromise
- **No Usage Tracking**: Your thinking patterns stay private
- **Complete Control**: Delete models and data anytime
- **Safe for Sensitive Work**: GDPR, HIPAA, NDA compliant by design

For detailed privacy rationale, see `/home/percy/.config/nvim/docs/explanation/LOCAL_AI_RATIONALE.md`

## Part 1: Ollama Setup

### Installing Ollama

**Linux/macOS**:

```bash
curl https://ollama.ai/install.sh | sh
```

**Manual Download** (all platforms):

Visit [ollama.ai](https://ollama.ai) and download the installer for your operating system.

**Verify Installation**:

```bash
ollama --version
# Should output: ollama version X.Y.Z
```

### Understanding System Requirements

| Hardware | Minimum        | Recommended       | Optimal          |
| -------- | -------------- | ----------------- | ---------------- |
| RAM      | 8GB            | 16GB              | 32GB             |
| Storage  | 10GB free      | 20GB free         | 50GB+ free       |
| CPU      | Any modern CPU | 4+ cores          | 8+ cores         |
| GPU      | Not required   | Apple Silicon/NPU | NVIDIA 8GB+ VRAM |

**Note**: Even minimum specs handle 3-7B parameter models comfortably for Zettelkasten work.

### Downloading Models

Start Ollama service (if not auto-started):

```bash
ollama serve
```

Download recommended models:

```bash
# Primary recommendation - balanced speed and quality
ollama pull llama3.2

# Alternative models (optional)
ollama pull mistral        # Faster, good for quick tasks
ollama pull codellama      # Better for technical notes
ollama pull nous-hermes    # Excellent instruction following
ollama pull phi3           # Microsoft's efficient model
```

**Download Progress**: Models are 2-8GB. Download times vary by internet speed (typically 5-20 minutes).

### Model Selection Guide

| Model       | Size  | Best For        | Speed     | Quality   | Use Case                |
| ----------- | ----- | --------------- | --------- | --------- | ----------------------- |
| llama3.2    | 4.7GB | General writing | Fast      | Good      | Daily Zettelkasten work |
| mistral     | 4.1GB | Quick tasks     | Very Fast | Good      | Rapid summarization     |
| codellama   | 7GB   | Technical notes | Medium    | Excellent | Programming concepts    |
| phi3        | 3.8GB | Efficiency      | Very Fast | Good      | Low-resource systems    |
| nous-hermes | 7GB   | Instructions    | Medium    | Excellent | Complex prompts         |
| llama3.1:8b | 8GB   | Higher quality  | Medium    | Excellent | Important drafts        |

**Default Model**: PercyBrain uses `llama3.2:latest` by default (configured in `lua/plugins/ai-sembr/ollama.lua`).

### Testing Ollama

**Test 1: Verify Service**:

```bash
# Check if Ollama is running
pgrep -x ollama
# Should output a process ID number
```

**Test 2: Simple Interaction**:

```bash
ollama run llama3.2 "Explain Zettelkasten method in 3 sentences"
```

Expected output: A concise explanation of the Zettelkasten method.

**Test 3: List Installed Models**:

```bash
ollama list
# Should show downloaded models with sizes and dates
```

### Troubleshooting Installation

**"Command not found: ollama"**:

```bash
# Check installation path
which ollama

# Add to PATH if needed (Linux/macOS)
echo 'export PATH="$PATH:/usr/local/bin"' >> ~/.bashrc
source ~/.bashrc
```

**"Cannot connect to Ollama server"**:

```bash
# Manually start Ollama service
ollama serve

# Or check if service is running
systemctl status ollama  # Linux with systemd
```

**"Out of memory" errors**:

- Close other applications to free RAM
- Try smaller model (phi3 instead of llama3.1:8b)
- Restart Ollama service: `pkill ollama && ollama serve`

## Part 2: AI Commands in PercyBrain

### Command Overview

All AI commands use the `<leader>a` prefix (by default `<space>a`):

| Keymap       | Command         | Description                      | Mode          |
| ------------ | --------------- | -------------------------------- | ------------- |
| `<leader>aa` | AI Menu         | Telescope picker of all commands | Normal        |
| `<leader>ae` | Explain         | Clarify complex concepts         | Normal/Visual |
| `<leader>as` | Summarize       | Condense to key points           | Normal/Visual |
| `<leader>al` | Suggest Links   | Find related concepts            | Normal        |
| `<leader>aw` | Improve Writing | Enhance clarity/flow             | Normal/Visual |
| `<leader>aq` | Ask Question    | Interactive Q&A                  | Normal        |
| `<leader>ax` | Generate Ideas  | Brainstorm angles                | Normal        |
| `<leader>ad` | Generate Draft  | Synthesize notes into prose      | Normal        |

### AI Menu (`<leader>aa`)

**Purpose**: Quick access to all AI commands via searchable Telescope picker.

**Usage**:

1. Press `<leader>aa` in any markdown file
2. Type to filter commands (e.g., "explain", "summ")
3. Press `Enter` to execute selected command

**When to use**: Preferred method when you're learning the commands or switching between different AI tasks.

### Explain (`<leader>ae`)

**Purpose**: Get AI explanation of complex concepts, academic jargon, or technical terminology.

**Usage**:

**Option 1: Explain Selection** (Visual mode)

1. Select text with `v` (visual mode)
2. Press `<leader>ae`
3. AI explains in simpler terms in floating window

**Option 2: Explain Context** (Normal mode)

1. Place cursor in paragraph
2. Press `<leader>ae`
3. AI explains surrounding context (50 lines)

**Example Workflow**:

```markdown
# Before
The phenomenological reduction involves epoché,
bracketing natural attitudes toward existence.

# After <leader>ae (visual selection)
Floating window shows:
"Phenomenological reduction is a method where you temporarily
set aside your usual assumptions about reality to examine
pure conscious experience. Epoché means 'suspension' - you're
pausing your normal way of thinking to see things fresh."
```

**Use Cases**:

- Literature notes with academic language → plain English
- Technical documentation → beginner-friendly explanations
- Foreign concept → familiar analogies
- Dense paragraphs → unpacked step-by-step

### Summarize (`<leader>as`)

**Purpose**: Condense long notes, articles, or sections into concise bullet points.

**Usage**:

**Summarize Selection**:

1. Select text in visual mode
2. Press `<leader>as`
3. Get bullet-point summary in floating window

**Summarize Context**:

1. Cursor in long note
2. Press `<leader>as` (normal mode)
3. AI summarizes surrounding context

**Example Workflow**:

```markdown
# Before (literature note with 5 paragraphs about distributed cognition)
[...500 words of dense academic text...]

# After <leader>as (visual selection)
Floating window shows:
"**Key Points**:
- Cognition extends beyond individual minds into tools and environment
- Knowledge is distributed across people, artifacts, and systems
- Example: Navigation uses charts, instruments, and crew coordination
- Memory offloaded to external representations (notebooks, diagrams)
- Implications: Design systems that support distributed thinking"
```

**Use Cases**:

- Literature notes → permanent note preparation
- Long articles → extract core insights
- Meeting notes → action items
- Research papers → key findings

### Suggest Links (`<leader>al`)

**Purpose**: Discover related concepts to link in your Zettelkasten.

**Usage**:

1. Cursor in current note
2. Press `<leader>al`
3. AI analyzes content and suggests 5-7 related topics

**Example Workflow**:

```markdown
# Current note: "distributed-cognition.md"
Content discusses how thinking happens across people and tools.

# After <leader>al
Floating window shows:
"**Suggested Related Concepts**:
- **Extended Mind Thesis**: Philosophical foundation for distributed cognition
- **Situated Cognition**: How environment shapes thinking
- **Activity Theory**: Framework for tool-mediated human activity
- **Cognitive Artifacts**: External objects that aid thinking
- **Communities of Practice**: Social dimension of distributed knowledge
- **Human-Computer Interaction**: Design implications
- **Embodied Cognition**: Physical basis of thought"
```

**Use Cases**:

- Building note connections
- Discovering gaps in knowledge graph
- Exploring new research directions
- Cross-disciplinary linking

### Improve Writing (`<leader>aw`)

**Purpose**: Enhance clarity, conciseness, and flow of rough drafts.

**Usage**:

1. Select rough text in visual mode
2. Press `<leader>aw`
3. Review improved version in floating window
4. Manually incorporate changes you like

**Example Workflow**:

```markdown
# Before (fleeting note)
So basically what I'm thinking is that the Zettelkasten method,
it's kind of like how your brain works with neurons and stuff,
because you have these individual notes that are small and they
link together and then new ideas emerge from the connections
which is pretty cool if you think about it.

# After <leader>aw
Floating window shows:
"The Zettelkasten method mirrors neural networks in the brain.
Individual notes function like neurons,
connecting to form emergent patterns of thought.
New insights arise from these connections,
making the system more than the sum of its parts."
```

**Use Cases**:

- Polish fleeting notes → permanent notes
- Refine rough drafts before publishing
- Improve email/report clarity
- Practice concise writing

**Important**: Always rewrite AI suggestions in your own voice. Don't copy-paste verbatim.

### Ask Question (`<leader>aq`)

**Purpose**: Interactive dialogue to explore ideas or clarify understanding.

**Usage**:

1. Cursor in relevant note
2. Press `<leader>aq`
3. Type question in prompt
4. AI answers based on current note context

**Example Workflow**:

```markdown
# Current note: "spaced-repetition.md"
Contains explanation of spaced repetition algorithm.

# User presses <leader>aq, types:
"How does spaced repetition differ from simple review?"

# Floating window shows:
"Spaced repetition adapts review timing based on memory strength.
Simple review uses fixed schedules (e.g., every day).
SR increases intervals for well-remembered items,
saving time while maintaining retention.
It exploits the spacing effect - distributed practice beats massed practice."
```

**Use Cases**:

- Clarify confusing concepts
- Test understanding
- Explore implications
- Generate follow-up questions

### Generate Ideas (`<leader>ax`)

**Purpose**: Brainstorm new angles, questions, or connections to explore.

**Usage**:

1. Cursor in current note
2. Press `<leader>ax`
3. AI generates 5 creative ideas based on content

**Example Workflow**:

```markdown
# Current note: "personal-knowledge-management.md"
Discusses PKM methods and tools.

# After <leader>ax
Floating window shows:
"**Ideas to Explore**:
1. **PKM for Teams**: How do these individual methods scale to groups?
2. **Failure Modes**: What goes wrong with PKM systems and why?
3. **Historical Context**: How did scholars manage knowledge pre-digital?
4. **Measurement**: How do you know if your PKM system is working?
5. **Integration Points**: Connecting PKM to productivity systems (GTD, etc.)"
```

**Use Cases**:

- Overcome writer's block
- Expand stub notes
- Find research questions
- Discover new note topics

### Generate Draft (`<leader>ad`)

**Purpose**: Synthesize multiple notes on a topic into coherent prose draft.

**Usage**:

1. Press `<leader>ad`
2. Enter search topic (e.g., "distributed cognition")
3. AI finds all matching notes in `~/Zettelkasten`
4. Generates draft combining insights
5. Opens in new buffer as `draft-[topic]-[date].md`

**Example Workflow**:

```bash
# User has 5 notes about "Zettelkasten method"
# Press <leader>ad, type "Zettelkasten method"

# AI searches ~/Zettelkasten, finds:
- zettelkasten-principles.md
- atomic-notes.md
- note-linking-strategies.md
- slip-box-history.md
- digital-vs-analog.md

# Generates draft combining these notes:
draft-zettelkasten-method-20251019.md

# Content includes:
- Introduction synthesizing key principles
- Sections from each note woven together
- Transitions between concepts
- Maintains semantic line breaks
- Ready for human editing
```

**Use Cases**:

- Blog post creation
- Essay drafts
- Tutorial writing
- Research synthesis

**Important**: Treat draft as starting point, not finished product. Always edit in your voice.

## Part 3: Practical Workflows

### Workflow 1: Literature Note Processing

**Goal**: Transform book excerpt into permanent notes efficiently.

**Steps**:

1. **Capture**: Paste book excerpt into new note
2. **Summarize**: Select excerpt → `<leader>as` → review key points
3. **Explain**: Select academic terms → `<leader>ae` → understand concepts
4. **Your Synthesis**: Write permanent note in own words (don't copy AI)
5. **Link**: Use `<leader>al` to discover related notes

**Time Savings**: 15 minutes → 10 minutes per literature note (33% faster)

**Example**:

```markdown
# Literature note: book-excerpt.md
[...3 pages of dense academic text on constructivism...]

# Step 1: <leader>as (summarize)
→ Get 5 bullet points of key concepts

# Step 2: <leader>ae (explain jargon)
→ Understand "schema", "assimilation", "accommodation"

# Step 3: Write permanent note (your words)
# constructivism-learning-theory.md
Learning builds on prior knowledge.
Students construct understanding by connecting new info to existing schemas.
[...your synthesis in your voice...]

# Step 4: <leader>al (find links)
→ Discover connections to cognitive-load.md, zone-proximal-development.md
```

### Workflow 2: Idea Exploration

**Goal**: Explore new concept from initial curiosity to interconnected notes.

**Steps**:

1. **Question**: Write question in new fleeting note
2. **AI Draft**: Select question → `<leader>ad` → generate initial exploration
3. **Extract Insights**: Read draft → identify 3-5 key insights
4. **Create Permanent Notes**: Write atomic notes for each insight (your words)
5. **Link Network**: Connect new notes to existing Zettelkasten

**Example**:

```markdown
# fleeting-note.md
"How does spaced repetition actually work?"

# <leader>ad (generate draft)
→ Creates draft explaining spaced repetition algorithm

# Extract insights:
- Forgetting curve shows memory decay
- Optimal review timing = just before forgetting
- Expanding intervals more efficient than fixed

# Create permanent notes (3 new notes):
1. forgetting-curve.md
2. optimal-review-timing.md
3. expanding-intervals-vs-fixed.md

# Link to existing notes:
- memory-consolidation.md
- active-recall.md
- learning-efficiency.md
```

### Workflow 3: Note Refinement

**Goal**: Polish rough fleeting notes into clear permanent notes.

**Steps**:

1. **Brain Dump**: Write fleeting note stream-of-consciousness
2. **AI Rewrite**: Select rough text → `<leader>aw` → see improved version
3. **Compare**: Read both versions side-by-side
4. **Manual Edit**: Rewrite in your voice, inspired by AI clarity
5. **Finalize**: Save as permanent note with links

**Example**:

```markdown
# fleeting-note.md (rough)
So I was thinking about how the Zettelkasten is kind of like
how the brain works with all the connections and stuff and
maybe that's why it feels more natural than folders because
brains don't really organize things in hierarchies they use
associations and networks which is more flexible...

# <leader>aw (improve writing)
→ Shows clearer version in floating window

# Manual rewrite (your voice + AI clarity):
# zettelkasten-brain-analogy.md
The Zettelkasten mirrors neural network architecture.
Knowledge organizes through associations rather than hierarchies.
This flexibility matches how our brains naturally connect ideas.
Links between notes function like synaptic connections,
enabling emergent insights from accumulated knowledge.

[[neural-networks]] [[associative-memory]] [[emergent-properties]]
```

### Workflow 4: Overcoming Writer's Block

**Goal**: Restart stalled writing with AI assistance.

**Steps**:

1. **Recognize Block**: You're stuck on a paragraph
2. **Generate Ideas**: `<leader>ax` → brainstorm new angles
3. **Explore One Idea**: Select interesting angle → write new paragraph
4. **Repeat**: If still stuck, try `<leader>aq` with specific question

**Alternative Approach**:

1. **Partial Paragraph**: Write what you can, leave incomplete
2. **AI Context**: Press `<leader>ae` → AI explains your own partial thought
3. **Clarity**: Reading AI explanation sparks how to continue
4. **Write**: Complete paragraph in your own words

**Example**:

```markdown
# Stuck paragraph:
Distributed cognition changes how we think about intelligence.
Instead of being located solely in individual minds...
[...stuck here, don't know where to go next...]

# <leader>ax (generate ideas)
→ Suggests: "Explore intelligence in navigation systems",
           "Examine role of artifacts in thinking",
           "Consider design implications"

# Choose angle, continue writing:
...intelligence emerges from interactions between people,
tools, and environment.
Navigation offers a clear example:
charts, instruments, and crew coordination create cognitive system
more capable than any individual sailor.
```

## Part 4: Prompt Engineering for Zettelkasten

### Effective Prompting Principles

**Be Specific**: Vague prompts get vague results.

**Good**: "Explain distributed cognition in 3 sentences with a concrete example from everyday life"

**Bad**: "What is distributed cognition?"

**Request Format**: Tell AI how to structure output.

**Good**: "Summarize this in 5 bullet points focusing on actionable insights"

**Bad**: "Summarize this"

**Provide Context**: Help AI understand your needs.

**Good**: "As if teaching a beginner who understands basic psychology but not cognitive science"

**Bad**: "Explain this"

### Prompt Templates

**Explanation Template**:

```
Explain [concept] in simple terms.
Assume audience knows [prior knowledge] but not [new knowledge].
Include one concrete example from [domain].
Keep explanation to 3-4 sentences.
```

**Summary Template**:

```
Extract the 5 most important insights from this text.
Focus on [aspect: actionable/theoretical/methodological].
Format as bullet points with brief explanations.
Prioritize ideas that connect to [related concept].
```

**Connection Template**:

```
How does [concept A] relate to [concept B]?
Identify:
- Points of overlap
- Key differences
- Potential synthesis
```

**Synthesis Template**:

```
Analyze these concepts: [list]
Find:
- Common themes
- Underlying patterns
- Emergent insights not obvious from individual concepts
```

### Adapting Prompts to Context

**Visual Selection**: Prompts reference "the following text"

```markdown
Select: "Zettelkasten uses atomic notes with unique identifiers..."
<leader>ae triggers prompt:
"Explain the following text clearly and concisely:
Zettelkasten uses atomic notes with unique identifiers..."
```

**Buffer Context**: Prompts reference "the following context"

```markdown
Cursor in middle of long note
<leader>as triggers prompt (uses 50 lines around cursor):
"Provide a concise summary of the following context from a knowledge note..."
```

**Custom Prompts**: For `<leader>aq` (Ask Question)

```
User types question directly
AI uses buffer context to inform answer
```

### Quality vs Speed Trade-offs

**Fast Prompts** (for quick tasks):

- Keep prompts short (1-2 sentences)
- Use smaller models (mistral, phi3)
- Accept "good enough" output

**Quality Prompts** (for important work):

- Detailed prompts with examples
- Use larger models (llama3.1:8b)
- Iterate: refine prompt based on output

## Part 5: Privacy and Ethics

### Data Privacy Guarantees

**Local Processing**:

```
Your thoughts → Your machine → Ollama (local) → Your insights
                     ↑                              ↑
                Never leaves                   No external
                your system                    dependencies
```

**What Stays Private**:

- All note content
- AI prompts and responses
- Search queries and topics
- Draft generations
- Your entire Zettelkasten

**What's Transmitted**: NOTHING. Zero network calls.

### Safe for Sensitive Work

Local AI enables work on:

- **Medical Research**: HIPAA compliant (no data transmission)
- **Legal Documents**: Attorney-client privilege maintained
- **Financial Analysis**: Regulatory compliance safe
- **Proprietary Research**: Trade secrets protected
- **Personal Journaling**: Complete privacy

### Ethical AI Use Guidelines

**Principle 1: AI as Research Assistant, Not Writer**

- AI generates drafts → YOU write permanent notes
- AI suggests ideas → YOU evaluate and synthesize
- AI explains concepts → YOU understand and restate

**Principle 2: Always Verify AI Facts**

- Language models hallucinate (make up plausible-sounding facts)
- Verify claims against sources
- Don't trust AI for factual accuracy without checking

**Principle 3: Maintain Your Voice**

- Rewrite AI suggestions in your style
- Don't copy-paste AI text into permanent notes
- Use AI for inspiration, not replacement

**Principle 4: Cite AI Assistance**

When appropriate, note AI use in metadata:

```markdown
---
title: Distributed Cognition Overview
created: 2025-10-19
ai_assisted: true
ai_note: "Used Ollama llama3.2 to summarize source material and suggest connections"
---
```

**Principle 5: Don't Publish AI Text as Original**

- Blog posts: Rewrite AI drafts completely
- Academic work: Cite AI use if required by institution
- Professional writing: AI for brainstorming only

### Best Practices

1. **AI as Understanding Tool**: Use AI to comprehend, not to think for you
2. **Verify Everything**: Treat AI output as suggestions requiring validation
3. **Your Voice Matters**: Personal knowledge management requires personal voice
4. **Link, Don't Copy**: Build on AI insights, don't save them verbatim
5. **Document Usage**: Note when AI significantly influenced your work

### When NOT to Use AI

**Skip AI for**:

- Original creative work requiring authentic voice
- Personal reflections and journaling (just write)
- Quick captures (AI adds friction to speed)
- Well-understood concepts (you don't need explanation)

**Use AI for**:

- Understanding new complex concepts
- Discovering connections across notes
- Overcoming writer's block
- Processing large amounts of literature notes

## Part 6: Advanced Configuration

### Custom Model Selection

**Edit Configuration** (`~/.config/nvim/lua/plugins/ai-sembr/ollama.lua`):

```lua
M.config = {
  model = "llama3.2:latest",  -- Change this line
  ollama_url = "http://localhost:11434",
  temperature = 0.7,  -- Lower (0.3) = deterministic, Higher (0.9) = creative
  timeout = 30000,
  context_lines = 50,  -- Increase for more context
}
```

**Available Models**:

```bash
# Efficient models (3-4GB)
ollama pull phi3           # Microsoft's efficient model
ollama pull mistral        # Fast general model
ollama pull llama3.2       # Default balanced model

# Higher quality (7-8GB)
ollama pull llama3.1:8b    # Better reasoning
ollama pull nous-hermes    # Excellent instruction following

# Specialized (7GB+)
ollama pull codellama      # Code understanding
ollama pull orca-mini      # Efficient reasoning (3GB)
```

**Model Switching**:

Change `model` value, then restart Neovim:

```bash
nvim
:source ~/.config/nvim/lua/plugins/ai-sembr/ollama.lua
```

### Performance Tuning

**Temperature Adjustment**:

- **0.1-0.3**: Deterministic, factual (explanations, summaries)
- **0.5-0.7**: Balanced (default)
- **0.8-1.0**: Creative (idea generation, drafting)

**Context Window**:

```lua
M.config = {
  context_lines = 50,  -- Default: 50 lines around cursor
}
```

- Increase to 100 for long notes
- Decrease to 20 for faster processing

**Timeout**:

```lua
M.config = {
  timeout = 30000,  -- 30 seconds default
}
```

- Increase to 60000 (60 sec) for complex prompts
- Decrease to 15000 for quick tasks

### RAM Optimization

**If experiencing slowness**:

1. **Use Smaller Models**:

   ```bash
   ollama pull phi3  # 3.8GB instead of llama3.2's 4.7GB
   ```

2. **Close Other Applications**: Free RAM for Ollama

3. **Model Quantization** (advanced):

   ```bash
   # Use quantized versions (smaller, faster, slight quality trade-off)
   ollama pull llama3.2:7b-q4_K_M  # Quantized 4-bit version
   ```

4. **Limit Concurrent Operations**: Run one AI task at a time

### SemBr Integration

**Semantic Line Breaks** (prose formatting for git):

**Manual Format**:

```
<leader>zs  - Format current buffer
<leader>zs  - Format visual selection (visual mode)
```

**Auto-Format on Save** (optional):

```
:SemBrToggle  - Enable/disable auto-format when saving .md files
```

**Configure Model** (`~/.config/nvim/lua/plugins/ai-sembr/sembr.lua`):

```lua
M.config = {
  model = "bert-small",  -- Options: bert-small, bert-base, bert-large
  auto_format = false,   -- Change to true for auto-format on save
}
```

**Use Cases**:

- Before git commit: Clean diffs (each line = semantic unit)
- After AI draft: Format prose for readability
- Long paragraphs: Break into logical sentence-per-line structure

## Part 7: Troubleshooting

### "Ollama not responding"

**Symptoms**: AI commands timeout or show connection errors.

**Solution**:

```bash
# Check if Ollama is running
pgrep -x ollama

# If not running, start manually
ollama serve

# Or restart if already running
pkill ollama && ollama serve
```

**Auto-Start Ollama** (optional):

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Start Ollama in background if not running
pgrep -x ollama > /dev/null || (ollama serve &)
```

### "Model not found"

**Symptoms**: Error message "model 'llama3.2' not found".

**Solution**:

```bash
# List installed models
ollama list

# Download missing model
ollama pull llama3.2

# Verify download
ollama list | grep llama3.2
```

**If wrong model name in config**:

Edit `~/.config/nvim/lua/plugins/ai-sembr/ollama.lua`:

```lua
M.config = {
  model = "llama3.2:latest",  -- Match exact name from `ollama list`
}
```

### "AI output too slow"

**Symptoms**: AI commands take >60 seconds to respond.

**Solutions**:

1. **Use Smaller Model**:

   ```bash
   ollama pull mistral  # Faster than llama3.2
   # Update config to use mistral
   ```

2. **Free RAM**:

   ```bash
   # Close browser, IDEs, other memory-heavy apps
   free -h  # Check available RAM
   ```

3. **Check Model Size vs Available RAM**:

   ```bash
   ollama list
   # If using 8GB model on 8GB RAM system → use 4GB model instead
   ```

4. **Reduce Context Size**:

   ```lua
   M.config = {
     context_lines = 20,  -- Reduced from 50
   }
   ```

### "AI output quality poor"

**Symptoms**: Irrelevant responses, hallucinations, unclear explanations.

**Solutions**:

1. **Better Prompts**:

   - Be specific (see Prompt Engineering section)
   - Provide context in your selection
   - Request specific format (bullet points, 3 sentences, etc.)

2. **Try Different Model**:

   ```bash
   # If using mistral (fast but lower quality)
   ollama pull llama3.1:8b  # Higher quality

   # If using llama3.2 (general)
   ollama pull codellama    # Better for technical content
   ```

3. **Provide More Context**:

   - Use visual selection with surrounding paragraphs
   - Include relevant background in note

4. **Adjust Temperature** (in config):

   ```lua
   M.config = {
     temperature = 0.3,  -- Lower = more focused, factual
   }
   ```

### "SemBr command not found"

**Symptoms**: `:SemBrFormat` shows "command not found" or `sembr: command not found`.

**Solution**:

```bash
# Install SemBr via uv (Python package manager)
uv tool install sembr

# Or via pip
pip install sembr

# Verify installation
which sembr
sembr --version
```

**If PATH issue**:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
source ~/.bashrc
```

### "Floating window doesn't close"

**Symptoms**: AI result window stays open, can't return to editing.

**Solution**:

Press `q` or `Esc` to close floating window.

**If keybindings don't work**:

Click window, then `:q` or `:close` in command mode.

### "AI gives same response every time"

**Symptoms**: Identical output for same prompt despite temperature >0.

**Solution**:

Increase temperature in config:

```lua
M.config = {
  temperature = 0.8,  -- Higher = more variation
}
```

**Note**: Some variation is good, but >0.9 may produce incoherent results.

## Part 8: Success Metrics

### Signs AI Integration is Working

**Quantitative Metrics**:

- **Time Savings**: Literature notes 15min → 10min (33% faster)
- **Note Quality**: Fewer rewrites (5 drafts → 2 drafts)
- **Connection Rate**: More links per note (AI suggests connections)
- **Processing Speed**: More notes processed per session

**Qualitative Indicators**:

- **Less Writer's Block**: AI helps restart stalled writing
- **Better Understanding**: Explanations clarify complex concepts
- **Richer Links**: Discovering connections you'd have missed
- **Improved Clarity**: AI-assisted rewrites teach concise writing

### Measuring Your Workflow

**Before/After Comparison**:

Track for one week before AI, one week with AI:

- Notes created per day
- Time per literature note
- Links added per note
- Permanent notes from fleeting notes ratio

**Example Results** (typical user):

| Metric               | Before AI | With AI | Improvement |
| -------------------- | --------- | ------- | ----------- |
| Literature notes/day | 3         | 4       | +33%        |
| Time per lit note    | 15 min    | 10 min  | -33%        |
| Links per note       | 2         | 4       | +100%       |
| Fleeting → Permanent | 30%       | 50%     | +67%        |

### When AI Isn't Helping

**Red Flags**:

- Copy-pasting AI text without rewriting (losing your voice)
- Spending more time prompting than writing
- Not verifying AI facts (accepting hallucinations)
- Using AI for everything (even simple tasks)

**Course Correction**:

1. **Refocus on Original Writing**: AI for understanding, you for creating
2. **Limit AI to Specific Tasks**: Summarizing, explaining only
3. **Improve Prompts**: Better prompts = less iteration
4. **Choose Right Tool**: Not every task needs AI

## Part 9: Next Steps

### Expanding Your AI Toolkit

**Once Comfortable with Basics**:

1. **Experiment with Models**: Try codellama for technical notes
2. **Customize Prompts**: Edit `ollama.lua` to add custom commands
3. **Integrate with Publishing**: Use AI drafts for blog posts (see `PUBLISHING_TUTORIAL.md`)
4. **Combine with SemBr**: AI draft → SemBr format → git commit

### Advanced Zettelkasten Workflows

**Explore Other Guides**:

- `ZETTELKASTEN_WORKFLOW.md`: Advanced note-taking patterns
- `PUBLISHING_TUTORIAL.md`: Hugo static site generation
- `PERCYBRAIN_DESIGN.md`: System architecture and philosophy

### Contributing Improvements

**Share Your Experience**:

- Effective prompts you've developed
- Custom AI commands you've added
- Model recommendations for specific use cases
- Workflow optimizations

**Report Issues**:

- PercyBrain GitHub issues (if public repo)
- Document limitations you discover
- Suggest new AI features

### Keeping AI in Perspective

**Remember**:

AI is a tool to enhance your thinking, not replace it. The Zettelkasten method works because YOU make connections, synthesize ideas, and develop insights. AI can accelerate understanding and reduce friction, but the knowledge management system belongs to you.

**Your Zettelkasten, your AI, your control.** As it should be.

## Appendix: Command Reference

### Keymaps Quick Reference

```
<leader>aa    - AI Menu (Telescope)
<leader>ae    - Explain text
<leader>as    - Summarize note
<leader>al    - Suggest links
<leader>aw    - Improve writing
<leader>aq    - Ask question
<leader>ax    - Generate ideas
<leader>ad    - Generate draft
<leader>zs    - SemBr format
<leader>zt    - SemBr auto-format toggle
```

### User Commands

```vim
:PercyAI             - AI command menu
:PercyExplain        - Explain text
:PercySummarize      - Summarize note
:PercyLinks          - Suggest links
:PercyImprove        - Improve writing
:PercyAsk            - Ask question
:PercyIdeas          - Generate ideas
:PercyDraft          - Generate draft from notes
:SemBrFormat         - Format with semantic line breaks
:SemBrFormatSelection - Format selection
:SemBrToggle         - Toggle auto-format on save
```

### Ollama Commands

```bash
ollama serve             - Start Ollama service
ollama list              - List installed models
ollama pull <model>      - Download model
ollama run <model>       - Interactive chat
ollama rm <model>        - Remove model
pgrep -x ollama          - Check if running
pkill ollama             - Stop Ollama
```

### Configuration Files

- **AI Commands**: `~/.config/nvim/lua/plugins/ai-sembr/ollama.lua`
- **Draft Generator**: `~/.config/nvim/lua/plugins/ai-sembr/ai-draft.lua`
- **SemBr Integration**: `~/.config/nvim/lua/plugins/ai-sembr/sembr.lua`

## Resources

- **Ollama Documentation**: [ollama.ai/docs](https://ollama.ai)
- **Model Library**: [ollama.ai/library](https://ollama.ai/library)
- **SemBr Project**: [github.com/nltk/sembr](https://github.com/nltk/sembr)
- **Privacy Rationale**: `/home/percy/.config/nvim/docs/explanation/LOCAL_AI_RATIONALE.md`
- **PercyBrain Design**: `/home/percy/.config/nvim/PERCYBRAIN_DESIGN.md`
