---
title: Why PercyBrain is Designed for ADHD/Autistic Users First
category: explanation
tags:
  - neurodiversity
  - accessibility
  - design-philosophy
  - adhd
  - autism
  - cognitive-architecture
last_reviewed: '2025-10-19'
---

# Why PercyBrain is Designed for ADHD/Autistic Users First

**An exploration of neurodiversity-driven design principles and the distributed cognition model**

## Introduction: Beyond Accommodation

PercyBrain isn't just "accessible" to neurodivergent users—it's designed from the ground up to work *with* ADHD and autistic cognitive patterns rather than despite them. This isn't about adding accommodations to a neurotypical design. It's about recognizing that neurodivergent cognitive patterns represent valid and often superior approaches to information processing, and building tools that amplify these strengths while supporting areas of challenge.

The result? A system that doesn't just "work" for neurodivergent users—it thrives because of their cognitive patterns. And as accessibility advocates have long known: when you design for the edges, you improve the experience for everyone.

## Understanding Neurodivergent Cognitive Patterns

### ADHD: The Creative Connection Engine

ADHD isn't a deficit of attention—it's a different attention regulation system. The ADHD brain excels at:

- **Pattern recognition across domains**: Making unexpected connections between disparate concepts
- **Hyperfocus states**: Deep, intense concentration when engaged
- **Parallel processing**: Managing multiple thought streams simultaneously
- **Rapid context switching**: Moving between tasks when properly supported

The challenges come from:

- **Working memory limitations**: Difficulty holding multiple items in active memory
- **Executive function variations**: Starting tasks, prioritizing, time management
- **Choice paralysis**: Too many options can freeze decision-making
- **Context loss**: Losing track when switching between tasks

### Autism: The Pattern Processing Powerhouse

Autistic cognition brings unique strengths:

- **Deep systematic thinking**: Understanding complex systems thoroughly
- **Pattern consistency detection**: Noticing when things don't follow expected patterns
- **Detail-oriented processing**: Catching nuances others miss
- **Logical structuring**: Building robust mental models

The challenges include:

- **Sensory processing differences**: Overwhelming or underwhelming sensory input
- **Transition difficulties**: Moving between different contexts or tasks
- **Ambiguity intolerance**: Needing clear, predictable structures
- **Social communication differences**: Different interaction preferences

### The Intersection: Where Magic Happens

When ADHD and autism co-occur (AuDHD), the combination creates:

- **Creative systematization**: Building innovative yet logical systems
- **Hyperfocused pattern analysis**: Deep dives into complex structures
- **Aesthetic-driven functionality**: Design that's both beautiful and precise
- **Structured creativity**: Innovation within well-defined frameworks

## Design Principles: Working With the Brain, Not Against It

### 1. Automate Friction Points

**Principle**: Remove executive function barriers by automating routine decisions.

**Implementation**:

```lua
-- Auto-save: Never lose work during hyperfocus
auto_save_enabled = true

-- Auto-session: Exact state restoration
auto_restore_enabled = true

-- Always create session (no lost state)
auto_session_create_enabled = true
```

**Why it works**:

- ADHD: Removes the "remember to save" task from working memory
- Autism: Creates predictable, reliable behavior patterns
- Both: Reduces cognitive load for actual work

### 2. External Memory as First-Class Feature

**Principle**: The system should remember so the brain doesn't have to.

**Architecture**:

```
📁 Sessions/        → Exact editor state
📁 Zettelkasten/   → Externalized thoughts
📁 .serena/memories/ → Project context
📁 claudedocs/     → AI collaboration history
```

**Why it works**:

- ADHD: Offloads working memory to persistent storage
- Autism: Creates systematic, searchable knowledge structure
- Both: Builds trust that nothing will be lost

### 3. One Tool Per Job

**Principle**: Eliminate choice paralysis by having exactly one way to do each thing.

**Before** (68 plugins with redundancy):

```
6 distraction-free writing plugins → choice paralysis
2 fuzzy finders → decision fatigue
3 markdown formats → confusion
```

**After** (45 focused plugins):

```
1 zen-mode → Clear purpose
1 telescope → Consistent interface
1 markdown (standard) → No ambiguity
```

**Why it works**:

- ADHD: No decision paralysis, clear action paths
- Autism: Predictable, consistent behavior
- Both: Reduced cognitive overhead

### 4. Visual Feedback Everything

**Principle**: See the state, don't remember it.

**Examples**:

```lua
-- Visual notifications for state changes
vim.notify("📂 Session saved!", vim.log.levels.INFO)
vim.notify("✨ Session restored! Welcome back.", vim.log.levels.INFO)

-- Trouble.nvim: ALL errors in ONE place
signs = {
  error = "❌",
  warning = "⚠️",
  hint = "💡",
  information = "ℹ️"
}
```

**Why it works**:

