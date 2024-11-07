# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# This stage is used when running from VS in fast mode (Default for Debug configuration)
#FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base

# Use UBI (Universal Base Image) with .NET on IBM Power architecture
FROM registry.access.redhat.com/ubi8/dotnet-80:latest AS base
USER app
WORKDIR /app
EXPOSE 8080


# This stage is used to build the service project
#FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
FROM registry.access.redhat.com/ubi8/dotnet-80:latest AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["SampleOCPApp.csproj", "."]
RUN dotnet restore "./SampleOCPApp.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "./SampleOCPApp.csproj" -c $BUILD_CONFIGURATION -o /app/build

# This stage is used to publish the service project to be copied to the final stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./SampleOCPApp.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production or when running from VS in regular mode (Default when not using the Debug configuration)
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SampleOCPApp.dll"]