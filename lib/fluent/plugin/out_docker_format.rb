require 'json'

module Fluent
  class DockerFormatOutput < Output
    Fluent::Plugin.register_output('docker-format', self)
    config_param :tag, :string
    config_param :container_id, :string
    config_param :docker_containers_path, :string, :default => '/var/lib/docker/containers'

    def configure(conf)
      super
      @container_name = "<unknown>"

      @docker_cfg = JSON.parse(File.read("#{@docker_containers_path}/#{@container_id}/config.json"))
      @container_name = @docker_cfg['Name']
    end

    def emit(tag, es, chain)
      es.each do |time,record|
        Engine.emit(@tag, time, format_record(record))
      end

      chain.next
    end

    private

    def format_record(record)
      record['container_id'] = @container_id
      record['container_name'] = @container_name
      record
    end
  end
end