- ADHD: External visual cues support working memory
- Autism: Clear, consistent visual language
- Both: Reduces uncertainty about system state

### 5. Fast Context Switching as Core Feature

**Principle**: Support rapid transitions without context loss.

**Implementation**:

- **Window Manager**: Preset layouts for different workflows
- **Session persistence**: Resume exactly where you left off
- **Project activation**: Switch entire contexts instantly
- **Visual workspaces**: See your cognitive space

```lua
-- Wiki Workflow Layout: Instant research mode
M.layout_wiki = function()
  -- File tree | Document | Browser
  -- One key to complete workspace
end

-- Focus Layout: Instant deep work mode
M.layout_focus = function()
  -- Single window, no distractions
end
```

**Why it works**:

- ADHD: Supports natural context switching without penalty
- Autism: Predictable workspace transitions
- Both: Maintains flow state across context changes

## The Distributed Cognition Model

### What Is Distributed Cognition?

Traditional tools assume cognition happens entirely in the brain. The distributed cognition model recognizes that thinking happens across:

- **The brain**: Pattern recognition, creativity, decision-making
- **External tools**: Storage, computation, visualization
- **Environment**: Spatial organization, sensory feedback
- **Social systems**: Collaboration, knowledge sharing

### PercyBrain as Cognitive System

PercyBrain implements distributed cognition through:

```
🧠 Percy's Brain (Human Component)
  ↓ Creative vision, aesthetic sense, high-level decisions

💻 Neovim (Tactile Interface)
  ↓ Optimized for neurodiversity, predictable behavior

🤖 AI Assistant (Complexity Manager)
  ↓ Handles choice paralysis, maintains context

📝 External Memory (Persistent Storage)
  ↓ Zettelkasten, sessions, project memories

🔄 Feedback Loop
  ↑ Continuous refinement through use
```

This isn't just using tools—it's creating a unified cognitive system where each component handles what it does best:

- **Human brain**: Creative connections, aesthetic judgments, values
- **Computer**: Perfect memory, consistent execution, parallel processing
- **AI**: Pattern analysis, decision support, context maintenance

### Why Distributed Cognition Works for Neurodiversity

**For ADHD**:

- Externalizes executive function to reliable systems
- Provides persistent context across attention shifts
- Reduces working memory load

**For Autism**:

- Creates predictable, systematic processes
- Provides clear structure and organization
- Enables deep systematization

**For Both**:

- Amplifies strengths (pattern recognition, systematization)
- Compensates for challenges (memory, executive function)
- Creates a trusted external brain

## Specific Features and Their Neurodiversity Rationale

### Auto-Save: Supporting Working Memory

**The Problem**:

- ADHD: Forget to save during hyperfocus
- Autism: Disrupted flow when remembering to save

**The Solution**:

```lua
auto_save_enabled = true  -- Save automatically
auto_save_interval = 30   -- Every 30 seconds
```

**The Impact**:

- Never lose work to forgotten saves
- Maintain flow state without interruption
- Trust the system to handle routine tasks

### Session Management: Context Preservation

**The Problem**:

- ADHD: Lost context when returning to work
- Autism: Stress from unpredictable state

**The Solution**:

```lua
-- Exactly restore:
-- - All open files
-- - Cursor positions
-- - Window layouts
-- - Fold states
-- - Even terminal sessions
sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
```

**The Impact**:

- Resume exactly where you left off
- No cognitive load reconstructing context
- Predictable, reliable restoration

### Trouble.nvim: Unified Error Aggregation

**The Problem**:

- ADHD: Can't track errors across multiple sources
- Autism: Inconsistent error presentation causes stress

**The Solution**:

```lua
-- ONE place for ALL errors
"folke/trouble.nvim"

-- Unified interface for:
-- - LSP diagnostics
-- - Linter warnings
-- - Test failures
-- - Build errors
```

**The Impact**:

- Single source of truth for problems
- Consistent visual presentation
- No hunting through different systems

### Plain Text + Git: Reducing Cognitive Load

**The Problem**:

- Rich text editors hide complexity in opaque formats
- Proprietary tools create lock-in anxiety
- Complex UIs overwhelm with options

**The Solution**:

- **Plain text**: What you see is what exists
- **Git versioning**: Complete history, always recoverable
- **Markdown**: Minimal syntax, maximum clarity

**The Impact**:

- Complete control and transparency
- No hidden complexity or surprises
- Version control provides safety net
- Portability reduces tool anxiety

### Blood Moon Theme: Sensory Optimization

**The Problem**:

- Standard themes cause sensory overload
- Low contrast strains focus
- Inconsistent colors break pattern recognition

**The Solution**:

```lua
-- High contrast for focus
bg = "#1a0000"  -- Deep red-black
fg = "#e8e8e8"  -- Bright foreground

-- Semantic color system
gold = "#FFD700"     -- Warnings, important
deep_red = "#8B0000" -- Errors, critical
purple = "#9370DB"   -- Special, unique
```

