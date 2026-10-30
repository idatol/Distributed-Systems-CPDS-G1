"""Run every Part 3 experiment REPS times and save the per-client results.

Each run calls opty:start/6 in a fresh Erlang VM and parses its output.
Usage (from opty-source-files):  python3 results/run_experiments.py
"""
import csv
import re
import statistics
import subprocess
import tempfile
from pathlib import Path

REPS = 10
TIME = 5  # seconds per run

SRC = Path(__file__).resolve().parent.parent
OUT = Path(__file__).resolve().parent / "results.csv"
MODULES = ["entry", "store", "handler", "validator", "server", "client", "opty"]
LINE = re.compile(r"^(\d+): Transactions TOTAL:(\d+), OK:(\d+)")

# (experiment, value, clients, entries, reads, writes, subset)
CONFIGS = (
    [("clients", c, c, 1000, 5, 5, 1000) for c in [1, 2, 4, 8, 16]]
    + [("entries", e, 4, e, 5, 5, e) for e in [10, 50, 100, 500, 1000]]
    + [("reads", r, 4, 1000, r, 5, 1000) for r in [0, 1, 5, 10, 20]]
    + [("writes", w, 4, 1000, 5, w, 1000) for w in [0, 1, 5, 10, 20]]
    + [("ratio", f"{r}/{10 - r}", 4, 1000, r, 10 - r, 1000) for r in [10, 7, 5, 3, 0]]
    + [("subset", s, 4, 1000, 5, 5, s) for s in [10, 100, 250, 500, 750, 1000]]
)


def run(ebin, clients, entries, reads, writes, subset):
    cmd = (f"opty:start({clients}, {entries}, {reads}, {writes}, {TIME}, {subset}), "
           "halt().")
    out = subprocess.run(["erl", "-noshell", "-pa", ebin, "-eval", cmd],
                         capture_output=True, text=True, check=True).stdout
    rows = [tuple(map(int, m.groups())) for m in map(LINE.match, out.splitlines()) if m]
    if len(rows) != clients:
        raise RuntimeError(f"expected {clients} client lines, got:\n{out}")
    return sorted(rows)


def main():
    with tempfile.TemporaryDirectory() as ebin:
        subprocess.run(["erlc", "-o", ebin] + [str(SRC / f"{m}.erl") for m in MODULES],
                       check=True)
        with open(OUT, "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(["experiment", "value", "clients", "entries", "reads", "writes",
                        "subset", "rep", "client", "total", "ok", "success"])
            for i, (exp, val, c, e, r, wr, s) in enumerate(CONFIGS, 1):
                for rep in range(1, REPS + 1):
                    rows = run(ebin, c, e, r, wr, s)
                    for cid, total, ok in rows:
                        w.writerow([exp, val, c, e, r, wr, s, rep, cid, total, ok,
                                    round(100 * ok / max(1, total), 3)])
                    f.flush()
                    rates = [100 * ok / max(1, t) for _, t, ok in rows]
                    print(f"[{i}/{len(CONFIGS)}] {exp}={val} rep {rep}: "
                          f"mean {statistics.mean(rates):.2f} %, "
                          f"min {min(rates):.2f}, max {max(rates):.2f}", flush=True)


if __name__ == "__main__":
    main()
