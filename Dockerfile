# --- Build-Stage: optimiertes Keycloak für PostgreSQL ---
FROM quay.io/keycloak/keycloak:26.2 AS builder

# Build-Zeit-Optionen (werden ins Image "eingebrannt")
ENV KC_DB=postgres
# Nur ein Keycloak-Container -> kein Cluster-Discovery (spart die JOIN-Timeouts)
ENV KC_CACHE=local
ENV KC_HEALTH_ENABLED=true

RUN /opt/keycloak/bin/kc.sh build

# --- Runtime-Stage ---
FROM quay.io/keycloak/keycloak:26.2

COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Realm-Export fest ins Image; wird mit --import-realm beim Start importiert
COPY --chown=keycloak:keycloak terramax-realm.json /opt/keycloak/data/import/terramax-realm.json

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized", "--import-realm"]
