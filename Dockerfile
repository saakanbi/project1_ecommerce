FROM openjdk:17-jdk-slim
COPY target/ecommerce-1.0.0.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
EXPOSE 8080
# Build the application JAR file before building the Docker image