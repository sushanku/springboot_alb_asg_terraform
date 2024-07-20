# Building with multistage to optimize the image size
# stage 1: Build application with gradle
FROM gradle:8.7-jdk17 AS build
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