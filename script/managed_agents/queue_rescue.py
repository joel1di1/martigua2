# /// script
# requires-python = ">=3.12"
# dependencies = ["anthropic>=1.11"]
# ///
"""Rescue and GC for sessions stuck in the self-hosted environment's queue
(.github/workflows/agent-queue.yml). Queued work items are only listed here, never claimed:
the sandbox runs started afterwards claim them.

For each queued session:
- queued less than RESCUE_AFTER: left to the agent.yml / agent-ci-fix.yml run that created it;
- rescued fewer than MAX_RESCUES times and queued less than GIVE_UP_AFTER: rescued, i.e.
  its rescue counter (session metadata) goes up and a sandbox run is requested for it;
- otherwise: given up. The work item is stopped, the session archived, and the linked
  issue or PR told so.

Then any open issue or PR still labelled `agent:working` whose latest session is neither
running nor active within STALE_AFTER (budget reached, crash, agent forgot its label) is
given up too: commented and moved to `agent:stuck`.

Writes `slots` (a JSON array with one entry per sandbox run to start) to $GITHUB_OUTPUT.
Needs ANTHROPIC_API_KEY, ANTHROPIC_ENVIRONMENT_ID, ANTHROPIC_ENVIRONMENT_KEY, and GH_TOKEN
for the GitHub comments.
"""

import asyncio
import json
import os
import subprocess
from datetime import datetime, timedelta, timezone

from anthropic import AsyncAnthropic

RESCUE_AFTER = timedelta(minutes=10)
GIVE_UP_AFTER = timedelta(hours=24)
MAX_RESCUES = 3
MAX_PARALLEL_RUNS = 5
# Well past the sandbox worker's 5 min idle stop (agent-sandbox.yml --max-idle).
STALE_AFTER = timedelta(minutes=15)


def age(timestamp: str) -> timedelta:
    return datetime.now(timezone.utc) - datetime.fromisoformat(
        timestamp.replace("Z", "+00:00")
    )


RETRY_LABELS = {"refine": "agent:refine!", "implement": "agent:dev!"}


def tell_github(metadata: dict[str, str], reason: str) -> None:
    if number := metadata.get("github_pr"):
        retry = "`agent:dev!`"
    elif number := metadata.get("github_issue"):
        retry = f"`{RETRY_LABELS.get(metadata.get('phase', ''), 'agent:refine!')}`"
    else:
        return
    body = f"🤖 Gave up on this agent session: {reason}. Add the {retry} label to start a new one."
    subprocess.run(["gh", "issue", "comment", number, "--body", body], check=False)
    subprocess.run(
        ["script/managed_agents/set_status.sh", number, "agent:stuck"], check=False
    )


def stale_working(
    items: list[dict], sessions: list
) -> list[tuple[dict[str, str], str]]:
    """The issues/PRs (GitHub JSON) labelled agent:working that no live session serves, as
    (metadata, reason). `sessions` is newest first."""
    latest = {}
    for session in sessions:
        meta = session.metadata or {}
        latest.setdefault(meta.get("github_pr") or meta.get("github_issue"), session)
    stale = []
    for item in items:
        number = str(item["number"])
        session = latest.get(number)
        if session is None:
            key = "github_pr" if "pull_request" in item else "github_issue"
            stale.append(({key: number}, "no agent session found for it"))
        elif session.status not in ("running", "rescheduling") and (
            datetime.now(timezone.utc) - session.updated_at >= STALE_AFTER
        ):
            reason = f"session {session.id} ended ({session.status}) while this was still `agent:working`"
            stale.append((dict(session.metadata), reason))
    return stale


def working_items() -> list[dict]:
    # The issues endpoint lists pull requests too.
    return json.loads(
        subprocess.run(
            [
                "gh",
                "api",
                "repos/{owner}/{repo}/issues?labels=agent:working&state=open&per_page=100",
            ],
            capture_output=True,
            text=True,
            check=True,
        ).stdout
    )


async def give_up_stale_working(api: AsyncAnthropic) -> None:
    items = working_items()
    if not items:
        return
    since = datetime.now(timezone.utc) - timedelta(days=3)
    sessions = [
        s async for s in api.beta.sessions.list(created_at_gte=since, order="desc")
    ]
    for metadata, reason in stale_working(items, sessions):
        print(
            f"giving up on #{metadata.get('github_pr') or metadata.get('github_issue')}: {reason}"
        )
        tell_github(metadata, reason)


async def main() -> int:
    environment_id = os.environ["ANTHROPIC_ENVIRONMENT_ID"]
    api = AsyncAnthropic()
    worker = AsyncAnthropic(auth_token=os.environ["ANTHROPIC_ENVIRONMENT_KEY"])

    rescued = 0
    async for work in worker.beta.environments.work.list(environment_id, limit=100):
        if work.state != "queued" or getattr(work.data, "type", None) != "session":
            continue
        queued_for = age(work.created_at)
        if queued_for < RESCUE_AFTER:
            continue

        session = await api.beta.sessions.retrieve(work.data.id)
        metadata = dict(session.metadata or {})
        rescues = int(metadata.get("rescue_attempts", "0"))
        label = f"session {session.id} (queued {queued_for // timedelta(minutes=1)} min, {rescues} rescue(s))"

        if rescues >= MAX_RESCUES or queued_for >= GIVE_UP_AFTER:
            reason = (
                f"still not served after {rescues} rescue attempts"
                if rescues >= MAX_RESCUES
                else f"waiting in the queue for more than {GIVE_UP_AFTER // timedelta(hours=1)} h"
            )
            print(f"giving up on {label}: {reason}")
            await worker.beta.environments.work.stop(
                work.id, environment_id=environment_id, force=True
            )
            await api.beta.sessions.archive(session.id)
            tell_github(metadata, reason)
        elif rescued < MAX_PARALLEL_RUNS:
            print(f"rescuing {label}")
            await api.beta.sessions.update(
                session.id, metadata={"rescue_attempts": str(rescues + 1)}
            )
            rescued += 1
        else:
            print(
                f"{label} left for the next run ({MAX_PARALLEL_RUNS} rescues already)"
            )

    await give_up_stale_working(api)
    print(f"{rescued} sandbox run(s) to start")
    return rescued


if __name__ == "__main__":
    runs = asyncio.run(main())
    if output := os.environ.get("GITHUB_OUTPUT"):
        with open(output, "a") as file:
            file.write(f"slots={json.dumps(list(range(1, runs + 1)))}\n")
