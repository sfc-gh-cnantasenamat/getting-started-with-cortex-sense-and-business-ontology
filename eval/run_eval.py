#!/usr/bin/env python3
"""Compare four Cortex Agents on a fixed question set and print a scorecard.

Arms: A bare semantic view, B + Business Ontology, C + Cortex Sense (tables only),
D + Business Ontology + Cortex Sense. Each answer is graded by an LLM judge against
the expected value in questions.csv.

Environment:
  SNOWFLAKE_CONNECTION_NAME  connection to use (default: "default")
  SNOWFLAKE_ROLE, SNOWFLAKE_WAREHOUSE  optional overrides
  SENSE_ONTOLOGY_SCHEMA  schema that holds the agents (default: SENSE_ONTOLOGY_QS.SAP)
  JUDGE_MODEL  model for grading (default: claude-sonnet-4-5)
"""
import argparse
import concurrent.futures as cf
import csv
import json
import math
import os
import re
import threading
import time

import snowflake.connector

SCHEMA = os.environ.get("SENSE_ONTOLOGY_SCHEMA", "SENSE_ONTOLOGY_QS.SAP")
JUDGE_MODEL = os.environ.get("JUDGE_MODEL", "claude-sonnet-4-5")
ARMS = {"A": "BARE_AGENT", "B": "ONTOLOGY_AGENT", "C": "SENSE_AGENT", "D": "SENSE_ONTOLOGY_AGENT"}
HERE = os.path.dirname(os.path.abspath(__file__))

JUDGE_PROMPT = """You grade an analytics agent's answer against ground truth.
Question: {question}
Expected: {expected}
Plausible wrong answer: {wrong}
Agent answer:
<<<
{answer}
>>>
The headline number must match the expected value within rounding. If the agent offers competing answers and never says which one is official, it is hedged and NOT correct.
Return only JSON with keys: "headline" (the final number the agent gave), "hedged" (true/false), "correct" (true/false), "reason" (one short sentence)."""


_CONN = None
_LOCK = threading.Lock()


def connect(fresh=False):
    """One shared connection, so browser or SSO logins prompt once, not once per call."""
    global _CONN
    with _LOCK:
        if _CONN is None or fresh:
            overrides = {k: os.environ[e] for k, e in (("role", "SNOWFLAKE_ROLE"), ("warehouse", "SNOWFLAKE_WAREHOUSE")) if os.environ.get(e)}
            _CONN = snowflake.connector.connect(connection_name=os.environ.get("SNOWFLAKE_CONNECTION_NAME", "default"), **overrides)
        return _CONN


def run_agent(agent, question, tries=3):
    body = json.dumps({"messages": [{"role": "user", "content": [{"type": "text", "text": question}]}]})
    err = ""
    for attempt in range(tries):
        try:
            cur = connect(fresh=attempt > 0).cursor()
            cur.execute("SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(%s, %s)", (f"{SCHEMA}.{agent}", body))
            resp = json.loads(cur.fetchone()[0])
            content = resp.get("content", [])
            return {
                "tools": [c["tool_use"]["name"] for c in content if c.get("type") == "tool_use"],
                "answer": "\n".join(c.get("text", "") for c in content if c.get("type") == "text" and c.get("text", "").strip()),
                "error": None,
            }
        except Exception as exc:  # a connection or service error is retried, never scored as a wrong answer
            err = str(exc)[:300]
            time.sleep(10 * (attempt + 1))
    return {"tools": [], "answer": "", "error": err}


def judge(q, answer):
    try:
        cur = connect().cursor()
        prompt = JUDGE_PROMPT.format(question=q["question"], expected=q["expected"], wrong=q["wrong"], answer=answer[:5000])
        for _ in range(3):
            try:
                cur.execute("SELECT AI_COMPLETE(%s, %s)", (JUDGE_MODEL, prompt))
                raw = cur.fetchone()[0]
                if raw.lstrip().startswith('"'):
                    raw = json.loads(raw)
                return json.loads(re.search(r"\{.*\}", raw, re.S).group(0))
            except Exception:
                time.sleep(5)
        return {"correct": None, "reason": "judge failed"}
    except Exception as exc:
        return {"correct": None, "reason": str(exc)[:200]}


def one(arm, q, rep):
    r = run_agent(ARMS[arm], q["question"])
    v = {"correct": None, "reason": r["error"]} if r["error"] else judge(q, r["answer"])
    return {"arm": arm, "qid": q["id"], "category": q["category"], "rep": rep, "tools": r["tools"], "answer": r["answer"], "correct": v.get("correct"), "reason": v.get("reason")}


def scorecard(rows):
    cats = ["governed", "discovery", "control"]
    print(f"\n{'Arm':<24}" + "".join(f"{c:>12}" for c in cats) + f"{'total':>10}")
    for a in "ABCD":
        mine = [r for r in rows if r["arm"] == a]
        if not mine:
            continue
        cells = []
        for c in cats:
            rs = [r for r in mine if r["category"] == c]
            cells.append(f"{sum(1 for r in rs if r['correct'])}/{len(rs)}")
        print(f"{a} {ARMS[a]:<22}" + "".join(f"{x:>12}" for x in cells) + f"{sum(1 for r in mine if r['correct'])}/{len(mine)}".rjust(10))
    unscored = sum(1 for r in rows if r["correct"] is None)
    if unscored:
        print(f"\n{unscored} runs have no verdict (service or judge error). Rerun with --resume.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--arms", default="A,B,C,D")
    ap.add_argument("--reps", type=int, default=2)
    ap.add_argument("--qids", default="", help="comma-separated question ids, default all")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--out", default=os.path.join(HERE, "results.json"))
    ap.add_argument("--resume", action="store_true", help="run only the calls that have no verdict yet")
    args = ap.parse_args()
    qs = [q for q in csv.DictReader(open(os.path.join(HERE, "questions.csv"))) if not args.qids or q["id"] in args.qids.split(",")]
    rows = json.load(open(args.out)) if args.resume and os.path.exists(args.out) else []
    done = {(r["arm"], r["qid"], r["rep"]) for r in rows if r["correct"] is not None}
    rows = [r for r in rows if r["correct"] is not None]
    jobs = [(a, q, i) for a in args.arms.split(",") for q in qs for i in range(args.reps) if (a, q["id"], i) not in done]
    print(f"Running {len(jobs)} calls on {SCHEMA} ...", flush=True)
    with cf.ThreadPoolExecutor(args.workers) as ex:
        for res in ex.map(lambda j: one(*j), jobs):
            rows.append(res)
            print(res["arm"], res["qid"], res["rep"], res["correct"], res["tools"], flush=True)
            json.dump(rows, open(args.out, "w"), indent=1)
    scorecard(rows)


if __name__ == "__main__":
    main()
