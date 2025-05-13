FROM debian:bookworm-slim

ENV IBM_DB_HOME=/usr/local/clidriver
ENV PATH=/usr/local/go/bin:$IBM_DB_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$IBM_DB_HOME/lib
ENV CGO_CFLAGS="-I${IBM_DB_HOME}/include"
ENV CGO_LDFLAGS="-L${IBM_DB_HOME}/lib"

# Install dependencies, IBM CLI, Go, build exporter, and clean up in one layer
RUN apt-get update -y && \
    apt-get install -y curl libxml2-dev make git bash build-essential && \
    # Install Go
    curl -sL https://go.dev/dl/go1.24.3.linux-amd64.tar.gz | tar -xz -C /usr/local && \
    # Install IBM CLI
    mkdir -p $IBM_DB_HOME && \
    curl -sL https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/v11.5.9/linuxx64_odbc_cli.tar.gz | \
    tar -xz -C $IBM_DB_HOME --strip-components=1 && \
    # Build exporter
    git clone https://github.com/grafana/ibm-db2-prometheus-exporter && \
    cd ibm-db2-prometheus-exporter && \
    go get github.com/ibmdb/go_ibm_db@latest && \
    go mod tidy && \
    make exporter && \
    mv bin/* /bin/ibm_db2_exporter && \
    # Cleanup
    apt-get remove make git -y build-essential && \
    cd / && rm -rf ibm-db2-prometheus-exporter /usr/local/go /var/lib/apt/lists/* /tmp/*

# Copy scripts
COPY entrypoint.sh /entrypoint.sh

# Entrypoint
CMD ["/bin/bash", "/entrypoint.sh"]
