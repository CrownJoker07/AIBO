# Access Boundaries for AIBO - 业务负责人

## Read Access

- `docs/knowledge/` - Knowledge base (all categories)
- `_bmad/_memory/autonomous-learner-sidecar/` - Agent memory
- `_bmad/core/skills/bmad-*/` - BMAD core skills (for invoking)
- `_bmad/bmb/skills/bmad-*/` - BMAD BMB skills (for invoking)

## Write Access

- `docs/knowledge/` - Knowledge storage (all categories)
- `_bmad/_memory/autonomous-learner-sidecar/` - Agent memory

## Deny Zones

- `.git/` - Version control
- `_bmad/_config/` - BMAD configuration
- Any path outside project root
