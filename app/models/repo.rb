class Repo < ApplicationRecord
  belongs_to :user
  serialize :compare, Hash

  def locale_path
    "#{cloned_source_path}/config/locales"
  end

  def match_locale(file)
    supported_locales = ["af", "ar", "az", "be", "bg", "bn", "bs", "ca", "cs", "cy", "da", "de", "de_AT", "de_CH", "de_DE", "el", "el_CY", "en", "en_AU", "en_CA", "en_GB", "en_IE", "en_IN", "en_NZ", "en_US", "en_ZA", "en_CY", "eo", "es", "es_419", "es_AR", "es_CL", "es_CO", "es_CR", "es_EC", "es_ES", "es_MX", "es_NI", "es_PA", "es_PE", "es_US", "es_VE", "et", "eu", "fa", "fi", "fr", "fr_CA", "fr_CH", "fr_FR", "gl", "he", "hi", "hi_IN", "hr", "hu", "id", "is", "it", "it_CH", "ja", "ka", "km", "kn", "ko", "lb", "lo", "lt", "lv", "mk", "ml", "mn", "mr_IN", "ms", "nb", "ne", "nl", "nn", "oc", "or", "pa", "pl", "pt", "pt_BR", "rm", "ro", "ru", "sk", "sl", "sq", "sr", "sw", "ta", "te", "th", "tl", "tr", "tt", "ug", "ur", "uz", "vi", "wo", "zh_CN", "zh_HK", "zh_TW", "zh_YUE"]
    return true if supported_locales.include?(file)
  end

  def run_compare
    hash = {}
    Dir.foreach(locale_path) do |file|
      # it does not work if it has another gem which supported locales
      basename = File.basename(file, '.yml')
      if match_locale(basename)
        temp = CompareFile.compare('en.yml', file, self) 
        hash[file] = temp 
      end
    end
    result = hash.select{|k,v| v.present?}
    self.update(compare: result)
  end

  def run_clone
    Rugged::Repository.clone_at(self.url, cloned_source_path)
  end

  def cloned_source_path
    "tmp/#{name}"
  end

  def self.routine_task
    Repo.each do |repo|
      if Dir.exists?(repo.cloned_source_path)
        # TODO: fetch
      else
        repo.run_clone
      end
      # do next
      # 1. run compare
      # 2. if have missing keys, send email to owner & subscribers
      # 3. There is a link to Repo/show in the email.
      # 
      # 4. Repo/show: display missing keys
      repo.run_compare
    end
  end

  
end

