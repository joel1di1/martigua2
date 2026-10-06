# /// script
# requires-python = ">=3.12"
# dependencies = ["anthropic>=1.11"]
# ///
"""Claims one session from the self-hosted Managed Agents environment's queue, for
`ant beta:worker run` to serve in the same GitHub Actions job (.github/workflows/agent-sandbox.yml).
The worker owns the lease from there, so the item is claimed with auto_stop=False.

    uv run script/managed_agents/claim.py --secret-file "$RUNNER_TEMP/work-secret" --wait 120

Writes found, work_id, session_id and environment_id to $GITHUB_OUTPUT (or stdout) and the
work item's secret to --secret-file. Needs ANTHROPIC_ENVIRONMENT_ID and ANTHROPIC_ENVIRONMENT_KEY.
"""

import argparse
import asyncio
import os
import sys
import time

from anthropic import AsyncAnthropic


async def claim(client: AsyncAnthropic, environment_id: str, environment_key: str):
    async for work in client.beta.environments.work.poller(
        environment_id=environment_id,
        environment_key=environment_key,
        block_ms=None,
        # Only reclaims items claimed but never acknowledged, i.e. a claimer that died
        # between the two calls.
        reclaim_older_than_ms=60_000,
        drain=True,
        auto_stop=False,
    ):
        # The queue also sends "healthcheck" items; nothing else will serve them.
        if getattr(work.data, "type", None) != "session":
            await client.beta.environments.work.stop(
                work.id, environment_id=environment_id
            )
            continue
        if not work.secret:
            # Without it the worker would need the environment key, which must stay out of
            # the agent's reach. Unserved, the item goes back to the queue.
            print(f"work {work.id} carries no secret, skipping it", file=sys.stderr)
            continue
        return work
    return None


def write_outputs(values: dict[str, str]) -> None:
    lines = "".join(f"{key}={value}\n" for key, value in values.items())
    path = os.environ.get("GITHUB_OUTPUT")
    if path:
        with open(path, "a") as output:
            output.write(lines)
    else:
        sys.stdout.write(lines)


async def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--secret-file", required=True)
    parser.add_argument(
        "--wait",
        type=int,
        default=0,
        help="seconds to keep polling while the queue is empty",
    )
    args = parser.parse_args()

    environment_id = os.environ["ANTHROPIC_ENVIRONMENT_ID"]
    environment_key = os.environ["ANTHROPIC_ENVIRONMENT_KEY"]
    deadline = time.monotonic() + args.wait
    async with AsyncAnthropic(auth_token=environment_key) as client:
        while (work := await claim(client, environment_id, environment_key)) is None:
            if time.monotonic() >= deadline:
                print("no session waiting in the queue")
                write_outputs({"found": "false"})
                return
            await asyncio.sleep(3)

    fd = os.open(args.secret_file, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as secret_file:
        secret_file.write(work.secret)
    print(f"claimed session {work.data.id} (work {work.id})")
    write_outputs(
        {
            "found": "true",
            "work_id": work.id,
            "session_id": work.data.id,
            "environment_id": work.environment_id,
        }
    )


if __name__ == "__main__":
    asyncio.run(main())
