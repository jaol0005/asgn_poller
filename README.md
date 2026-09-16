# asgn_poller

A poller service that fetches data from a web service every 5 seconds and logs it with timestamps.

## Structure

- `web/` — Web service (serves `data.txt` on port 8000)
  - `Dockerfile` — Python HTTP server
  - `data.txt` — Sample data file
- `poller/` — Poller service
  - `Dockerfile` — Alpine + curl image
  - `poller.sh` — Script that polls the web service
- `docker-compose.yml` — Orchestrates both services

## Running

```bash
docker compose up
```

*Note: Use `docker compose` (with space) for Docker v20.10+. If you get 'command not found', install with:*
```bash
sudo apt install docker-compose-plugin
```

This starts both services. The poller will:
- Fetch data from `http://web:8000/data.txt` every 5 seconds
- Log results to `poller/logs/poller.log` with timestamps
- Handle failures (timeouts, non-200 responses)

View logs:
```bash
tail -f poller/logs/poller.log
```

## What Each Part Does

- **web service**: Serves `data.txt` via HTTP
- **poller service**: Fetches data, extracts fields with grep, appends timestamped entries
- **docker-compose.yml**: Defines both services so they can communicate by name (`web`)
