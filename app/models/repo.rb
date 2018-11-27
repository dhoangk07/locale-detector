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
  include AASM
  aasm do
    state :created, initial: true
    state :cloned
    state :compared
    state :pulled

    event :do_cloning do 
      transitions from: [:created], to: :cloned
    end  

    event :do_comparing do
      transitions from: [:cloned, :pulled], to: :compared
    end

    event :do_pulling do
      transitions from: [:compared], to: :pulled
    end
  end
  validate :valid_url?
  validates :name, :url, uniqueness: true, presence: true
  belongs_to :user
  has_many :subscribes,  dependent: :destroy
  has_many :locale_keys
  serialize :compare, Hash
  
  def fetch_description_from_github
    array_datas = Github.repos.list user: "#{split(url)}", auto_pagination: true
    array_datas.body.each do |array_data|
      if array_data.clone_url == url
        description = array_data.description
        homepage = array_data.homepage
        update(description: description, homepage: homepage)
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
    File.read("#{cloned_source_path}/README.md") if Dir.exist?(cloned_source_path)
  end
  
  def locale_path
    "#{cloned_source_path}/config/locales"
  end

  def locale_path_exist?
    Dir.exist?(locale_path)
  end
  
  def match_locale?(file)
    supported_locales = ["af", "ar", "az", "be", "bg", "bn", "bs", "ca", "cs", "cy", "da", "de", "de_AT", "de_CH", "de_DE", "el", "el_CY", "en", "en_AU", "en_CA", "en_GB", "en_IE", "en_IN", "en_NZ", "en_US", "en_ZA", "en_CY", "eo", "es", "es_419", "es_AR", "es_CL", "es_CO", "es_CR", "es_EC", "es_ES", "es_MX", "es_NI", "es_PA", "es_PE", "es_US", "es_VE", "et", "eu", "fa", "fi", "fr", "fr_CA", "fr_CH", "fr_FR", "gl", "he", "hi", "hi_IN", "hr", "hu", "id", "is", "it", "it_CH", "ja", "ka", "km", "kn", "ko", "lb", "lo", "lt", "lv", "mk", "ml", "mn", "mr_IN", "ms", "nb", "ne", "nl", "nn", "oc", "or", "pa", "pl", "pt", "pt_BR", "rm", "ro", "ru", "sk", "sl", "sq", "sr", "sw", "ta", "te", "th", "tl", "tr", "tt", "ug", "ur", "uz", "vi", "wo", "zh_CN", "zh_HK", "zh_TW", "zh_YUE"]
    supported_locales.include?(file)
  end

  def available_locales
    result = []
    Dir.foreach(locale_path) do |file|
      basename = File.basename(file, '.yml')
      result << file if match_locale?(basename)
    end
    result
  end

  def multi_language_support?
    available_locales != ['en.yml']
  end

  def locale_keys_of_repo_existing?
    LocaleKey.where(repo_id: self.id).present?
  end

  def run_compare_yml_file
    Dir.foreach(locale_path) do |file|
      basename = File.basename(file, '.yml')
      if match_locale?(basename)
        locale_files = FlattenedYml.flattened_version_of_yml("#{locale_path}/#{file}")
        locale_files.each do |key, value|
          if locale_keys_of_repo_existing?
            change_data_of_locale_key(update, file, key, value, self)
          else
            change_data_of_locale_key(create, file, key, value, self)
          end
        end
      end
    end
  end

  def run_compare
    run_compare_yml_file
    en_keys = LocaleKey.where(repo_id: self.id, locale: 'en').distinct.pluck(:key)
    locale_lists = locale_keys.select('locale').where.not(locale: 'en').distinct 
    hash = {}
    locale_lists.each do |locale| 
      keys = LocaleKey.where(repo_id: self.id, locale: locale.locale.remove('.yml')).distinct.pluck(:key)
      different_keys = en_keys - keys
      hash[locale.locale] = different_keys if different_keys != [] 
    end
    self.update(compare: hash)
    self.do_comparing!
  end

  def run_clone
    Rugged::Repository.clone_at(self.url, cloned_source_path)
    self.do_cloning!
  end

  def pull_code
    rugged = Rugged::Repository.new(cloned_source_path)
    rugged.remotes['origin'].fetch
    rugged.checkout(rugged.branches["origin/master"], strategy: :force)
    self.do_pulling!
  end

  def cloned_source_path
    "tmp/#{name}"
  end

  def self.detect_missing_keys_daily
    Repo.all.each do |repo|
      if !Dir.exists?(repo.locale_path)
        repo.run_clone
      else
        repo.pull_code
      end
      previous_compare = repo.compare
      repo.run_compare
      daily_compare = repo.compare
      repo.send_email_if_missing_keys if previous_compare === daily_compare
    end
  end

  def self.delete_folder_github(path)
    FileUtils.rm_rf(path)
  end

  def valid_url?
    url_regexp = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
    errors.add(:url, "Please input correct Url") unless self.url =~ url_regexp 
  end

  def convert_to_git_path
    self.url[-1] == '/' ? self.url.chomp!('/') : self.url
    url = self.url + ".git" 
    name = self.name.gsub(/[-]/, ' ').gsub(/[_]/, ' ').humanize
    update(url: url, name: name)
  end
  
  def self.search(search)
    search ? self.where('name ILIKE ?', "%#{search}%") : self
  end

  def send_email_if_missing_keys
    if compare != {} 
      UserMailer.notify_missing_key_on_locale_for_owner(self.user, self).deliver_now
      if self.subscribes.present?
        subscribes.each do |subscribe|
          user_subscribed = User.find(subscribe.user_id)
          UserMailer.notify_missing_key_on_locale_for_subscribe(user_subscribed, self).deliver_now
        end
      end
    end
  end

  def self.count_search(search)
    self.search(search).count
  end
end

