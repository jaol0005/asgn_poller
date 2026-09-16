# asgn_poller

A small, runnable Docker Compose project built for the **Containerised Toolbox** assignment. A shell script — packaged in its own container — polls a simple web service over the network, extracts the fields it cares about, and logs them with a timestamp.

## Group Members

- Jannik
- Jonas
- Jazmin
- Nikolaj
- Kenadid

## What It Does

This project runs two containers on the same Docker network, talking to each other by **service name**:

- **`web`** — a lightweight Python HTTP server (`python3 -m http.server`) that serves a static file, `data.txt`, containing simple key=value data:
  ```
  temperature=21
  city=Copenhagen
  status=sunny
  ```
- **`poller`** — a shell script running in its own Alpine container. Every few seconds it:
  1. Sends a `curl` request to the web service at `http://web:8000/data.txt` — reachable by the Compose service name `web`, never a hard-coded IP.
  2. Checks curl's exit code to catch connection failures or timeouts (e.g. the web service isn't up yet).
  3. Checks the HTTP status code to catch non-200 responses.
  4. On success, pulls out `temperature`, `city`, and `status` using `grep` and `cut`, then appends a timestamped line to a growing log.
  5. On failure, logs the error and retries on the next loop — it never crashes.

This satisfies the "poller" shape from the assignment: curl an endpoint, extract fields with pipes, and append them to a timestamped log — while gracefully surviving an unreliable network.

## Project Structure

```
asgn_poller/
├── web/
│   ├── Dockerfile        # builds the web service image
│   └── data.txt          # data served by the web service
├── poller/
│   ├── Dockerfile        # builds the poller image (Alpine + curl)
│   └── poller.sh         # the polling/logging script
├── docker-compose.yaml    # wires both services together on one network
├── .gitattributes         # forces LF line endings on shell scripts
└── README.md
```

## How to Run

Clone the repo and start everything with:

```bash
docker compose up --build
```

In a second terminal, follow the poller's logs:

```bash
docker compose logs -f poller
```

You should see output like:

```
2026-09-16T10:45:02Z poller starting, target=http://web:8000/data.txt interval=5s
2026-09-16T10:45:02Z OK status=200 temperature=21 city=Copenhagen weather_status=sunny
2026-09-16T10:45:07Z OK status=200 temperature=21 city=Copenhagen weather_status=sunny
```

### Testing Failure Handling

To confirm the poller survives the web service being down or slow, stop it while the poller keeps running:

```bash
docker compose stop web
```

The poller will start logging lines like:

```
2026-09-16T10:45:03Z ERROR curl_exit=7 retries=1 msg="curl: (7) Failed to connect to web port 8000 after 22 ms: Could not connect to server"
```

instead of crashing. Bring the web service back with:

```bash
docker compose start web
```

The poller will automatically recover and resume logging `OK` lines on its very next cycle.

### Stopping Everything

```bash
docker compose down
```

## File and Service Responsibilities

| File | Responsibility |
|---|---|
| `web/Dockerfile` | Builds the web service image (`python:3-alpine`), serves `data.txt` on port 8000 |
| `web/data.txt` | The data the web service exposes to the poller |
| `poller/poller.sh` | The shell script: polls `web`, parses fields, logs timestamped results, handles failures |
| `poller/Dockerfile` | Builds the poller image (Alpine base + `curl` installed via `RUN`) |
| `docker-compose.yaml` | Defines both services on one Docker network so they reach each other by service name |
| `.gitattributes` | Forces `*.sh` files to use LF line endings so the script runs correctly inside the Linux container regardless of host OS |

## Configuration

The poller's behavior can be tuned via environment variables set in `docker-compose.yaml`:

| Variable | Default | Description |
|---|---|---|
| `WEB_URL` | `http://web:8000/data.txt` | URL the poller curls |
| `INTERVAL` | `5` | Seconds between poll cycles |
| `MAX_RETRIES` | `5` | Consecutive failures before logging an "unreachable" warning |

## Skills Used

`curl`, HTTP status codes, `grep`/`cut` pipes, a `while … sleep` loop, exit-code checking, and output redirection (`tee -a`) — the Session 3 and Session 4 toolkit, applied to a real two-container network interaction.
