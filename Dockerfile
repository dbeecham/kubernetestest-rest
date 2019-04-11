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

FROM rust:1.33-slim
WORKDIR /
COPY --from=build /iot-rest/target/release/iot-rest /iot-rest
CMD /iot-rest
