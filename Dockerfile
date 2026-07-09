# NIGHTGLASS is a single static file (index.html) -- this container just
# serves it over HTTP. No build step, no dependencies.
FROM python:3.12-alpine

WORKDIR /app
COPY index.html .

EXPOSE 8080
CMD ["python", "-m", "http.server", "8080"]
