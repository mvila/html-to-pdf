# Building

```bash
docker build --tag mvila/html-to-pdf .
docker push mvila/html-to-pdf
```

# Starting

```bash
docker run --name=html-to-pdf --rm --publish=3333:3333 --detach mvila/html-to-pdf
```

# Stopping

```bash
docker rm --force html-to-pdf
```
