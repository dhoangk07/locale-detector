class Repo < ApplicationRecord
  # Schema Repos table
  #   t.string "url"
  #   t.datetime "created_at", null: false
  #   t.datetime "updated_at", null: false
  #   t.string "name"
  #   t.integer "user_id"
  #   t.text "compare"
  #   t.string "description"
  #   t.string "homepage"
  validate :valid_url?
  validates :name, uniqueness: true
  belongs_to :user
  has_many :subscribes, dependent: :destroy
  serialize :compare, Hash
  
  def fetch_description_from_github
    array_datas = Github.repos.list user: "#{split(url)}"
    array_datas.body.each do |array_data|
      if array_data.clone_url == url
        description = array_data.description
        homepage = array_data.homepage
        self.update(description: description, homepage: homepage)
      end
    end
  end

  def split(url)
    %r{/([^/]+)/([^/]+)/?\z}o.match(url)[1]
  end

  def star_github_small
    "https://ghbtns.com/github-btn.html?user=#{split(url)}&repo=#{name}&type=star&count=true&size=small"
  end

  def fork_github_small
    "https://ghbtns.com/github-btn.html?user=#{split(url)}&repo=#{name}&type=fork&count=true&size=small"
  end

  def read_file_read_me
    File.read("#{cloned_source_path}/README.md") if Dir.exist?("#{cloned_source_path}")
  end
  
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

  ## fetch
  ## 1. rug.remotes['origin'].fetch
  ## 2. rug.checkout(rug.branches["origin/master"], strategy: :force)
  def pull_code
    # TODO: need to handle exception or conflicts
    # TODO: need to check the repo has legacy code
    rugged = Rugged::Repository.new(cloned_source_path)
    rugged.remotes['origin'].fetch
    rugged.checkout(rugged.branches["origin/master"], strategy: :force)
  end

  def cloned_source_path
    "tmp/#{name}"
  end

  def self.detect_missing_keys
    Repo.all.each do |repo|
      if Dir.exists?(repo.locale_path) == false
        repo.run_clone
      else
        repo.pull_code
      end
      repo.run_compare
      repo.send_email_if_missing_keys
    end
  end

  def self.delete_folder_github(cloned_source_path)
    FileUtils.rm_rf(cloned_source_path)
  end

  def valid_url?
    url_regexp = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
    errors.add(:url, "Please input correct Url") unless self.url =~ url_regexp 
  end

  def conver_to_git_path
    self.url[-1] == '/' ? self.url.chomp!('/') : self.url
    url = self.url + ".git" 
    name = self.name.gsub(/[-]/, ' ').gsub(/[_]/, ' ').humanize
    self.update(url: url, name: name)
  end
  
  def self.search(search)
    search ? self.where('name ILIKE ?', "%#{search}%") : self
  end

  def send_email_if_missing_keys
    if self.compare != {} 
      UserMailer.notify_missing_key_on_locale_for_owner(self.user, self).deliver_now
      user_subscribed_id = self.subscribes.last.user_id if self.subscribes.present?
      user_subscribed = User.find(user_subscribed_id)
      UserMailer.notify_missing_key_on_locale_for_subscribe(user_subscribed, self).deliver_now
    end
  end

  def self.count_search(search)
    self.search(search).count
  end
end