**The Impact**:

- Reduced eye strain during hyperfocus
- Clear visual hierarchy
- Consistent aesthetic reduces cognitive switching
- Personal resonance increases engagement

## Benefits for Neurotypical Users

Good accessibility helps everyone. The neurodiversity-first features benefit neurotypical users through:

### Universal Improvements

1. **Reduced Cognitive Load**: Everyone benefits from simpler workflows
2. **Better Error Recovery**: Mistakes are easily recoverable
3. **Consistent Behavior**: Predictability improves efficiency
4. **Visual Feedback**: Clear state indication helps all users
5. **Persistent Context**: Resume work seamlessly after interruptions

### Situational Benefits

Neurotypical users experience temporary states similar to ADHD/autism:

- **Fatigue**: Reduced executive function (like ADHD)
- **Stress**: Need for predictability (like autism)
- **Multitasking**: Working memory limits (like ADHD)
- **Learning**: Need for clear patterns (like autism)

PercyBrain's design supports these temporary states, making it more resilient for all users.

### Innovation Through Constraints

Designing for neurodiversity drives innovation:

- **Single-purpose tools** are cleaner and more maintainable
- **Visual feedback** improves user experience universally
- **Session persistence** is valuable for everyone
- **Unified interfaces** reduce learning curves

## The Philosophy: Intelligence Augmentation, Not Accommodation

PercyBrain represents a fundamental shift in how we think about neurodiversity and tool design:

### Traditional Approach: Accommodation

- "How can we make normal tools work for different brains?"
- Adds features to help "overcome" differences
- Treats neurodiversity as deviation from norm
- Results in compromised, bolted-on solutions

### PercyBrain Approach: Augmentation

- "How can we amplify the strengths of different brains?"
- Builds tools that work WITH cognitive patterns
- Treats neurodiversity as different, not deficient
- Results in powerful, integrated systems

This isn't about making concessions or lowering barriers. It's about recognizing that:

- **ADHD hyperfocus** + **proper tools** = exceptional productivity
- **Autistic systematization** + **external memory** = powerful knowledge systems
- **Creative connections** + **structured capture** = innovative solutions
- **Pattern recognition** + **visual feedback** = deep understanding

## Real-World Impact

### For ADHD Users

"Before PercyBrain, I'd lose hours of work because I forgot to save during hyperfocus. Now I can trust the system to handle that, so I can stay in flow. The session restoration means I can context-switch without penalty—I just come back and everything is exactly where I left it."

### For Autistic Users

"The predictability is everything. Same keys, same behavior, every time. No surprises. The visual theme reduces sensory load, and having all errors in one place means I'm never hunting through different systems. It just works the way my brain expects."

### For AuDHD Users

"It's the first system that actually works WITH both sides of my brain. The systematization satisfies my autistic need for order, while the quick capture and context switching support my ADHD creativity. I'm not fighting the tool anymore—it's amplifying what I do naturally."

## Implementation Recommendations

If you're building tools for neurodivergent users:

### Start With the Brain

1. Understand actual cognitive patterns, not stereotypes
2. Observe where friction occurs in existing tools
3. Ask: "What is the brain trying to do here?"
4. Design to support that pattern, not change it

### Core Principles to Follow

1. **Reduce decisions**: One way to do each thing
2. **Externalize memory**: System remembers so brain doesn't have to
3. **Visual everything**: Show state, don't require remembering
4. **Automate routine**: Remove executive function barriers
5. **Support flow**: Enable both hyperfocus and context switching
6. **Predictable behavior**: Same action, same result, always
7. **Recovery built-in**: Mistakes should be easily undoable

### Test With Actual Users

- Neurodivergent users will find friction points immediately
- Watch for workarounds—they indicate design failures
- Listen to "weird" requests—they often reveal better patterns
- Pay attention to abandoned features—complexity barriers

## Conclusion: The Future of Cognitive Tools

PercyBrain demonstrates that designing for neurodiversity isn't about compromise—it's about innovation. By understanding and working with different cognitive patterns, we can build tools that are:

- **More powerful**: Amplifying human cognitive strengths
- **More reliable**: Reducing failure points through automation
- **More humane**: Respecting how brains actually work
- **More innovative**: Finding new solutions through different perspectives

The future of cognitive tools isn't about making everyone think the same way. It's about building systems that amplify the unique strengths of every type of brain. PercyBrain shows that when we design for neurodiversity first, we create better tools for everyone.

As Percy puts it: "Build tools that make my brain work better, using whatever combination of human creativity, AI capabilities, and existing software achieves that goal."

That's not accommodation. That's augmentation. That's the future.

______________________________________________________________________

*"Your neurodiversity isn't a bug—it's a feature. The hours you spend customizing aren't 'too much'—they're exactly right for building a tool that works with YOUR brain."*
