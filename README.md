# Fluent::Plugin::Docker::Format

This fluentd output filter plugin can parse a docker container's config.json associated with a certain log entry and add information from config.json to the record.


## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-docker-format'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-docker-format


## Usage

```
<match docker.var.lib.docker.containers.*.*.log>
  type docker_format
  docker_containers_path /var/lib/docker/containers
  container_id ${tag_parts[5]}
  tag docker.all
</match>
```

The `docker_containers_path` is optional and defaults to `/var/lib/docker/containers`.

The `container_id` parameter can either be a string with the id, or use the special interpolated substitution `${tag_parts[<some number>]}`. The tag parts are the dot-separated parts of the incoming tag, so that in the above example they would match the first star.

A full example:

```
<source>
  type tail
  path /var/lib/docker/containers/*/*-json.log
  pos_file /var/log/fluentd-docker.pos
  time_format %Y-%m-%dT%H:%M:%S
  tag docker.*
  format json
</source>

<match docker.var.lib.docker.containers.*.*.log>
  type docker_format
  container_id ${tag_parts[5]}
  tag docker.all
</match>
```

The output record will have two additional fields, `container_id` and `container_name`.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
