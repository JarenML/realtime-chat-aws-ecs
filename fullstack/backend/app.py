"""
VERSIÓN ARREGLADA — con Redis Pub/Sub.
Ahora es API PURA: no sirve HTML, solo expone /ws y /send.
El frontend (HTML/CSS/JS) vive en un servicio/contenedor separado.

Corre esto con: uvicorn app:app --workers 3 --host 0.0.0.0 --port 8000
"""
import os
import time
import asyncio
import json
from contextlib import asynccontextmanager

import redis.asyncio as redis
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

REDIS_URL = os.environ.get("REDIS_URL", "redis://redis:6379")
# Orígenes permitidos para llamadas HTTP/WebSocket desde el frontend.
# En local con docker-compose, el frontend corre en localhost:8080 (ver docker-compose.yml).
# En AWS, aquí va la URL real del frontend (o "*" solo para pruebas, nunca en prod real).
ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "http://localhost:8080").split(",")

CHANNEL = "ws_channel"
WORKER_PID = os.getpid()

active_connections: list[WebSocket] = []
redis_client: redis.Redis | None = None


async def redis_listener():
    pubsub = redis_client.pubsub()
    await pubsub.subscribe(CHANNEL)
    print(f"[Worker {WORKER_PID}] Suscrito a Redis canal '{CHANNEL}'")
    async for message in pubsub.listen():
        if message["type"] != "message":
            continue
        data = json.loads(message["data"])
        out = json.dumps({
            "type": "message",
            "username": data["username"],
            "text": data["text"],
            "ts": data["ts"],
        })
        stale = []
        for ws in active_connections:
            try:
                await ws.send_text(out)
            except Exception:
                stale.append(ws)
        for ws in stale:
            active_connections.remove(ws)


@asynccontextmanager
async def lifespan(app: FastAPI):
    global redis_client
    redis_client = redis.from_url(REDIS_URL, decode_responses=True)
    listener_task = asyncio.create_task(redis_listener())
    yield
    listener_task.cancel()
    await redis_client.aclose()


app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_methods=["*"],
    allow_headers=["*"],
)


class Message(BaseModel):
    text: str
    username: str


@app.get("/health")
async def health():
    """Endpoint simple para healthcheck de ECS."""
    return {"status": "ok", "worker": WORKER_PID}


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    active_connections.append(websocket)
    await websocket.send_text(json.dumps({
        "type": "system",
        "text": f"Conectado (worker {WORKER_PID})",
    }))
    print(f"[Worker {WORKER_PID}] Nueva conexión. Total en este worker: {len(active_connections)}")
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        active_connections.remove(websocket)
        print(f"[Worker {WORKER_PID}] Conexión cerrada. Total en este worker: {len(active_connections)}")


@app.post("/send")
async def send_message(msg: Message):
    payload = json.dumps({
        "text": msg.text,
        "username": msg.username,
        "ts": time.time(),
        "origin_worker": WORKER_PID,
    })
    await redis_client.publish(CHANNEL, payload)
    return {
        "handled_by_worker": WORKER_PID,
        "local_connections_on_this_worker": len(active_connections),
    }
