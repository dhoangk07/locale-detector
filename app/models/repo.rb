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
    github = Github.new client_id: ENV['CLIENT_ID'], client_secret: ENV['APP_SECRET']
    result = github.repos.get(user_name(url), repo_name(url))
    description = result.description
    homepage = result.homepage
    self.update(description: description, homepage: homepage)
  end

  def user_name(url)
    %r{/([^/]+)/([^/]+)/?\z}o.match(url)[1]
  end

  def repo_name(url)
    %r{/([^/]+)/([^/]+)/?\z}o.match(url)[2].remove('.git')
  end

  def star_github_small
    "https://ghbtns.com/github-btn.html?user=#{user_name(url)}&repo=#{name}&type=star&count=true&size=small"
  end

  def fork_github_small
    "https://ghbtns.com/github-btn.html?user=#{user_name(url)}&repo=#{name}&type=fork&count=true&size=small"
  end

  def read_file_read_me
    if Dir.exist?(cloned_source_path)
      readme = File.read("#{cloned_source_path}/README.md") 
      update(readme: readme)
    end
  end
  
  def locale_path
    "#{cloned_source_path}/config/locales"
  end

  def locale_path_exist?
    update(locale_exist: true) if Dir.exist?(locale_path)
  end
  
  def match_locale?(file)
    supported_locales = ["af", "ar", "az", "be", "bg", "bn", "bs", "ca", "cs", "cy", "da", "de", "de_AT", "de_CH", "de_DE", "el", "el_CY", "en", "en_AU", "en_CA", "en_GB", "en_IE", "en_IN", "en_NZ", "en_US", "en_ZA", "en_CY", "eo", "es", "es_419", "es_AR", "es_CL", "es_CO", "es_CR", "es_EC", "es_ES", "es_MX", "es_NI", "es_PA", "es_PE", "es_US", "es_VE", "et", "eu", "fa", "fi", "fr", "fr_CA", "fr_CH", "fr_FR", "gl", "he", "hi", "hi_IN", "hr", "hu", "id", "is", "it", "it_CH", "ja", "ka", "km", "kn", "ko", "lb", "lo", "lt", "lv", "mk", "ml", "mn", "mr_IN", "ms", "nb", "ne", "nl", "nn", "oc", "or", "pa", "pl", "pt", "pt_BR", "rm", "ro", "ru", "sk", "sl", "sq", "sr", "sw", "ta", "te", "th", "tl", "tr", "tt", "ug", "ur", "uz", "vi", "wo", "zh_CN", "zh_HK", "zh_TW", "zh_YUE"]
    supported_locales.include?(file)
  end

  def locale_keys_of_repo_existing?
    LocaleKey.where(repo_id: self.id).present?
  end

  def change_data_on_localekeys_table
    available_locales = []
    Dir.foreach(locale_path) do |file|
      basename = File.basename(file, '.yml')
      if match_locale?(basename)
        available_locales << file
        locale_files = FlattenYmlFile.perform("#{locale_path}/#{file}")
        locale_files.each do |key, value|
          if locale_keys_of_repo_existing? 
            self.locale_keys.where(locale: basename, key: key).update(value: value)
          else
            LocaleKey.create(locale: basename, key: key, value: value, repo_id: self.id)
          end
        end
      end
    end
    update(multi_language_support: true) if available_locales != ['en.yml']
  end

  def run_compare
    en_keys = LocaleKey.where(repo_id: self.id, locale: 'en').distinct.pluck(:key)
    available_locales = locale_keys.select('locale').where.not(locale: 'en').distinct 
    hash = {}
    available_locales.each do |name| 
      keys = LocaleKey.where(locale: name.locale).distinct.pluck(:key)
      different_keys = en_keys - keys
      hash[name.locale] = different_keys if different_keys != [] 
    end
    update(compare: hash)
    do_comparing!
  end

  def run_clone
    Rugged::Repository.clone_at(self.url, cloned_source_path)
    do_cloning!
  end

  def pull_code
    rugged = Rugged::Repository.new(cloned_source_path)
    rugged.remotes['origin'].fetch
    rugged.checkout(rugged.branches["origin/master"], strategy: :force)
    do_pulling!
  end

  def cloned_source_path
    "tmp/#{name}"
  end

  def self.detect_missing_keys_daily
    Repo.find_each do |repo|
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

  def self.update_repos_table
    Repo.find_each do |repo|
      repo.fetch_description_from_github
      repo.read_file_read_me
      repo.convert_to_git_path
      repo.locale_path_exist?
    end
  end

  def stop_send_email(user)
    Subscribe.where(user_id: user.id, repo_id: self.id).delete_all
  end

  def self.count_search(search)
    self.search(search).count
  end
end

