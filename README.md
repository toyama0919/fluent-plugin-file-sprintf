# fluent-plugin-file-sprintf

sprintf output file plugin for Fluentd.

## Installation

### td-agent(Linux)

    /usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-file-sprintf

### td-agent(Mac)

    sudo /usr/local/Cellar/td-agent/1.1.XX/bin/fluent-gem install fluent-plugin-file-sprintf

### fluentd only

    gem install fluent-plugin-file-sprintf

## parameter

param    |   value|exsample
--------|------|------
compress|file compress gzip(default:true)|true
buffer_path|buffer file path(require)|/tmp/buffer/test.ltsv.*.log
path|output file path(require)|/tmp/test.ltsv
format|sprintf format(require)|%s
key_names|key names comma separator(require)|ltsv
time_format|time value output format(default:%Y-%m-%d %H:%M:%S)|%Y-%m-%d %H:%M:%S
include_tag_key|tag key in record|true
tag_key_name|tag key name(default:tag)|tag_name
include_time_key|time key in record|true
time_key_name|time key name(default:time)|timestamp
rotate_format|file rotate format(default:%Y%m%d)|%Y%m%d

## key_names reserved words

param    |   value|
--------|------|
time|output time string
tag|output tag string
ltsv|output ltsv string
msgpack|output msgpack string
json|output json string


## Configuration Exsample(json format)

	<match apache.json>
		type file_sprintf
		compress true
		buffer_path /tmp/buffer/apache.json.*.log
		path /tmp/apache.json
		format %s
		key_names json
	</match>

## Configuration Exsample(labeled tsv format)

	<match apache.ltsv>
		type file_sprintf
		compress true
		buffer_path /tmp/buffer/apache.ltsv.*.log
		path /tmp/apache.ltsv
		format %s
		key_names ltsv
	</match>

## Configuration Exsample(message pack format)

	<match apache.ltsv>
		type file_sprintf
		compress true
		buffer_path /tmp/buffer/apache.msgpack.*.log
		path /tmp/apache.msgpack
		format %s
		key_names msgpack
	</match>

## Configuration Exsample(custom json format)

	<match apache.myjson>
		type file_sprintf
		compress true
		buffer_path /tmp/buffer/apache.json.*.log
		path /tmp/apache.json
		format {"method":"%s","agent":"%s","referer":"%s","path":"%s","host":"%s","time":"%s","tag":"%s"}
		key_names method,agent,referer,path,host,time,tag
	</match>

## Configuration Exsample(tsv format)

	<match apache.tsv>
		type file_sprintf
		compress true
		buffer_path /tmp/buffer/apache.tsv.*.log
		path /tmp/apache.tsv
		format %s\t%s\t%s\t%s\t%s\t%s\t%s
		key_names method,agent,referer,path,host,time,tag
	</match>

## Configuration Exsample(elasticsearch bulk import format. multiline format)

	<store>
		type file_sprintf
		compress false
		buffer_path /tmp/buffer/es.json.*.log
		path /tmp/es.json
		format { "index" : { "_index" : "test_index", "_type" : "test_type" } }\n%s
		key_names json
	</store>


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
