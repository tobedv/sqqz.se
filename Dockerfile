FROM python:3.6-alpine
LABEL Name=sqqz.se Version=1.0.0

WORKDIR /app

RUN apk update && \
     apk add --virtual build-deps gcc musl-dev && \
     apk add postgresql-dev

COPY Pipfile* ./
RUN pip install --no-cache-dir --trusted-host pypi.python.org pipenv && \
    pipenv install --deploy --system
RUN apk del build-deps

ADD ./src ./

EXPOSE 8000

ENTRYPOINT ["gunicorn"]
CMD ["--workers=1", \
      "--worker-class=gevent", \
      "--worker-connections=1024", \
      "--access-logfile=-", \
      "--access-logformat=%(h)s - %(u)s %(t)s \"%(r)s\" %(s)s %(b)s \"%(f)s\" \"%(a)s\" %(D)s", \
      "--error-logfile=-", \
      "--log-level=error", \
      "--timeout=20", \
      "--graceful-timeout=5", \
      "--bind=0.0.0.0:8000", \
      "app:application"]