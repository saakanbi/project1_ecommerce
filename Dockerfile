# Use OpenJDK 17 as base image
FROM openjdk:17

# Copy the built jar into the container
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# Run the jar file
ENTRYPOINT ["java", "-jar", "/app.jar"]
