# kestrel/ipfix-gen: netflow_generator plus a Kestrel Point IPFIX flow file whose IPs are
# filled in at start-up. Upstream: https://github.com/mikemiles-dev/netflow_generator
# (LICENSE file: Apache-2.0; the README says MIT).
FROM rust:1-slim-bookworm AS build
ARG NFG_VERSION=0.2.8
RUN cargo install netflow_generator --version "${NFG_VERSION}" --locked --root /out

FROM debian:12-slim
RUN apt-get update && apt-get install -y --no-install-recommends gettext-base \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /out/bin/netflow_generator /usr/local/bin/netflow_generator
COPY flows.yaml.tmpl /etc/kestrel/flows.yaml.tmpl
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--interval", "10"]
