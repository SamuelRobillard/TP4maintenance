# Build stage with Maven (using the latest Maven image)
FROM maven:latest AS build

# Define working directory
WORKDIR /app

# Copy the pom.xml from /src/api and download dependencies
COPY src/api/pom.xml ./api/pom.xml
RUN mvn -f ./api/pom.xml dependency:go-offline

# Copy the source code into the image
COPY src/api/src ./api/src

# Compile the application, skipping tests
RUN mvn -f ./api/pom.xml clean package -DskipTests

# Deployment stage with a lightweight Java 17 image
FROM eclipse-temurin:17-jre-alpine

# Define working directory
WORKDIR /app

# Copy the compiled JAR from the build stage
COPY --from=build /app/api/target/todo-0.0.1-SNAPSHOT.jar /app/todo-app.jar

# Expose port for the application
EXPOSE 8080

# Command to run the app
ENTRYPOINT ["java", "-jar", "todo-app.jar"]

