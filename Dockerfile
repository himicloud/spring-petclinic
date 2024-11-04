# Use an official OpenJDK runtime as a base image
FROM openjdk:17-jdk-alpine

# Create a directory for the app
WORKDIR /app

# Copy the JAR file built by Maven or Gradle into the Docker image
COPY target/spring-petclinic-*.jar app.jar

# Expose the port the app will run on
EXPOSE 8080

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
