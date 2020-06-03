
FROM maven:3.6.3-jdk-8 AS builder
WORKDIR /home/mvn
COPY . .
RUN mvn clean install 

FROM openjdk:8-jdk-alpine
COPY --from=builder /home/mvn/target/*.jar ./app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","./app.jar"]