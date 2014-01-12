# -*- encoding : utf-8 -*-
module Fluent
  class FileSprintfOutput < Fluent::TimeSlicedOutput
    Fluent::Plugin.register_output('file_sprintf', self)

    config_param :path, :string
    config_param :file_size_limit, :integer ,:default => 8388608
    config_param :format, :string
    config_param :compress, :bool, :default => true
    config_param :key_names, :string
    config_param :time_format, :string, :default => "%Y-%m-%d %H:%M:%S"

    def initialize
      super
      require 'zlib'
      require 'ltsv'
    end

    def start
      super
    end

    def shutdown
      super
    end

    def configure(conf)
      super
      @key_names = @key_names.split(',').map{|key|
        key = key.strip
        result = ""
        if key == 'time'
          result = "Time.at(time).strftime('#{time_format}')"
        elsif key == 'tag'
          result = 'tag'
        elsif key == 'ltsv'
          result = 'LTSV.dump(record)'
        elsif key == 'json'
          result = 'record.to_json'
        elsif key == 'msgpack'
          result = 'record.to_msgpack'
        else
          result = "record['" + key + "']"
        end
        result
      }
      @key_names = @key_names.join(',')
      @eval_string = "%Q{#{@format}} % [#{@key_names}]"
      $log.info "format => #{@eval_string}"
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      filepath = @path
      file_size = 0
      File.open(filepath,'a') { |file|
        chunk.msgpack_each do |tag, time, record|
          result = eval(@eval_string)
          file.puts result
        end
        file_size = file.size
      }

      if file_size > @file_size_limit
        if @compress
          Zlib::GzipWriter.open(@path + "." + "#{Fluent::Engine.now}" + ".gz") do |gz|
            gz.mtime = File.mtime(filepath)
            gz.orig_name = filepath
            gz.write IO.binread(filepath)
          end
        else
          FileUtils.cp filepath, @path + "." + "#{Fluent::Engine.now}"
        end
        FileUtils.remove_file(filepath, force = true)
      end
    end

  end
end
