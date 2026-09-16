# asgn_poller

A simple web service and poller system. The web service serves data via HTTP, and the poller periodically fetches and logs this data.

## Structure

- `web/` — Web service (serves `data.txt` on port 8000)
  - `Dockerfile` — Docker configuration
  - `data.txt` — Sample data file
- `poller/poller.sh` — Poller script (fetches data every 5 seconds and logs it)

## Prerequisites

- Docker
- curl

## Quick Start

### 1. Clone or download the project

```bash
cd asgn_poller
```

### 2. Build and run the web server

```bash
cd web
docker build -t web-server .
docker run -d -p 8000:8000 web-server
```

Verify it works: open `http://localhost:8000/data.txt` in your browser. You should see the contents of `data.txt`.

### 3. Run the poller

```bash
cd poller
chmod +x poller.sh
mkdir -p logs
./poller.sh
```

The poller will fetch data from the web service every 5 seconds and append entries to `logs/poller.log`.

### 4. Check the logs

```bash
tail -f logs/poller.log
```

## Stopping

- Stop the poller: Press `Ctrl+C` in its terminal
- Stop the web server:
  ```bash
  docker ps
  docker stop <container-id>
  ```

## Notes for Review

- The web service uses Python's built-in HTTP server for simplicity.
- The poller expects the web service to be running on `localhost:8000`.
- Log entries follow the format: `TIMESTAMP | temperature=XX | city=XX | status=XX`