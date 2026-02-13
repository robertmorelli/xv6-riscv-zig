#!/usr/bin/env python3

import argparse
import os
import signal
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LOG_DIR = ROOT / "test-logs"


@dataclass(frozen=True)
class TestCase:
    name: str
    cmd: list[str]
    timeout_s: int


TESTS: dict[str, TestCase] = {
    "build": TestCase("build", ["zig", "build"], 240),
    "usertests_quick": TestCase("usertests_quick", ["python3", "test-xv6.py", "-q", "usertests"], 480),
    "usertests_full": TestCase("usertests_full", ["python3", "test-xv6.py", "usertests"], 900),
    "crash_suite": TestCase("crash_suite", ["python3", "test-xv6.py", "crash"], 600),
}

PROFILES: dict[str, list[str]] = {
    "smoke": ["build"],
    "quick": ["build", "usertests_quick"],
    "full": ["build", "usertests_full", "crash_suite"],
}


def terminate_process_group(proc: subprocess.Popen[str]) -> None:
    if proc.poll() is not None:
        return
    try:
        os.killpg(proc.pid, signal.SIGTERM)
    except ProcessLookupError:
        return
    time.sleep(1.0)
    if proc.poll() is None:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            return


def run_case(case: TestCase, timeout_scale: float, env: dict[str, str]) -> tuple[bool, str]:
    timeout_s = max(1, int(case.timeout_s * timeout_scale))
    log_path = LOG_DIR / f"{case.name}.log"
    print(f"[RUN ] {case.name} (timeout={timeout_s}s)", flush=True)
    start = time.monotonic()
    proc = subprocess.Popen(
        case.cmd,
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        start_new_session=True,
        env=env,
    )

    timed_out = False
    output = ""
    try:
        output, _ = proc.communicate(timeout=timeout_s)
    except subprocess.TimeoutExpired:
        timed_out = True
        terminate_process_group(proc)
        output, _ = proc.communicate()

    elapsed = time.monotonic() - start
    log_path.write_text(output, encoding="utf-8", errors="replace")

    if timed_out:
        print(f"[FAIL] {case.name} timed out after {elapsed:.1f}s (log: {log_path})", flush=True)
        return False, case.name
    if proc.returncode != 0:
        print(f"[FAIL] {case.name} exited {proc.returncode} after {elapsed:.1f}s (log: {log_path})", flush=True)
        return False, case.name

    print(f"[ OK ] {case.name} in {elapsed:.1f}s (log: {log_path})", flush=True)
    return True, case.name


def main() -> int:
    parser = argparse.ArgumentParser(description="Run xv6 tests with robust timeouts and logs.")
    parser.add_argument(
        "--profile",
        choices=sorted(PROFILES.keys()),
        default="quick",
        help="Test profile to run.",
    )
    parser.add_argument(
        "--timeout-scale",
        type=float,
        default=1.0,
        help="Multiply per-test timeouts by this factor.",
    )
    args = parser.parse_args()

    LOG_DIR.mkdir(parents=True, exist_ok=True)

    env = os.environ.copy()
    env.setdefault("ZIG_LOCAL_CACHE_DIR", str(ROOT / ".zig-cache-local"))
    env.setdefault("ZIG_GLOBAL_CACHE_DIR", str(ROOT / ".zig-global-cache"))

    failures: list[str] = []
    for name in PROFILES[args.profile]:
        ok, case_name = run_case(TESTS[name], args.timeout_scale, env)
        if not ok:
            failures.append(case_name)
            break

    if failures:
        print("", flush=True)
        print("Failed tests:", flush=True)
        for name in failures:
            print(f"  - {name}", flush=True)
        return 1

    print("", flush=True)
    print("All tests in profile passed.", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
