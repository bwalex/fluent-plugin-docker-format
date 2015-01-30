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

The output record will have the following additional fields:
  - `name`: container name, e.g. `saint_stallman`
  - `full_id`: full id of the container,
    e.g. `ffb4d30ab540b43e040a4cebbf968137cb0f17e21e61e90547113dfb83e3df79`
  - `id`: abbreviated id of the container, e.g. `ffb4d30ab540`

#### A full example

Consider following config:

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
  container_id ${tag_parts[-3]}
  tag docker.${name}.${id}.${stream}
</match>
```

Then an input event

```json
tag = docker.var.lib.docker.containers.ffb4d30ab540b43e040a4cebbf968137cb0f17e21e61e90547113dfb83e3df79.ffb4d30ab540b43e040a4cebbf968137cb0f17e21e61e90547113dfb83e3df79-json.log
time = 2015-01-29T22:01:28.583281971Z
record = {
  "stream":"stdout",
  "log": "actual log line",
}
```

will become:

```json
tag = docker.saint_stallman.ffb4d30ab540.stdout
time = 2015-01-29T22:01:28.583281971Z
record = {
  "name": "saint_stallman",
  "id": "ffb4d30ab540",
  "full_id": "ffb4d30ab540b43e040a4cebbf968137cb0f17e21e61e90547113dfb83e3df79",
  "stream":"stdout",
  "log": "actual log line",
}
```

## Option Parameters

- container_id

    The container id.

    The parameter value is interpolated with the following placeholders:
      - `${tag}`: the input tag
      - `${tag_parts[N]}`: input tag splitted by '.' indexed with `N` such as
        `${tag_parts[0]}`, `${tag_parts[-1]}`. 

- tag

    The output tag.

    Tag parameter value is interpolated with the following placeholders:
      - `${tag}`: input tag
      - `${tag_parts[N]}`: input tag splitted by '.' indexed with `N` such as
        `${tag_parts[0]}`, `${tag_parts[-1]}`. 
      - `${<field>}`: any record field including the new fields
	(`id`, `full_id` and `name`)

- docker_containers_path (optional)

    The path to docker containers directory;
    defaults to `/var/lib/docker/containers`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
