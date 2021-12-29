FROM mcr.microsoft.com/dotnet/aspnet:6.0-focal AS base
WORKDIR /app
EXPOSE 5000

ENV ASPNETCORE_URLS=http://+:5000

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS build
WORKDIR /src
COPY ["CloudNative_Day2.csproj", "./"]
RUN dotnet restore "CloudNative_Day2.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "CloudNative_Day2.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CloudNative_Day2.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CloudNative_Day2.dll"]
