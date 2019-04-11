FROM rust:1.33 as build

# Doing a new cargo project and installing dependencies makes before copying in
# sources is a neat trick - it makes docker cache the installation of
# dependencies, which means that you don't have to spend 5 minutes to wait for
# deps to install with each build.

RUN USER=root cargo new --bin iot-rest
WORKDIR /iot-rest

COPY ./Cargo.lock .
COPY ./Cargo.toml .

RUN cargo build --release 
RUN rm -f ./target/release/deps/iot_rest*
RUN rm src/*.rs

# Ok, so now deps are installed and cached! Copy over the sources, and build again.
COPY ./src ./src
RUN cargo build --release

FROM scratch
WORKDIR /
RUN mkdir -p /lib/x86_64-linux-gnu
COPY --from=build /iot-rest/target/release/iot-rest /iot-rest
COPY --from=build /lib/x86_64-linux-gnu/libdl.so.2 /lib/x86_64-linux-gnu/libdl.so.2
COPY --from=build /lib/x86_64-linux-gnu/librt.so.1 /lib/x86_64-linux-gnu/librt.so.1
COPY --from=build /lib/x86_64-linux-gnu/libpthread.so.0 /lib/x86_64-linux-gnu/libpthread.so.0
COPY --from=build /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so.1
COPY --from=build /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
COPY --from=build /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
COPY --from=build /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/libm.so.6
CMD /iot-rest
