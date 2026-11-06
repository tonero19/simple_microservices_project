# Stage 1: Build execution layer using a cached Temurin JDK compiler
FROM maven:3.9.6-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY pom.xml .
# Cache dependencies before copying source code
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Light runtime execution environment
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8082

# The critical magic: SerialGC drops memory footprint by avoiding massive parallel GC threads
ENTRYPOINT ["sh", "-c", "java $JVM_OPTS -XX:+UseSerialGC -Xss512k -Xms128m -Xmx256m -jar app.jar"]
