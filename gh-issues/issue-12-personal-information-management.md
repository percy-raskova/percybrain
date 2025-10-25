# Issue #12: Personal Information Management (Email + Finances)

**Labels:** `enhancement`, `pim`, `nice-to-have`, `low-priority`

## Description

Integrate personal information management tools into Neovim: TUI-based email client and personal finance/accounting system for complete life management within the Zettelkasten environment.

## Context

Current PercyBrain focus: Zettelkasten knowledge management + AI writing **Gap**: No personal life management (email, finances, tasks outside GTD) **Priority**: Nice-to-have, not critical for core Zettelkasten workflow

## Requirements

### 1. Email Integration (TUI-based)

Terminal email client integration:

- Email client selection (neomutt, aerc, himalaya)
- IMAP/SMTP configuration
- Email reading and composition
- Attachment handling
- Search and filtering
- Integration with Zettelkasten (email → note conversion)

### 2. Personal Finances/Accounting

TUI-based accounting system:

- Ledger CLI integration (plaintext accounting)
- hledger integration (alternative)
- Transaction entry and management
- Budget tracking
- Report generation
- Visualization (charts, graphs)
- Integration with Zettelkasten (financial notes)

### 3. Workflow Integration

Seamless PIM workflow:

- Quick email check without leaving Neovim
- Rapid transaction entry
- Email → Zettelkasten note conversion
- Financial data → research note integration
- Task extraction from emails (GTD integration)

### 4. UI Components

Consistent PercyBrain UI:

- Floating window for email/finance views
- Split window support
- Blood Moon theme integration
- Dashboard integration (show email/finance status)
- Notification system (new emails, budget alerts)

## Acceptance Criteria

- [ ] Email integration: One TUI client fully integrated (neomutt/aerc/himalaya)
- [ ] Finance integration: Ledger CLI or hledger working
- [ ] Workflow commands: `<leader>me` (email), `<leader>mf` (finance)
- [ ] Email → Note: Convert emails to Zettelkasten notes
- [ ] Transaction entry: Quick financial transaction recording
- [ ] Dashboard: Show email/finance status
- [ ] Documentation: Complete PIM user guide

## Implementation Tasks

### Phase 1: Email Client Integration (4-6 hours)

- [ ] Research TUI email clients (neomutt, aerc, himalaya)
- [ ] Implement email client detection
- [ ] Create email client launcher
- [ ] Build floating window for email view
- [ ] Add email configuration management
- [ ] Implement email → note conversion

### Phase 2: Finance Integration (4-6 hours)

- [ ] Research plaintext accounting (ledger, hledger)
- [ ] Implement accounting tool detection
- [ ] Create transaction entry interface
- [ ] Build report generation functionality
- [ ] Add budget tracking system
- [ ] Create financial visualization

### Phase 3: Workflow Integration (3-4 hours)

- [ ] Add `<leader>me` (email) keybinding
- [ ] Add `<leader>mf` (finance) keybinding
- [ ] Implement email → Zettelkasten conversion
- [ ] Add financial note templates
- [ ] Integrate with GTD (task extraction)
- [ ] Add dashboard status indicators

### Phase 4: UI Polish (2-3 hours)

- [ ] Apply Blood Moon theme to PIM views
- [ ] Create consistent UI patterns
- [ ] Add notification system (new emails, alerts)
- [ ] Implement status line integration
- [ ] Create keyboard shortcuts reference

### Phase 5: Documentation (2-3 hours)

- [ ] Write PIM user guide
- [ ] Document email client setup
- [ ] Document finance tool setup
- [ ] Create workflow examples
- [ ] Add troubleshooting section

## Testing Strategy

- **Email Testing**: Test with various email providers (Gmail, ProtonMail, custom)
- **Finance Testing**: Test transaction entry, report generation, accuracy
- **Conversion Testing**: Verify email → note and finance → note quality
- **UI Testing**: Test floating windows, splits, theme consistency
- **Integration Testing**: Verify GTD task extraction from emails
- **Performance**: Measure email/finance view launch times

## Success Metrics

- **Email Integration**: Read/compose/search working seamlessly
- **Finance Integration**: Transaction entry + reports functional
- **Conversion Quality**: Email → note preserves content/context
- **Launch Time**: \<3 seconds for email/finance views
- **User Adoption**: Clear documentation enables self-service
- **Stability**: No data loss or corruption

## Estimated Effort

15-20 hours

## Dependencies

**Email Clients** (choose one):

- neomutt (`sudo apt install neomutt` or `brew install neomutt`)
- aerc (`sudo apt install aerc` or `brew install aerc`)
- himalaya (`cargo install himalaya`)

**Finance Tools** (choose one):

- ledger (`sudo apt install ledger` or `brew install ledger`)
- hledger (`sudo apt install hledger` or `brew install hledger`)

**Neovim Dependencies**:

- Plenary (async job control)
- Telescope (search integration)
- Dashboard integration

## Related Files

- `lua/plugins/pim/email.lua` (NEW - email client integration)
- `lua/plugins/pim/finance.lua` (NEW - finance tool integration)
- `lua/config/keymaps/pim.lua` (NEW - PIM keybindings)
- `lua/percybrain/dashboard.lua` (UPDATE - add PIM status)
- `docs/how-to/PIM_GUIDE.md` (NEW - personal information management guide)
- `docs/reference/KEYBINDINGS_REFERENCE.md` (UPDATE - document PIM keybindings)

## Notes

- **Privacy**: TUI email clients offer better privacy than web interfaces
- **Plaintext Accounting**: Ledger/hledger use plain text files (version control friendly)
- **Zettelkasten Integration**: All PIM data can be converted to notes for long-term knowledge
- **Alternative**: Could use external tools with hotkeys instead of embedding
- **GTD Integration**: Email task extraction aligns with existing GTD Phase 1 (Capture)
