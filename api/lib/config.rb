# frozen_string_literal: true

require 'singleton'
require 'toml-rb'

def flatten_hash_to_str_keys(hash)
  result_hash = {}
  hash.each do |key, value|
    if value.is_a? Hash
      flattened = flatten_hash_to_str_keys value
      flattened.each { |subkey, value| result_hash["#{key}_#{subkey}"] = value }
    else
      result_hash[key] = value
    end
  end
  result_hash
end

def str_hash_to_sym_hash(hash)
  result_hash = {}
  hash.each do |key, value|
    result_hash[key.to_sym] = value
  end
  result_hash
end

# Global configuration instead of using environment variables
class Config
  include Singleton

  def initialize
    @config_paths = ['./gitme.toml', '~/.gitme/gitme.toml', '~/.config/gitme.toml', '/etc/gitme/gitme.toml']

    @current_config_path = @config_paths.find { |path| File.file?(path) }

    if @current_config_path.nil?
      valid_path_string = @config_paths.select { |s| "'#{s}'" }.join(', ')
      raise "Missing config file please create a config file at one of these locations: #{valid_path_string}"
    end

    @config = str_hash_to_sym_hash flatten_hash_to_str_keys TomlRB.parse(File.read(@current_config_path))
  end

  def loaded_config_path
    @current_config_path
  end

  def [](config_name)
    @config[config_name]
  end
end
