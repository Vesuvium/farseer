# Farseer

[![Hex.pm](https://img.shields.io/hexpm/v/farseer.svg?style=for-the-badge)](https://hex.pm/packages/farseer)
[![Travis (.com)](https://img.shields.io/travis/com/strangemachines/farseer.svg?style=for-the-badge)](https://travis-ci.com/strangemachines/farseer)
[![Hexdocs](https://img.shields.io/badge/docs-hexdocs-blueviolet.svg?style=for-the-badge)](https://hexdocs.pm/farseer)

A configurable Elixir API gateway.

## Getting started

Install with:

```sh
mix archive.install hex farseer
```

Check the installation with:

```sh
farseer version
```

Create a `farseer.yml` file with:

```sh
farseer example
```

Run the example with:

```sh
farseer run --port 8000
```

## Quickstart

Simple configuration:

```yaml
farseer: "0.5.0"
endpoints:
  /test:
    methods:
      - get
      - post
    to: "https://internalservice:3000"
  /login:
    methods:
      - post
  to: "https://loginservice"
```


Specifying an handler:


```yaml
/upload:
  methods:
    - get
  handler: Json
  response:
    message: "hello world"
```

Transformations:

```yaml
/login:
  methods:
    - post:
        request:
          body:
            - extra_field: "value" # adds a field to the request body
    - patch:
        request:
          headers:
            add:
              - Bearer: "$TOKEN" # adds an header to the request using an env var
  to: "https://example.com"
  transform:
    data:
      items: body.object # returns body.objects instead of body.items
    headers:
      delete:
        - X-service-header
      add:
        - X-awesome-header: "value"
```

Error handling:

```yaml
/login:
  methods:
    - post
  to: https://loginservice
  errors:
    - 500: 401 # transform 500 in 401
    - 414: # transform 414 in 401, with custom message
      status: 401
      message: "teapots are not welcome!"
    - any: 401 # transform any error in a 401
```
