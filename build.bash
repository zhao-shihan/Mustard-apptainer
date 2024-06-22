cd Mustard
MUSTARD_COMMIT=$(git rev-parse HEAD)
MUSTARD_TIME=$(git show --pretty=format:'%cI' | head -1)
cd ..

build_mustard() {
    apptainer build \
        --build-arg RGB="$(pwd)/../RGB/rgb-$1.sif" \
        --build-arg MUSTARD_SRC_HOST_DIR="$(pwd)/Mustard" \
        --build-arg MUSTARD_COMMIT=$MUSTARD_COMMIT \
        --build-arg MUSTARD_TIME=$MUSTARD_TIME \
        mustard-$1.sif \
        def/$2 &&
        apptainer build \
            --build-arg FROM=mustard-$1.sif \
            mustard-$1-slim.sif \
            def/slim.def
}

build_mustard tianhe2 mustard-tianhe2.def &
build_mustard tianhe2-mt mustard-tianhe2.def &
for mpi in mpich openmpi; do
    build_mustard $mpi mustard.def &
    build_mustard $mpi-mt mustard.def &
done
wait
