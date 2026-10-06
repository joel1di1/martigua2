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


def age(timestamp: str) -> timedelta:
    return datetime.now(timezone.utc) - datetime.fromisoformat(
        timestamp.replace("Z", "+00:00")
    )


def tell_github(metadata: dict[str, str], reason: str) -> None:
    if number := metadata.get("github_pr"):
        retry = "`/agent fix`"
    elif number := metadata.get("github_issue"):
        retry = "`/agent work`"
    else:
        return
    body = f"🤖 Gave up on this agent session: {reason}. Comment {retry} to start a new one."
    subprocess.run(["gh", "issue", "comment", number, "--body", body], check=False)
    subprocess.run(
        ["gh", "issue", "edit", number, "--remove-label", "agent-working"], check=False
    )


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

    print(f"{rescued} sandbox run(s) to start")
    return rescued


if __name__ == "__main__":
    runs = asyncio.run(main())
    if output := os.environ.get("GITHUB_OUTPUT"):
        with open(output, "a") as file:
            file.write(f"slots={json.dumps(list(range(1, runs + 1)))}\n")
