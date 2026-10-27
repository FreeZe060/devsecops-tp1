# syntax=docker/dockerfile:1.27.1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
FROM python:3.13.16-slim-trixie@sha256:bf44cdfcb76cd3b41e879bc058fc37ec5872002ccfde7fcb765e218cde0cd79c AS builder
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /build
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked \
    --mount=type=secret,id=pip_token,required=true \
    test -s /run/secrets/pip_token \
    && pip install --no-compile --target /install -r requirements.txt

FROM gcr.io/distroless/python3-debian13:nonroot@sha256:64e54c4b1200da244d80181d98e86fc01d73c8101f107d5baf472152d8e119a2
ENV PYTHONPATH=/app/deps \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=builder /install /app/deps
COPY app.py .
USER 65532:65532
EXPOSE 5000
CMD ["-m", "gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
