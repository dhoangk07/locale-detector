require 'yaml'
class FlattenKey
  def self.perform(hash, prefix = '')
    keys = []
    hash.keys.each do |key|
      if hash[key].is_a? Hash
        current_prefix = prefix + "#{key}."
        keys << perform(hash[key], current_prefix)
      else
        keys << "#{prefix}#{key}"
      end
    end
    prefix == "" ? keys.flatten : keys
  end

  def self.read_file_yml(yml_file)
    YAML.load_file(yml_file)
  end
end

