# nt-server-docker
NetworkTables server in Docker

```bash
docker run -d  --mount type=bind,source=$(pwd)/data,target=/data --name nt-server --publish 1735:1735 --restart=unless-stopped j3ff/nt-server
```
