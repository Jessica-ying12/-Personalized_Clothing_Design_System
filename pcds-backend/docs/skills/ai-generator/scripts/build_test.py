"""
TDD tests for skill build script.

Tests ensure that the build process correctly generates symlinks from
AI tool config directories to the single-source skill definitions in docs/skills/.
"""

import os
from pathlib import Path

import pytest

from build import SkillBuilder, SkillMeta, TARGET_CONFIGS


@pytest.fixture
def workspace(tmp_path):
    """Create a temporary workspace with a sample skill structure."""
    skill_dir = tmp_path / "docs" / "skills" / "test-skill"
    skill_dir.mkdir(parents=True)

    (skill_dir / "SKILL.md").write_text(
        "---\n"
        "name: test-skill\n"
        "description: A test skill for unit testing.\n"
        "---\n"
        "\n"
        "# Test Skill\n"
        "\n"
        "This is a test skill.\n",
        encoding="utf-8",
    )

    (skill_dir / "run.md").write_text(
        "---\n"
        "description: 'Run the test skill'\n"
        "argument-hint: '<arg>'\n"
        "---\n"
        "\n"
        "# Run\n"
        "\n"
        "Execute with: $ARGUMENTS\n",
        encoding="utf-8",
    )

    sub_dir = skill_dir / "sub"
    sub_dir.mkdir()
    (sub_dir / "helper.md").write_text(
        "---\n"
        "description: 'A helper command'\n"
        "---\n"
        "\n"
        "# Helper\n",
        encoding="utf-8",
    )

    ref_dir = skill_dir / "references"
    ref_dir.mkdir()
    (ref_dir / "schema.md").write_text("# Schema\n", encoding="utf-8")

    return tmp_path


@pytest.fixture
def builder(workspace):
    return SkillBuilder(project_root=workspace)


# ---- SkillMeta parsing tests ----


class TestSkillMeta:
    def test_parse_skill_md(self, workspace):
        skill_md = workspace / "docs" / "skills" / "test-skill" / "SKILL.md"
        meta = SkillMeta.from_skill_md(skill_md)
        assert meta.name == "test-skill"
        assert "test skill" in meta.description.lower()

    def test_parse_missing_name_raises(self, tmp_path):
        bad_skill = tmp_path / "SKILL.md"
        bad_skill.write_text("---\ndescription: no name\n---\n", encoding="utf-8")
        with pytest.raises(ValueError, match="name"):
            SkillMeta.from_skill_md(bad_skill)


# ---- Discovery tests ----


class TestDiscovery:
    def test_discover_skills(self, builder):
        skills = builder.discover_skills()
        assert len(skills) == 1
        assert skills[0].name == "test-skill"

    def test_discover_commands(self, builder):
        skills = builder.discover_skills()
        commands = builder.discover_commands(skills[0])
        cmd_names = [c.name for c in commands]
        assert "run.md" in cmd_names
        assert "SKILL.md" not in cmd_names
        assert "schema.md" not in cmd_names

    def test_discover_sub_commands(self, builder):
        skills = builder.discover_skills()
        commands = builder.discover_commands(skills[0])
        cmd_paths = [str(c.relative_to(skills[0].skill_dir)) for c in commands]
        assert any("sub" in p and "helper.md" in p for p in cmd_paths)


# ---- Target config tests ----


class TestTargetConfigs:
    def test_all_targets_defined(self):
        assert "claude" in TARGET_CONFIGS
        assert "trae" in TARGET_CONFIGS

    def test_claude_config_structure(self):
        cfg = TARGET_CONFIGS["claude"]
        assert cfg["commands_dir"] == ".claude/commands"

    def test_trae_config_structure(self):
        cfg = TARGET_CONFIGS["trae"]
        assert cfg["commands_dir"] == ".trae/commands"


# ---- Build (symlink) tests ----


class TestBuild:
    def test_build_creates_claude_symlink(self, builder, workspace):
        builder.build()
        link = workspace / ".claude" / "commands" / "test-skill" / "run.md"
        assert link.exists()
        assert link.is_symlink()

    def test_build_creates_trae_symlink(self, builder, workspace):
        builder.build()
        link = workspace / ".trae" / "commands" / "test-skill" / "run.md"
        assert link.exists()
        assert link.is_symlink()

    def test_build_creates_sub_command_symlinks(self, builder, workspace):
        builder.build()
        for prefix in (".claude", ".trae"):
            link = workspace / prefix / "commands" / "test-skill" / "sub" / "helper.md"
            assert link.exists()
            assert link.is_symlink()

    def test_build_excludes_skill_md(self, builder, workspace):
        builder.build()
        assert not (
            workspace / ".claude" / "commands" / "test-skill" / "SKILL.md"
        ).exists()

    def test_build_excludes_references(self, builder, workspace):
        builder.build()
        assert not (
            workspace / ".claude" / "commands" / "test-skill" / "references"
        ).exists()

    def test_symlink_points_to_source(self, builder, workspace):
        """Symlink target resolves to the original source file."""
        builder.build()
        link = workspace / ".claude" / "commands" / "test-skill" / "run.md"
        source = workspace / "docs" / "skills" / "test-skill" / "run.md"
        assert link.resolve() == source.resolve()

    def test_symlink_content_matches_source(self, builder, workspace):
        builder.build()
        source = (workspace / "docs" / "skills" / "test-skill" / "run.md").read_text(
            encoding="utf-8"
        )
        target = (
            workspace / ".claude" / "commands" / "test-skill" / "run.md"
        ).read_text(encoding="utf-8")
        assert source == target

    def test_source_edit_reflects_through_symlink(self, builder, workspace):
        """Editing the source file is immediately visible via the symlink."""
        builder.build()
        source = workspace / "docs" / "skills" / "test-skill" / "run.md"
        link = workspace / ".claude" / "commands" / "test-skill" / "run.md"
        source.write_text("# Updated content\n", encoding="utf-8")
        assert link.read_text(encoding="utf-8") == "# Updated content\n"

    def test_build_idempotent(self, builder, workspace):
        builder.build()
        builder.build()
        link = workspace / ".claude" / "commands" / "test-skill" / "run.md"
        assert link.exists()
        assert link.is_symlink()

    def test_build_replaces_plain_file_with_symlink(self, builder, workspace):
        """If a plain file exists at the target, build replaces it with a symlink."""
        target = workspace / ".claude" / "commands" / "test-skill" / "run.md"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text("old plain file", encoding="utf-8")
        assert not target.is_symlink()
        builder.build()
        assert target.is_symlink()


# ---- Clean tests ----


class TestClean:
    def test_clean_removes_generated_dirs(self, builder, workspace):
        builder.build()
        assert (workspace / ".claude" / "commands" / "test-skill").exists()
        builder.clean()
        assert not (workspace / ".claude" / "commands" / "test-skill").exists()
        assert not (workspace / ".trae" / "commands" / "test-skill").exists()

    def test_clean_preserves_non_skill_files(self, builder, workspace):
        builder.build()
        other = workspace / ".claude" / "commands" / "other-stuff.md"
        other.write_text("keep me", encoding="utf-8")
        builder.clean()
        assert other.exists()


# ---- Summary/report tests ----


class TestReport:
    def test_build_returns_summary(self, builder):
        summary = builder.build()
        assert summary.skills_count == 1
        assert summary.files_generated > 0
        assert "claude" in summary.targets
        assert "trae" in summary.targets
