from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL_DIR = ROOT / "goal-prompt-builder"
SKILL_MD = SKILL_DIR / "SKILL.md"
OPENAI_YAML = SKILL_DIR / "agents" / "openai.yaml"


def read_skill() -> str:
    return SKILL_MD.read_text(encoding="utf-8")


def frontmatter_description(text: str) -> str:
    for line in text.splitlines():
        if line.startswith("description: "):
            return line.removeprefix("description: ").strip()
    raise AssertionError("missing description frontmatter")


def test_description_is_trigger_only():
    description = frontmatter_description(read_skill())

    assert description.startswith("Use when "), "description should start with trigger language"
    assert len(description) <= 260, "description should stay concise"

    workflow_terms = [
        "5-section",
        "supports three interaction modes",
        "auto-detects",
        "reads AGENTS",
        "predicts audit-friendliness",
        "Produces a complete",
    ]
    for term in workflow_terms:
        assert term not in description, f"description should not summarize workflow: {term}"


def test_openai_ui_metadata_exists():
    assert OPENAI_YAML.exists(), "agents/openai.yaml should exist for Codex UI metadata"

    metadata = OPENAI_YAML.read_text(encoding="utf-8")
    for field in ("display_name:", "short_description:", "default_prompt:"):
        assert field in metadata, f"missing {field} in agents/openai.yaml"


def test_hybrid_mode_is_default_without_initial_mode_prompt():
    text = read_skill()

    assert "Ask **once** at the start" not in text
    assert "Default to hybrid mode" in text
    assert "only ask the user to choose a mode" in text


if __name__ == "__main__":
    tests = [
        test_description_is_trigger_only,
        test_openai_ui_metadata_exists,
        test_hybrid_mode_is_default_without_initial_mode_prompt,
    ]
    failures = []
    for test in tests:
        try:
            test()
            print(f"PASS {test.__name__}")
        except AssertionError as exc:
            failures.append((test.__name__, str(exc)))
            print(f"FAIL {test.__name__}: {exc}")

    if failures:
        raise SystemExit(1)
