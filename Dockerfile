FROM alpine:3.20

RUN apk add --no-cache bash iputils procps

COPY app/ /app/

RUN chmod +x /app/diagnostic.sh /app/health-check.sh

WORKDIR /app

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD ["/app/health-check.sh"]

ENTRYPOINT ["/app/diagnostic.sh"]
CMD ["help"]
