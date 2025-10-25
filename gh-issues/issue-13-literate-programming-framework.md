# Issue #13: Literate Programming Framework

**Labels:** `enhancement`, `documentation`, `literate-programming`, `low-priority`

## Description

Implement literate programming framework enabling code + documentation in wiki pages with code extraction (tangling), documentation weaving, and Hugo publishing integration.

## Context

Current PercyBrain: Zettelkasten for documentation, code in separate files **Gap**: No literate programming support (code within prose documentation) **Priority**: Not MVP, nice-to-have for advanced documentation workflows

## Requirements

### 1. Code Block Extraction (Tangling)

Extract executable code from markdown:

- Parse code blocks with language tags
- Extract to source files by language
- Support file path annotations (`file: path/to/file.lua`)
- Handle multiple code blocks → single file
- Preserve code block order
- Support append/prepend directives

### 2. Documentation Weaving

Generate documentation from code + prose:

- Combine markdown prose with code blocks
- Generate cross-references (code ↔ documentation)
- Create index of code definitions
- Support multiple output formats (HTML, PDF, markdown)
- Syntax highlighting in woven output

### 3. Zettelkasten Integration

Literate programming within Zettelkasten workflow:

- Wiki pages can contain executable code
- Code blocks tagged with file paths
- Tangling command: extract code from wiki page
- Weaving command: generate documentation
- Hugo frontmatter compatibility
- Publishing workflow integration

### 4. Build System Integration

Automated tangling and weaving:

- Pre-commit hook: verify code tangling succeeds
- CI/CD integration: auto-tangle and test
- Watch mode: auto-tangle on wiki save
- Build validation: ensure code compiles
- Test integration: run tests after tangling

### 5. Cross-Reference System

Navigate between code and documentation:

- Jump from code → source wiki page
- Jump from wiki → generated code files
- Find all wiki pages referencing code file
- Search code definitions across wiki pages
- Backlinks for literate programming

## Acceptance Criteria

- [ ] Tangling: Extract code from wiki pages to source files
- [ ] Weaving: Generate documentation from wiki pages
- [ ] Zettelkasten integration: Wiki pages with code blocks
- [ ] Build system: Pre-commit hook validates tangling
- [ ] Cross-references: Jump between code ↔ wiki pages
- [ ] Hugo publishing: Literate programming pages publish correctly
- [ ] Documentation: Complete literate programming user guide
- [ ] Examples: 3+ example wiki pages with executable code

## Implementation Tasks

### Phase 1: Code Block Parsing (3-4 hours)

- [ ] Parse markdown code blocks with language tags
- [ ] Extract file path annotations
- [ ] Build AST of code blocks per file
- [ ] Implement append/prepend logic
- [ ] Handle code block ordering
- [ ] Create unit tests for parser

### Phase 2: Tangling Implementation (4-5 hours)

- [ ] Implement code extraction algorithm
- [ ] Create file writing with directory creation
- [ ] Add tangling command (`<leader>lt` - literate tangle)
- [ ] Support multi-file tangling
- [ ] Add tangling validation (syntax check)
- [ ] Create error reporting UI

### Phase 3: Weaving Implementation (4-5 hours)

- [ ] Implement documentation generation
- [ ] Create cross-reference system
- [ ] Add code definition index
- [ ] Support multiple output formats
- [ ] Implement syntax highlighting
- [ ] Add weaving command (`<leader>lw` - literate weave)

### Phase 4: Zettelkasten Integration (3-4 hours)

- [ ] Integrate tangling into write-quit pipeline
- [ ] Add Hugo frontmatter support
- [ ] Create literate programming wiki templates
- [ ] Implement cross-reference navigation
- [ ] Add backlinks for code references
- [ ] Update dashboard with literate programming status

### Phase 5: Build System Integration (3-4 hours)

- [ ] Add pre-commit hook for tangling validation
- [ ] Create CI/CD tangling tests
- [ ] Implement watch mode (auto-tangle on save)
- [ ] Add build validation (compile checks)
- [ ] Integrate with test suite
- [ ] Create error recovery mechanisms

### Phase 6: Documentation & Examples (3-4 hours)

- [ ] Write literate programming user guide
- [ ] Create example wiki pages with code
- [ ] Document tangling/weaving workflow
- [ ] Add troubleshooting section
- [ ] Create video tutorial
- [ ] Document best practices

## Testing Strategy

- **Parsing Tests**: Verify code block extraction accuracy
- **Tangling Tests**: Test multi-file extraction, ordering, syntax
- **Weaving Tests**: Verify documentation generation quality
- **Integration Tests**: Test complete workflow (wiki → code → test)
- **Build Tests**: Verify pre-commit hooks and CI/CD integration
- **Cross-Reference Tests**: Test navigation accuracy
- **Performance**: Measure tangling/weaving speed for large wikis

## Success Metrics

- **Tangling Accuracy**: 100% code extraction correctness
- **Weaving Quality**: Generated docs preserve prose + code context
- **Build Integration**: Pre-commit hooks catch 95%+ errors
- **Cross-References**: Navigation works across 100+ wiki pages
- **Performance**: Tangle/weave \<5 seconds for typical wiki page
- **User Adoption**: 3+ users successfully using literate programming
- **Documentation Quality**: User guide enables self-service

## Estimated Effort

20-25 hours

## Dependencies

- Treesitter (for code parsing and syntax highlighting)
- Plenary (for file operations and async)
- Hugo (for publishing integration)
- Pandoc (optional: for multiple output formats)
- Existing Zettelkasten system
- Write-quit pipeline (for auto-tangling)

## Related Files

- `lua/plugins/zettelkasten/literate-programming.lua` (NEW - core implementation)
- `lua/percybrain/tangle.lua` (NEW - tangling engine)
- `lua/percybrain/weave.lua` (NEW - weaving engine)
- `lua/config/keymaps/workflows/zettelkasten.lua` (UPDATE - add literate programming commands)
- `tests/contract/literate_programming_spec.lua` (NEW - contract tests)
- `tests/capability/literate/tangling_spec.lua` (NEW - capability tests)
- `docs/how-to/LITERATE_PROGRAMMING_GUIDE.md` (NEW - user guide)
- `docs/explanation/LITERATE_PROGRAMMING_RATIONALE.md` (NEW - philosophy)
- `/home/percy/Zettelkasten/templates/literate.md` (NEW - literate wiki template)

## Notes

- **Inspiration**: Org-mode's literate programming, Jupyter notebooks
- **File Path Annotations**: Use comments in code blocks (e.g., `lua -- file: path/to/file.lua`)
- **Syntax**: ```` ```language file:path/to/file.lua ````
- **Workflow**: Wiki page → tangle → source files → compile/test → commit
- **Publishing**: Hugo publishes wiki page with code, source files deployed separately
- **Alternative**: Could use noweb-style syntax for more powerful tangling
- **Use Cases**: Complex algorithms, tutorials, documented libraries, research code

## Example

**Wiki Page** (`algorithms/quicksort.md`):

````markdown
# Quicksort Implementation

This is an efficient sorting algorithm using divide-and-conquer.

```lua file:src/sort/quicksort.lua
function quicksort(arr)
  if #arr <= 1 then return arr end
  -- implementation
end
```

```lua file:tests/sort/quicksort_spec.lua
describe("quicksort", function()
  it("sorts arrays", function()
    -- test
  end)
end)
```
````

**After Tangling**:

- `src/sort/quicksort.lua` created with quicksort function
- `tests/sort/quicksort_spec.lua` created with tests

**After Weaving**:

- HTML/PDF documentation with prose + highlighted code
- Cross-references: code → wiki page
