FROM microsoft/dotnet:2.1.302-sdk-alpine3.7 as builder

COPY ./source/services/service2 /src/services/service
COPY ./source/common /src/common

WORKDIR /src/services/service

RUN dotnet publish -o /app -c release

FROM microsoft/dotnet:2.1.2-aspnetcore-runtime-alpine3.7 as runner
COPY --from=builder /app /app

WORKDIR /app
EXPOSE 80
ENTRYPOINT [ "dotnet", "service2.dll" ]