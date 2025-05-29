<<<<<<< HEAD
FROM maven:3.8-openjdk-11 as build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/ecommerce-1.0-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
=======
# Use OpenJDK 17 as base image
FROM openjdk:17

# Copy the built jar into the container
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# Run the jar file
ENTRYPOINT ["java", "-jar", "/app.jar"]
>>>>>>> 943ee0b81e73be5ba97817c57c11e5f82a79519b
