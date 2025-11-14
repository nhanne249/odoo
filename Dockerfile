FROM python:3.13-slim

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential pkg-config gcc \
    libldap2-dev libsasl2-dev libssl-dev \
    libxml2-dev libxslt1-dev zlib1g-dev libpq-dev \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/secrets

ENV PGSSLROOTCERT=/etc/secrets/ca.pem \
    ODOO_DB_SSLMODE=verify-full

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . .
CMD python odoo-bin \
    -d "$defaultdb" \
    -i all \
    --db_user "$ODOO_DB_USER" \
    -w "$ODOO_DB_PASSWORD" \
    --db_host "$ODOO_DB_HOST" \
    --db_port "$ODOO_DB_PORT" \
    --db_sslmode "$ODOO_DB_SSLMODE"
