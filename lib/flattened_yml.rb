class FlattenedYml
  def self.process_hash(translations, current_key, hash)
    hash.each do |new_key, value|
      combined_key = [current_key, new_key].delete_if { |k| k == '' }.join(".")
      if value.is_a?(Hash)
        process_hash(translations, combined_key, value)
      else
        translations[combined_key] = value
      end
    end
  end

  def self.flattened_version_of_yml file=nil, root=nil
    target_file = nil
    if !file.nil?
      target_file = file
    else
      raise 'Unable to load target file!'
    end

    require 'yaml'

    yml_version = YAML::load(IO.read(target_file))
    # p yml_version[locale]

    if root.nil?
      root = yml_version.keys.first
    end

    flattend_version = {}
    process_hash(flattend_version, '', yml_version[root])
    flattend_version
  end
end
