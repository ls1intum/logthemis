# Logthemis Server

The Logthemis Server is a web server providing REST Endpoints to manage the Logthemis chat interaction between the client and the AI microservice.

## Setup

The server can be started with the following command:

```bash
docker-compose up -d
```

Please make sure, that the SSL certificates are available for the container.

## Endpoints

- GET `/`
  - Arguments:
    - `message`: The message to send to the AI
    - `sessionId`: The id of the current session, enables chat history
    - `logFile`: name of the log file to be searched
  - Returns:
    - `200`: If the message was sent successfully
