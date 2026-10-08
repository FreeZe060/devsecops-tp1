FROM python:3.13.16-slim-trixie@sha256:bf44cdfcb76cd3b41e879bc058fc37ec5872002ccfde7fcb765e218cde0cd79c AS builder
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --no-compile --target /install -r requirements.txt

FROM gcr.io/distroless/python3-debian13:nonroot@sha256:774595d652a294b54c9bd575b2d9fdd1a4b47547dc17b8bfa4c0e953c64855b3
ENV PYTHONPATH=/app/deps \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=builder /install /app/deps
COPY app.py .
USER 65532:65532
EXPOSE 5000
CMD ["-m", "gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
