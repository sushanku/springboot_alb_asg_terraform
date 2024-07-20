# Building with multistage to optimize the image size
# Stage 1: caching for build speed
FROM gradle:8.7-jdk17 AS cache
RUN mkdir -p /home/gradle/cache_home
ENV GRADLE_USER_HOME=/home/gradle/cache_home
COPY . /home/gradle/java-code/
WORKDIR /home/gradle/java-code
RUN ./gradlew clean build


# stage 2: Build application with gradle
FROM gradle:8.7-jdk17 AS build
COPY --from=cache /home/gradle/cache_home /home/gradle/.gradle
WORKDIR /app
COPY . .
RUN ./gradlew clean build -x test


# Stage 2: Deploy the application
FROM openjdk:17-jdk-slim
ARG RELEASE_VERSION=3.3.0
WORKDIR /app
COPY --from=build /app/build/libs/*-$RELEASE_VERSION.jar petclinic.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "petclinic.jar"]