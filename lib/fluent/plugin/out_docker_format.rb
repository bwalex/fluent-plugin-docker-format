require 'json'

module Fluent
  class DockerFormatOutput < Output
    Fluent::Plugin.register_output('docker_format', self)
    config_param :tag, :string
    config_param :container_id, :string
    config_param :docker_containers_path, :string, :default => '/var/lib/docker/containers'

    def configure(conf)
      super
      @id_to_name = {}
    end

    def emit(tag, es, chain)
      es.each do |time,record|
	record = format_record(tag, record)
        Engine.emit(interpolate_tag(tag, record), time, record)
      end

      chain.next
    end

    private

    def interpolate(tag, str)
      tag_parts = tag.split('.')

      str.gsub(/\$\{tag_parts\[(\d+)\]\}/) { |m| tag_parts[$1.to_i] }
    end

    def interpolate_tag(tag, record)
      record.reduce(interpolate(tag, @tag)) do |t, (key, value)|
        t.gsub(/\$\{#{key}\}/, value)
      end
    end

    def get_name_from_cfg(id)
      begin
        docker_cfg = JSON.parse(File.read("#{@docker_containers_path}/#{id}/config.json"))
	# Remove the leading '/'
        container_name = docker_cfg['Name'][1..-1]
      rescue
        container_name = nil
      end
      container_name
    end

    def get_name(id)
      @id_to_name[id] = get_name_from_cfg(id) unless @id_to_name.has_key? id
      @id_to_name[id]
    end

    def format_record(tag, record)
      full_id = interpolate(tag, @container_id)
      record['full_id'] = full_id
      record['id'] = full_id[0..12]
      record['name'] = get_name(full_id) || "<unknown>"
      record
    end
  end
end
