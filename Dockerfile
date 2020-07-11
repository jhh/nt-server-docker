FROM gradle:jdk11 as builder

COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle --no-daemon build

FROM openjdk:11-jre-slim
EXPOSE 1735
COPY --from=builder /home/gradle/src/build/distributions/nt-server-docker.tar /app/
WORKDIR /app
RUN tar -xvf nt-server-docker.tar
WORKDIR /app/nt-server-docker
CMD bin/nt-server-docker