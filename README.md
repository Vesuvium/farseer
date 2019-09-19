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
farseer: 1
endpoints:
    test:
        path: /test
        methods:
            - get
            - post
        to: "https://internalservice:3000"
    login:
        path: /login
        methods:
            - post
        to: "https://loginservice"
```


Specifying an handler:


```yaml
login:
    path: /upload
    methods:
        - post
    handler: "Farseer.Handlers.S3"
```

Transformations:

```yaml
login:
    path: /login
    methods:
        - post
        - patch:
            headers:
                - Bearer: "my token" # adds an header to the request
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
login:
    path: /login
    methods:
        - post
    to: "https://loginservice"
    errors:
        - 500: 401 # transform 500 in 401
        - 414: # transform 414 in 401, with custom message
            status: 401
            message: "teapots are not welcome!"
        - any: 401 # transform any error in a 401
```
