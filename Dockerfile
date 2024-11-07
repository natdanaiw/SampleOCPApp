# Use the Red Hat UBI 8 .NET 8 image as the base image
FROM registry.access.redhat.com/ubi8/dotnet-80:latest AS build

# Set the working directory within the container
WORKDIR /app

# Copy the project files into the container
COPY *.csproj ./

# Ensure permissions for the working directory
RUN chmod -R 777 /app

# Restore the project dependencies
RUN dotnet restore

# Copy the rest of the application code
COPY . .

# Publish the application in Release mode to the /app/out folder
RUN dotnet publish -c Release -o /app/out

# Use the Red Hat UBI 8 .NET 8 runtime image for the final build stage
FROM registry.access.redhat.com/ubi8/dotnet-80-runtime:latest AS runtime

# Set the working directory to /app
WORKDIR /app

# Copy the published output from the build stage
COPY --from=build /app/out ./

# Expose port 8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "SampleOCPApp.dll"]