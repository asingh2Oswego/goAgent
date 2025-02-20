## This is a multi-stage Dockerfile for efficiency
## and size reduction of the final Docker image.
## We specify the base image we need for our
## go application
FROM 817615305328.dkr.ecr.us-east-1.amazonaws.com/golang AS build
## Copy source
WORKDIR /app
COPY . .
## Download required modules 
RUN go mod download
## Build a statically-linked Go binary for Linux
RUN CGO_ENABLED=0 GOOS=linux go build -a -o agent .
## New build phase -- create binary-only image
FROM 817615305328.dkr.ecr.us-east-1.amazonaws.com/alpine
## Add support for HTTPS
RUN apk update && \
    apk upgrade && \
    apk add ca-certificates
## Work Directory
WORKDIR /
## Copy files from previous build container
COPY --from=build /app/agent ./
## Check results
RUN env && pwd && find .
## Start the application
CMD ["./agent"]
