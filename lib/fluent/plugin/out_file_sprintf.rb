# -*- encoding : utf-8 -*-
module Fluent
  class FileSprintfOutput < Fluent::TimeSlicedOutput
    Fluent::Plugin.register_output('file_sprintf', self)

    config_param :path, :string
    config_param :format, :string
    config_param :compress, :bool, :default => true
    config_param :include_tag_key, :bool, :default => false
    config_param :tag_key_name, :string, :default => "tag"
    config_param :include_time_key, :bool, :default => false
    config_param :time_key_name, :string, :default => "time"
    config_param :key_names, :string
    config_param :time_format, :string, :default => "%Y-%m-%d %H:%M:%S"
    config_param :rotate_format, :string, :default => "%Y%m%d"
    config_param :file_prefix_key, :string, :default => "Time.at(time).strftime(@rotate_format)"

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
          result = "Time.at(time).strftime('#{@time_format}')"
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
      $log.info "flush_interval => #{@flush_interval}"
    end

    def format(tag, time, record)
      if @include_tag_key
        record[@tag_key_name] = tag
      end
      if @include_time_key
        record[@time_key_name] = Time.at(time).strftime(@time_format)
      end
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      write_file(chunk)
      compress_file
    end

    private
    def write_file(chunk)
      set = Set.new
      chunk.msgpack_each do |tag, time, record|
        set.add(eval(@file_prefix_key))
      end

      filename_hash = {}
      set.each{|prefix|
        filename_hash[prefix] = File.open(@path + '.' + prefix,'a')
      }

      chunk.msgpack_each do |tag, time, record|
        result = eval(@eval_string)
        file = filename_hash[eval(@file_prefix_key)]
        file.puts result
      end

      filename_hash.each{|k,v|
        v.close
      }
    end

    def compress_file
      if @compress
        Dir.glob( "#{@path}.*[^gz]" ).each{ |output_path|
          if Time.now > File.mtime(output_path) + (@flush_interval * 5)
            Zlib::GzipWriter.open(output_path + ".gz") do |gz|
              gz.mtime = File.mtime(output_path)
              gz.orig_name = output_path
              gz.write IO.binread(output_path)
            end
            FileUtils.remove_file(output_path, force = true)
          end
        }
      end
    end

  end
end
