########################################
# Stage 1: Build the .xar package
########################################
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies and build the XAR
COPY package.json ./
RUN npm install

# Copy source files
COPY expath-pkg.xml repo.xml gulpfile.js .existdb.json ./
COPY src/ src/

# Copy Fore dist files into resources (postinstall may have missed them)
RUN mkdir -p src/resources/fore && \
    cp node_modules/@jinntec/fore/dist/fore.js src/resources/fore/ 2>/dev/null || true && \
    cp node_modules/@jinntec/fore/dist/fore.css src/resources/fore/ 2>/dev/null || true && \
    cp node_modules/@jinntec/fore/dist/fore.js.map src/resources/fore/ 2>/dev/null || true

# Build the .xar
RUN npx gulp build && npx gulp xar

########################################
# Stage 2: eXist-db with the .xar
########################################
FROM existdb/existdb:release

# eXist-db runs on 8080 inside the container
EXPOSE 8080

# Copy the built .xar into eXist-db's autodeploy directory
# Packages placed here are installed automatically on first startup
COPY --from=builder /app/dist/*.xar /exist/autodeploy/
