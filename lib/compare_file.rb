require "yaml"
class CompareFile
  def self.flatten_keys(hash, prefix="")
    keys = []
    hash.keys.each do |key|
      if hash[key].is_a? Hash
        current_prefix = prefix + "#{key}."
        keys << flatten_keys(hash[key], current_prefix)
      else
        keys << "#{prefix}#{key}"
      end
    end
    prefix == "" ? keys.flatten : keys
  end

  def self.compare(locale_1, locale_2, repo)
    yaml_1 = YAML.load_file("#{repo.path}/#{locale_1}")
    yaml_2 = YAML.load_file("#{repo.path}/#{locale_2}")
    keys_1 = flatten_keys(yaml_1[yaml_1.keys.first])
    keys_2 = flatten_keys(yaml_2[yaml_2.keys.first])
    missing = keys_2 - keys_1
    if missing.any?
      puts "#{locale_2} is missing from #{locale_1}:"
      missing.each { |key| puts "  - #{key}" }
    end
  end
end