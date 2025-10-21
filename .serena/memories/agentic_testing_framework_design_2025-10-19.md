# Agentic Testing Framework Design - PercyBrain

**Date**: 2025-10-19 **Context**: Revolutionary testing approach using Claude Code as simulated user in CI/CD

## Core Philosophy

**Traditional Testing**: "Does the code work?" **Agentic Testing**: "Can a user successfully complete real workflows?"

This extends PercyBrain's "Active Testing Philosophy" - validating through actual usage, not just code correctness.

## Architecture

### GitHub Action Integration

- Runs on PR, push to main, scheduled daily
- Sets up complete PercyBrain environment
- Executes Claude Code with Neovim MCP
- Agent attempts rigorously defined workflows
- Generates UX-focused test reports

### Workflow Test Structure

```yaml
name: "Workflow Name"
persona: "User type and experience level"
difficulty: "beginner|intermediate|advanced"
success_criteria: [list of requirements]
workflow: [step-by-step user journey]
validation: [automated checks]
report_to_agent: [subjective questions]
```

### Key Workflows to Test

1. **First Note Creation** (beginner):

   - Tests: Onboarding experience, template clarity
   - Validates: File creation, frontmatter structure

2. **Linking Notes** (intermediate):

   - Tests: Discovery UX, navigation, backlinks
   - Validates: Markdown links, gf navigation, bidirectional detection

3. **AI-Assisted Writing** (intermediate):

   - Tests: AI integration, streaming UX, editing workflow
   - Validates: Ollama integration, content quality

4. **Hugo Publishing** (advanced):

   - Tests: Frontmatter validation, publishing workflow
   - Validates: Hugo compatibility, error messages

5. **Complex Refactoring** (advanced):

   - Tests: Bulk operations, batch editing
   - Validates: Data integrity, undo capability

## Success Metrics

**Quantitative**:

- Workflow completion rate: ≥90%
- Error recovery success: ≥95%
- Performance: Each workflow \<5min

**Qualitative** (Agent-reported):

- User clarity rating: ≥8/10
- Documentation sufficiency: ≥85%
- Friction point count: \<3 per workflow

## What This Reveals

**Traditional Tests Miss**:

- Confusing UX that technically "works"
- Missing discoverability (hidden features)
- Cryptic error messages
- Workflow friction and cognitive load

**Agentic Tests Detect**:

- "This worked but I didn't understand why"
- "I got stuck and documentation didn't help"
- "Error message didn't explain how to fix it"
- "I had to guess the correct approach"

## Report Structure

### Agent Commentary Sections:

1. **Experience Summary**: What the workflow felt like
2. **Friction Points**: Where confusion or difficulty occurred
3. **Suggestions**: Specific improvements to try
4. **Surprising Discoveries**: Unexpected delights or failures

### Automated Validation:

1. **File System Checks**: Did files get created correctly?
2. **Content Validation**: Proper frontmatter, links, formatting?
3. **State Verification**: System in expected state after workflow?
4. **Performance Metrics**: Timing, resource usage

## Integration with Existing Testing

**Unit Tests** (Plenary):

- Fast, deterministic
- Validate individual functions
- Run on every commit

**Agentic Tests** (Claude Code):

- Slower, more comprehensive
- Validate user experience
- Run daily or on major changes

**Both Required**: Unit tests catch regressions, agentic tests catch UX degradation

## Implementation Files

```
.github/
├── workflows/
│   └── agentic-testing.yml          # GitHub Action definition
├── agentic-tests/
│   ├── config.json                   # Agent configuration
│   └── workflows/
│       ├── 01-first-note-creation.yaml
│       ├── 02-linking-notes.yaml
│       ├── 03-ai-assisted-writing.yaml
│       ├── 04-hugo-publishing.yaml
│       ├── 05-complex-refactoring.yaml
│       └── 06-bulk-operations.yaml
└── scripts/
    ├── setup-test-environment.sh     # Deploy PercyBrain to runner
    └── generate-ux-report.js         # Parse agent results

docs/testing/
└── AGENTIC_TESTING_GUIDE.md         # Philosophy and usage
```

## Future Enhancements

1. **Visual Regression Testing**: Screenshots comparison
2. **Performance Profiling**: Track workflow speed over time
3. **Accessibility Testing**: Screen reader simulation
4. **Multi-Persona Testing**: Different user types simultaneously
5. **Failure Recovery Testing**: How well does system handle errors?

## Key Insight

This approach treats PercyBrain as a **product users experience**, not just **code that runs**.

The agent becomes our most rigorous user, documenting every moment of confusion, every unclear message, every point of friction - insights traditional testing can never reveal.

## Next Steps

1. Create workflow YAML definitions
2. Implement GitHub Action
3. Set up test environment provisioning
4. Build report generation system
5. Document testing philosophy

## Success Criteria for Framework Itself

The agentic testing framework is successful when:

- Catches UX regressions traditional tests miss
- Provides actionable improvement suggestions
- Reports are read and acted upon by team
- User satisfaction metrics improve over time
- Framework becomes trusted quality gate
