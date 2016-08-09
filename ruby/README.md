## Quick Example for a Ruby Worker (5 minutes)

This example will show you how to test and deploy Ruby code to IronWorker.

**Note**: Be sure you've followed the base [getting started instructions on the top level README](https://github.com/iron-io/dockerworker).

### 1. Vendor dependencies (if you update your Gemfile, rerun this):

```sh
docker run --rm -v "$PWD":/worker -w /worker iron/ruby:dev bundle install --standalone --clean
```

If you have issues during the above build/bundle stage, see [Ruby Troubleshooting](https://github.com/iron-io/dockerworker/wiki/Ruby-Troubleshooting).

Then require the vendored gems. Notice in `hello.rb`, we add the following so it uses the vendored gems:

```ruby
require_relative 'bundle/bundler/setup'
```

### 2. Test locally

Now test it locally:

```sh
docker run --rm -it -e "PAYLOAD_FILE=hello.payload.json" -e "YOUR_ENV_VAR=ANYTHING" -v "$PWD":/worker -w /worker iron/ruby:dev ruby hello.rb
```

The PAYLOAD_FILE environment variable is passed in to your worker automatically and tells you
where the payload file is. Our [client libraries](http://dev.iron.io/worker/libraries/) help you load the special environment variables automatically.

The YOUR_ENV_VAR environment variable is your custom environment variable. There can
be any number of custom environment variables and they can be anything.

Boom, it works! And now that it works, we know it will work on IronWorker.

### 3. Package your code

Let's package it up inside a Docker image and upload it to a Docker Registry. Copy the [Dockerfile](https://github.com/iron-io/dockerworker/blob/master/ruby/Dockerfile) from this repository
and modify the ENTRYPOINT line to run your script, but for this example, it's all ready to go:

```sh
docker build -t USERNAME/hello:0.0.1 .
```

That's just a standard `docker build` command. The 0.0.1 is the version which you can update
whenever you make changes to your code.

Test your image, just to be sure you created it correctly:

```sh
docker run --rm -it -e "PAYLOAD_FILE=hello.payload.json" -e "YOUR_ENV_VAR=ANYTHING" USERNAME/hello:0.0.1
```

### 4. Push it to Docker Hub

Push it to Docker Hub:

```sh
docker push USERNAME/hello:0.0.1
```

### 4. Register your image with Iron

Ok, we're ready to run this on Iron now, but first we have to let Iron know about the
image you just pushed to Docker Hub. Also, you can optionally register environment variables here that will be passed into your container at runtime.

```sh
iron register -e "YOUR_ENV_VAR=ANYTHING" USERNAME/hello:0.0.1
```

### 5. Queue / Schedule jobs for your image

Now you can start queuing jobs or schedule recurring jobs for your image. Let's quickly
queue up a job to try it out.

```sh
iron worker queue --payload-file hello.payload.json --wait USERNAME/hello
```

Notice we don't use the image tag when queuing, this is so you can change versions
without having to update all your code that's queuing up jobs for the image.

The `--wait` parameter waits for the job to finish, then prints the output.
You will also see a link to [HUD](http://hud.iron.io) where you can see all the rest of the task details along with the log output.

Of course, in practice you'll be
[queuing up jobs via the API](http://dev.iron.io/worker/reference/api/#queue_a_task),
most likely using one of our
[client libraries](http://dev.iron.io/worker/libraries/).
Here's a curl example to show how easy it is to do in any language:

```sh
curl -H "Content-Type: application/json" -H "Authorization: OAuth $IRON_TOKEN" \
 -d '{"tasks":[{"code_name":"USERNAME/hello","payload":"{\"name\":\"Travis\"}"}]}' \
 "http://worker-aws-us-east-1.iron.io/2/projects/$IRON_PROJECT_ID/tasks"
```

Just copy the above, change `USERNAME` to your Docker Hub username and paste it into a terminal
to queue up a task.

## Private images

If you want to keep your code private and use a [private Docker repository](https://docs.docker.com/docker-hub/repos/#private-repositories), you just need
to let Iron know how to access your private images:

```sh
iron docker login -e YOUR_DOCKER_HUB_EMAIL -u YOUR_DOCKER_HUB_USERNAME -p YOUR_DOCKER_HUB_PASSWORD
```

Then just do everything the same as above.

## If you don't want to package your code using Docker

You can package and send your code to Iron directly with the instructions below.
Start with steps 1 and 2 above, then continue at step 3 here.

### 3. Package your code

Let's package it up:

```sh
zip -r hello.zip .
```

### 4. Upload your code

Then upload it:

```sh
iron worker upload --name hello --zip hello.zip iron/ruby ruby hello.rb
```

### 5. Queue / Schedule jobs for your worker

Now you can start queuing jobs or schedule recurring jobs for your worker. Let's quickly
queue up a job to try it out.

```sh
iron worker queue --payload-file hello.payload.json --wait hello
```

The `--wait` parameter waits for the job to finish, then prints the output.
You will also see a link to [HUD](http://hud.iron.io) where you can see all the rest of the task details along with the log output.
