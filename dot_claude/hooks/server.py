import json
import logging

from fastapi import FastAPI, Request

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("hooks")

app = FastAPI()

EVENTS = [
    "SessionStart",
    "SessionEnd",
    "UserPromptSubmit",
    "PreToolUse",
    "PostToolUse",
    "PostToolUseFailure",
    "PermissionRequest",
    "Notification",
    "Stop",
    "PreCompact",
    "SubagentStart",
    "SubagentStop",
    "TeammateIdle",
    "TaskCompleted",
    "ConfigChange",
    "WorktreeCreate",
    "WorktreeRemove",
]


@app.post("/hooks/{event}")
async def handle_hook(event: str, request: Request):
    body = await request.json()
    log.info(f"[{event}] {json.dumps(body, indent=2)}")
    return {}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8787)
