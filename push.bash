success_or_exit() {
    if eval "$1"; then
        >>/dev/null
    else
        exit 1
    fi
}

success_or_exit "apptainer registry login --username $1 --password $2 oras://ghcr.io"

apptainer verify mustard-tianhe2.sif &
apptainer verify mustard-tianhe2-mt.sif &
apptainer verify mustard-tianhe2-slim.sif &
apptainer verify mustard-tianhe2-mt-slim.sif &
for mpi in mpich openmpi; do
    apptainer verify mustard-$mpi.sif &
    apptainer verify mustard-$mpi-mt.sif &
    apptainer verify mustard-$mpi-slim.sif &
    apptainer verify mustard-$mpi-mt-slim.sif &
done
wait

auto_retry() {
    local max_attempts=$1
    local command="$2"
    local wait_time=5

    local attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if eval $command; then
            break
        else
            attempt=$((attempt + 1))
            echo "Attempt $attempt failed, retrying in $wait_time seconds..."
            sleep $wait_time
        fi
    done
    if [ $attempt -eq $max_attempts ]; then
        echo "Command failed after $max_attempts attempts."
    fi
}

auto_retry 999 "apptainer push mustard-tianhe2.sif oras://ghcr.io/zhao-shihan/mustard:tianhe2" &
auto_retry 999 "apptainer push mustard-tianhe2.sif oras://ghcr.io/zhao-shihan/mustard:tianhe2-mt" &
auto_retry 999 "apptainer push mustard-tianhe2-slim.sif oras://ghcr.io/zhao-shihan/mustard:tianhe2-slim" &
auto_retry 999 "apptainer push mustard-tianhe2-slim.sif oras://ghcr.io/zhao-shihan/mustard:tianhe2-mt-slim" &
for mpi in mpich openmpi; do
    auto_retry 999 "apptainer push mustard-$mpi.sif oras://ghcr.io/zhao-shihan/mustard:$mpi" &
    auto_retry 999 "apptainer push mustard-$mpi.sif oras://ghcr.io/zhao-shihan/mustard:$mpi-mt" &
    auto_retry 999 "apptainer push mustard-$mpi-slim.sif oras://ghcr.io/zhao-shihan/mustard:$mpi-slim" &
    auto_retry 999 "apptainer push mustard-$mpi-slim.sif oras://ghcr.io/zhao-shihan/mustard:$mpi-mt-slim" &
done
wait
# auto_retry 999 "apptainer push mustard-mpich.sif oras://ghcr.io/zhao-shihan/mustard:latest"
