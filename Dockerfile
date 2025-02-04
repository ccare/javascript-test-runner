FROM node:lts-alpine as builder

# Install SSL ca certificates
RUN apk update && apk add ca-certificates
RUN apk upgrade

# Create appuser
RUN adduser -D -g '' appuser

WORKDIR /javascript-test-runner
COPY . .

# Only install the node_modules we need
RUN yarn install --production --modules-folder './production_node_modules'

# Build a minimal and secured container
FROM node:lts-alpine
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /javascript-test-runner/package.json /opt/test-runner/package.json
COPY --from=builder /javascript-test-runner/bin /opt/test-runner/bin
COPY --from=builder /javascript-test-runner/production_node_modules /opt/test-runner/node_modules
USER appuser
WORKDIR /opt/test-runner

COPY ./bin/run.sh ./bin/

ENTRYPOINT [ "sh", "/opt/test-runner/bin/run.sh" ]
