# Colored icon proposal

Base shapes: Tabler Icons 3.44.0, MIT License.

This package contains two color treatments for the same four SVG icons:

- `blue/`: single-color blue icons using `#2563EB`.
- `blue-accent/`: mostly blue icons with subtle accents:
  - primary blue `#2563EB`
  - cyan accent `#06B6D4`
  - success green `#16A34A`
  - code purple `#7C3AED`
  - pencil amber `#F59E0B`

Mappings are unchanged from the plugin paths:

- `assets/unity-testing.svg` ← Tabler `brand-unity`
- `skills/unity-check-compilation/assets/badge-check.svg` ← Tabler `file-check`
- `skills/unity-run-tests/assets/test-tube-diagonal.svg` ← Tabler `test-pipe`
- `skills/unity-write-tests/assets/file-pen-line.svg` ← Tabler `pencil-code`

The SVGs keep the original 24x24 viewBox, `fill="none"`, 2px stroke, round caps/joins. The only functional change is replacing `currentColor` with fixed SVG stroke colors.
