# Build stage
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
# Copia pom.xml
COPY pom.xml .
# Copia código fonte do backend mantendo a estrutura esperada pelo pom.xml
COPY backend/src ./backend/src
RUN mvn -q -DskipTests clean package

# Run stage
FROM eclipse-temurin:17-jre
WORKDIR /app
# Copia o JAR executável gerado pelo Spring Boot
# O Spring Boot repackage cria um JAR executável com todas as dependências
COPY --from=build /app/target/SubscriptionManager-1.0-SNAPSHOT.jar app.jar
COPY backend/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
