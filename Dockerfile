FROM postgres:16.3 AS builder

# Install necessary dependencies for building pgvector
RUN apt-get update && apt-get install -y \
  build-essential \
  postgresql-server-dev-16 \
  git \
  ca-certificates \  
  && update-ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Clone and build pgvector
WORKDIR /tmp
RUN git clone --depth 1 --branch v0.7.0 https://github.com/pgvector/pgvector.git

WORKDIR /tmp/pgvector
RUN make
RUN make install

# Extend the official PostgreSQL image
FROM postgres:16.3

# copy extensions to the final image
COPY --from=builder /usr/include/postgresql /usr/include/postgresql
COPY --from=builder /usr/lib/postgresql/16/lib /usr/lib/postgresql/16/lib
COPY --from=builder /usr/share/postgresql/16/extension /usr/share/postgresql/16/extension

# Enable pgvector in PostgreSQL
# RUN echo "shared_preload_libraries = 'pgvector'" >> /usr/share/postgresql/postgresql.conf
