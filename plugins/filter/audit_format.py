"""Ansible filter plugins for audit result formatting."""
import json
from datetime import datetime, timezone


def to_audit_json(results):
    """Convert audit_results list to formatted JSON string."""
    return json.dumps(results, indent=2, ensure_ascii=False)


def to_audit_markdown(results):
    """Convert audit_results list to Markdown report."""
    if not results:
        return "# Audit Report\n\nNo results found.\n"

    lines = ["# Audit Report", ""]
    lines.append(f"**Generated**: {datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}")
    lines.append("")

    # Group by host
    hosts = {}
    for r in results:
        h = r.get("hostname", "unknown")
        hosts.setdefault(h, []).append(r)

    # Summary
    total_pass = sum(1 for r in results if r["status"] == "PASS")
    total_warn = sum(1 for r in results if r["status"] == "WARN")
    total_fail = sum(1 for r in results if r["status"] == "FAIL")

    lines.append("## Summary")
    lines.append("")
    lines.append(f"| Status | Count |")
    lines.append(f"|--------|-------|")
    lines.append(f"| PASS | {total_pass} |")
    lines.append(f"| WARN | {total_warn} |")
    lines.append(f"| FAIL | {total_fail} |")
    lines.append(f"| **Total** | **{len(results)}** |")
    lines.append("")

    # Per-host results
    for host, checks in sorted(hosts.items()):
        h_pass = sum(1 for c in checks if c["status"] == "PASS")
        h_warn = sum(1 for c in checks if c["status"] == "WARN")
        h_fail = sum(1 for c in checks if c["status"] == "FAIL")

        lines.append(f"## {host}")
        lines.append("")
        lines.append(f"**Result**: {h_pass} PASS, {h_warn} WARN, {h_fail} FAIL")
        lines.append("")

        for check in checks:
            icon = {"PASS": "✅", "WARN": "⚠️", "FAIL": "❌"}.get(check["status"], "?")
            lines.append(f"### {icon} {check['name']}")
            lines.append("")
            lines.append(f"- **Status**: {check['status']}")
            lines.append(f"- **Severity**: {check['severity']}")
            lines.append(f"- **Message**: {check['message']}")
            if check.get("recommendation"):
                lines.append(f"- **Recommendation**: {check['recommendation']}")
            lines.append("")

    return "\n".join(lines)


class FilterModule:
    """Ansible filter plugins."""

    def filters(self):
        return {
            "to_audit_json": to_audit_json,
            "to_audit_markdown": to_audit_markdown,
        }
