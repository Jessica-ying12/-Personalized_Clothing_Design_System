"""
Skill Build Script - Single Source of Truth (SSOT) for AI tool configurations.

Reads skill definitions from docs/skills/ and generates config files for
multiple AI tools (Claude Code, Trae, etc.).

Usage:
    python build.py              # Build all targets
    python build.py --clean      # Remove generated files
    python build.py --targets claude trae  # Build specific targets
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
import sys
from dataclasses import dataclass, field
from pathlib import Path

# Directories excluded from command discovery
EXCLUDED_DIRS = {"references", "assets", "evals", "scripts", "__pycache__"}
# Files excluded from command discovery
EXCLUDED_FILES = {"SKILL.md"}

# Target AI tool configurations
TARGET_CONFIGS: dict[str, dict] = {
    "claude": {
        "commands_dir": ".claude/commands",
    },
    "trae": {
        "commands_dir": ".trae/commands",
    },
    "cursor": {"commands_dir": ".cursor/commands"},
}

@dataclass
class SkillMeta:
    """Parsed metadata from a SKILL.md frontmatter."""

    name: str
    description: str
    skill_dir: Path

    @classmethod
    def from_skill_md(cls, skill_md_path: Path) -> SkillMeta:
        """Parse SKILL.md YAML frontmatter to extract metadata."""
        content = skill_md_path.read_text(encoding="utf-8")

        # Extract YAML frontmatter between --- markers
        match = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
        if not match:
            raise ValueError(f"No YAML frontmatter found in {skill_md_path}")

        frontmatter = match.group(1)

        # Simple YAML parsing (no dependency on pyyaml)
        name = cls._extract_field(frontmatter, "name")
        if not name:
            raise ValueError(f"Missing required 'name' field in {skill_md_path}")

        description = cls._extract_field(frontmatter, "description") or ""

        return cls(
            name=name,
            description=description,
            skill_dir=skill_md_path.parent,
        )

    @staticmethod
    def _extract_field(frontmatter: str, field_name: str) -> str | None:
        """Extract a simple field value from YAML frontmatter."""
        # Handle multi-line (>- or |- style)
        multi_match = re.search(
            rf"^{field_name}:\s*[>|]-?\s*\n((?:\s+.+\n?)+)",
            frontmatter,
            re.MULTILINE,
        )
        if multi_match:
            lines = multi_match.group(1).strip().splitlines()
            return " ".join(line.strip() for line in lines)

        # Handle single-line with quotes
        single_match = re.search(
            rf'^{field_name}:\s*["\']?(.+?)["\']?\s*$',
            frontmatter,
            re.MULTILINE,
        )
        if single_match:
            return single_match.group(1).strip()

        return None


@dataclass
class BuildSummary:
    """Summary of a build operation."""

    skills_count: int = 0
    files_generated: int = 0
    targets: list[str] = field(default_factory=list)
    details: list[str] = field(default_factory=list)


class SkillBuilder:
    """Builds AI tool config files from skill source definitions."""

    def __init__(
        self,
        project_root: Path | None = None,
        targets: list[str] | None = None,
    ):
        self.project_root = Path(project_root) if project_root else self._find_project_root()
        self.skills_dir = self.project_root / "docs" / "skills"
        self.targets = targets or list(TARGET_CONFIGS.keys())

    @staticmethod
    def _find_project_root() -> Path:
        """Walk up from this script to find project root (has .git or docs/skills)."""
        current = Path(__file__).resolve().parent
        for parent in [current] + list(current.parents):
            if (parent / ".git").exists() or (parent / "docs" / "skills").exists():
                return parent
        raise RuntimeError("Cannot find project root")

    def discover_skills(self) -> list[SkillMeta]:
        """Find all skills in docs/skills/ that have a SKILL.md."""
        skills = []
        if not self.skills_dir.exists():
            return skills

        for skill_md in sorted(self.skills_dir.rglob("SKILL.md")):
            # Skip nested SKILL.md (only direct children of skills/)
            if skill_md.parent.parent != self.skills_dir:
                continue
            try:
                meta = SkillMeta.from_skill_md(skill_md)
                skills.append(meta)
            except ValueError as e:
                print(f"Warning: skipping {skill_md}: {e}", file=sys.stderr)

        return skills

    def discover_commands(self, skill: SkillMeta) -> list[Path]:
        """Find all command .md files in a skill directory (excluding SKILL.md, references, etc.)."""
        commands = []
        for md_file in sorted(skill.skill_dir.rglob("*.md")):
            # Skip excluded files
            if md_file.name in EXCLUDED_FILES:
                continue

            # Skip files in excluded directories
            rel = md_file.relative_to(skill.skill_dir)
            if any(part in EXCLUDED_DIRS for part in rel.parts):
                continue

            commands.append(md_file)

        return commands

    def build(self, targets: list[str] | None = None) -> BuildSummary:
        """Build config files for all targets."""
        targets = targets or self.targets
        summary = BuildSummary(targets=list(targets))

        skills = self.discover_skills()
        summary.skills_count = len(skills)

        for skill in skills:
            commands = self.discover_commands(skill)
            for target_name in targets:
                if target_name not in TARGET_CONFIGS:
                    print(f"Warning: unknown target '{target_name}', skipping", file=sys.stderr)
                    continue

                config = TARGET_CONFIGS[target_name]
                generated = self._build_target(skill, commands, config)
                summary.files_generated += generated
                summary.details.append(
                    f"  [{target_name}] {skill.name}: {generated} files"
                )

        return summary

    def _build_target(
        self,
        skill: SkillMeta,
        commands: list[Path],
        config: dict,
    ) -> int:
        """Create symlinks from target directory to source skill files."""
        commands_base = self.project_root / config["commands_dir"]
        target_skill_dir = commands_base / skill.name
        count = 0

        for cmd_path in commands:
            rel = cmd_path.relative_to(skill.skill_dir)
            target_path = target_skill_dir / rel

            target_path.parent.mkdir(parents=True, exist_ok=True)

            # Remove old symlinks or plain files
            if target_path.is_symlink() or target_path.exists():
                target_path.unlink()

            # Create relative symlink: target -> source
            source_rel = os.path.relpath(cmd_path, target_path.parent)
            target_path.symlink_to(source_rel)
            count += 1

        return count

    def clean(self):
        """Remove all generated skill command directories."""
        skills = self.discover_skills()
        skill_names = {s.name for s in skills}

        for target_name in self.targets:
            if target_name not in TARGET_CONFIGS:
                continue
            config = TARGET_CONFIGS[target_name]
            commands_base = self.project_root / config["commands_dir"]

            for name in skill_names:
                target_dir = commands_base / name
                if target_dir.exists():
                    shutil.rmtree(target_dir)


def main():
    parser = argparse.ArgumentParser(description="Build AI tool configs from skills")
    parser.add_argument("--clean", action="store_true", help="Remove generated files")
    parser.add_argument(
        "--targets",
        nargs="+",
        choices=list(TARGET_CONFIGS.keys()),
        default=list(TARGET_CONFIGS.keys()),
        help="Target AI tools to build for",
    )
    parser.add_argument(
        "--project-root",
        type=Path,
        default=None,
        help="Project root directory (auto-detected if not specified)",
    )
    args = parser.parse_args()

    builder = SkillBuilder(project_root=args.project_root, targets=args.targets)

    if args.clean:
        builder.clean()
        print("Cleaned generated files.")
        return

    summary = builder.build()
    print(f"Build complete: {summary.skills_count} skill(s), {summary.files_generated} file(s) generated")
    for detail in summary.details:
        print(detail)


if __name__ == "__main__":
    main()
