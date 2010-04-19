#! /usr/bin/env ruby
require 'erb'
require 'yaml'
# %w(erb yaml).each &method(:require) # ooo... look how clever i am. pffftt...

def error(message) puts(message) || exit end
def file(file) "#{File.dirname(__FILE__)}/#{file}" end

if ARGV.include? '--example'
  example = file:'config.yml.example'
  error open(example).read
end

env_in  = ENV['POUND_CONFIG_YAML']
env_out = ENV['POUND_CONFIG_FILE']

if ARGV.empty? && !env_in
  error "Usage: generate_pound_config [config file] [out file]"
end

overwrite = %w(-y -o -f --force --overwrite).any? { |f| ARGV.delete(f) }

filename = env_in || ARGV.shift || 'config.yml'
config   = YAML.load(ERB.new(File.read(filename)).result)
template = \
  if custom_template_index = (ARGV.index('--template') || ARGV.index('-t'))
    custom = ARGV[custom_template_index+1]
    unless File.exist?(custom)
      error "=> Specified template file #{custom} does not exist."
    end
    ARGV.delete_at(custom_template_index) # delete the --argument
    ARGV.delete_at(custom_template_index) # and its value
    custom
  else
    file:'pound.erb'
  end

output_filename = env_out || ARGV.shift || 'pound.conf'
if File.exists?(output_filename) && !overwrite
  error "=> #{output_filename} already exists, won't overwrite it.  Quitting."
else
  output = ERB.new(File.read(template), nil, '>').result(binding)
  open(output_filename, 'w+').write(output)
  error "=> Wrote #{output_filename} successfully."
end
