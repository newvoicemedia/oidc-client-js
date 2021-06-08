# Build Info for oidc-client-js

> Auto-generated file by Vonage CLI

## tl;dr

To run the build pipeline locally, run each individual task:

```bash
$ rake -f Rakefile.CI version
1.0.0
```

```bash
$ rake -f Rakefile.CI build
...
```

```bash
$ rake -f Rakefile.CI test
...
```

```bash
$ rake -f Rakefile.CI package
...
```

```bash
$ rake -f Rakefile.CI test_integration
...
```

```bash
$ rake -f Rakefile.CI cleanup
...
```

You can also run all phases like this:

```bash
$ rake -f Rakefile.CI all
...
```

or

```bash
$ rake -f Rakefile.CI
...
```

> Some phases are optional and not mandated by configuration. There are `test`, `package`, `test_integration`.
> Listed here as CI will always run all of these regarless of current project configuration.

## Build

This stage does the following:

1. Auto-login to the AWS ECR to pull the necessary base image in case no active session is active;
2. Builds and runs the Docker build image: `oidc-client-js:build`;
3. Build the code inside the running docker image.

```bash
$ rake -f Rakefile.CI build
...
```

### Using `docker-compose` Directly

Ensuring we have an active session to AWS ECR:

```bash
$ aws ecr get-login --region eu-west-1 --no-include-email | bash
...
```

> No `bash`? Run the command without `| bash` and then execute the output command to proceed.

First, build and start the `build` service container from `docker-compose.ci.yml`
```bash
$ docker-compose up -d --build build
...
```

Then execute the build commands:

```bash
$ docker-compose exec -T build \
    bundle exec rake build
```

## Test

This stage runs the unit tests.

```bash
$ rake -f Rakefile.CI test
...
```

## Package

This stage packages the artefacts

```bash
$ rake -f Rakefile.CI package
...
```

## Integration Test

This stage uses the docker-compose.test.yml to stand-up the service and it dependencies, then run the integration tests.

```bash
$ rake -f Rakefile.CI test_integration
...
```

## Cleanup

This stage cleans up any previous build or docker artefacts.

```bash
$ rake -f Rakefile.CI cleanup
...
```
