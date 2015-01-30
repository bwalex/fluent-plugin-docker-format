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

The `tag` parameter either be:
 - a string with the id
 - use the special interpolated substitution `${tag_parts[<some number>]}`.
   The tag parts are the dot-separated parts of the incoming tag,
   so that in the above example they would match the first star.
 - use the special interpolated substitution `${<field>}`,
   where `field` is the field of the record,
   including the new fields: `name`, `full_id` and `id` (see below).

The output record will have the following additional fields:
  - `name`: container name, e.g. `saint_stallman`
  - `full_id`: full id of the container,
    e.g. `ffb4d30ab540b43e040a4cebbf968137cb0f17e21e61e90547113dfb83e3df79`
  - `id`: abbreviated id of the container, e.g. `ffb4d30ab540`

### A full example:

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
  tag docker.${name}.${id}.${stream}
</match>
```

So if an input event was

```json
{
  "tag": "docker.var.lib.docker.containersffb4d30ab540b43e040a4cebbf968137cb0f17e21e61e90547113dfb83e3df79.ffb4d30ab540b43e040a4cebbf968137cb0f17e21e61e90547113dfb83e3df79-json.log",
  "time":"2015-01-29T22:01:28.583281971Z",
  "stream":"stdout",
  "log": "actual log line",
}
```

it will become:

```json
{
  "tag": "docker.saint_stallman.ffb4d30ab540.stdout",
  "time":"2015-01-29T22:01:28.583281971Z",
  "name": "saint_stallman",
  "id": "ffb4d30ab540",
  "full_id": "ffb4d30ab540b43e040a4cebbf968137cb0f17e21e61e90547113dfb83e3df79",
  "stream":"stdout",
  "log": "actual log line",
}
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
