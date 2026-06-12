#!/bin/bash

set -e # link to the source - https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html

log_info() {
    echo "[INFO] $1"
}

log_step() {
    echo "[STEP] $1"
}

log_error() {
    echo "[ERROR] $1" >&2 # linl to the source - https://linuxize.com/post/bash-redirect-stderr-stdout/
}

DATA_DIR="$(pwd)/data"

check_docker() {
    if ! command -v docker &> /dev/null; then # link to the source - https://www.delftstack.com/howto/linux/bash-check-if-command-exists/
        log_error "Docker not installed"
        exit 1
    fi
}

build_generator() {
    log_step "assembling the generator image..."
    check_docker
    docker build -f Dockerfile.generator -t rhode-generator:latest .
    log_info "image rhode-generator:latest is assembled"
}

run_generator() {
    log_step "starting the generator..."
    check_docker
    mkdir -p "$DATA_DIR"
    docker run --rm -v "$DATA_DIR:/data" rhode-generator:latest
    log_info "data saved in $DATA_DIR/data.csv"
}

create_local_data() {
    log_step "local generation..."
    mkdir -p local_data
    python3 generate.py local_data
    log_info "local data: $(pwd)/local_data/data.csv"
}

build_reporter() {
    log_step "asssembling the analyst image..."
    check_docker
    docker build -f Dockerfile.reporter -t rhode-reporter:latest .
    log_info "image rhode-reporter:latest is assembled"
}

run_reporter() {
    log_step "launching the analyst..."
    check_docker
    if [ ! -f "$DATA_DIR/data.csv" ]; then
        log_error "data/data.csv not found. first, run run_generator"
        exit 1
    fi

    docker run --rm -v "$DATA_DIR:/data" rhode-reporter:latest
    log_info "the report is saved in $DATA_DIR/report.html"
}

structure() {
    log_step "project's structure:"
    for entry in *; do
        if [ -d "$entry" ]; then
            echo "  [d] $entry"
        else
            echo "  [f] $entry"
        fi
    done
}

clear_data() {
    log_step "data cleanup..."
    if [ -d "$DATA_DIR" ]; then
        rm -f "$DATA_DIR"/*.csv "$DATA_DIR"/*.html
    fi
    log_info "cleaned up"
}

inside_generator() {
    log_step "entrance to the generator container..."
    check_docker
    docker run --rm -it -v "$DATA_DIR:/data" --entrypoint /bin/sh rhode-generator:latest
}

inside_reporter() {
    log_step "entrance to the analyst container..."
    check_docker
    docker run --rm -it -v "$DATA_DIR:/data" --entrypoint /bin/sh rhode-reporter:latest
}

report_server() {
    log_step "launching a web service..."
    check_docker
    docker stop rhode-server 2>/dev/null || true # link to the source - https://www.cyberciti.biz/faq/how-to-redirect-output-and-errors-to-devnull/
    docker rm rhode-server 2>/dev/null || true
    docker run -d --name rhode-server -p 8080:80 -v "$DATA_DIR:/usr/share/nginx/html:ro" nginx:alpine
    log_info "web service on http://localhost:8080/report.html"
}

case "$1" in #link to the source - https://linuxize.com/post/bash-case-statement/
    build_generator)
        build_generator
        ;;
    run_generator)
        run_generator
        ;;
    create_local_data)
        create_local_data
        ;;
    build_reporter)
        build_reporter
        ;;
    run_reporter)
        run_reporter
        ;;
    structure)
        structure
        ;;
    clear_data)
        clear_data
        ;;
    inside_generator)
        inside_generator
        ;;
    inside_reporter)
        inside_reporter
        ;;
    report_server)
        report_server
        ;;
    *)
    echo "Unknown command: $1"
        exit 1
        ;;
esac