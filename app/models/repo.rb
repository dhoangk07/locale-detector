class Repo < ApplicationRecord
  # create_table "repos", force: :cascade do |t|
  #   t.string "url"
  #   t.datetime "created_at", null: false
  #   t.datetime "updated_at", null: false
  #   t.string "name"
  #   t.integer "user_id"
  #   t.text "compare"
  #   t.string "description"
  #   t.string "homepage"
  # end
  # validates :url, uniqueness: true
  validate :valid_url?
  validates :name, uniqueness: true
  belongs_to :user
  has_many :subscribes, dependent: :destroy
  serialize :compare, Hash
  
  def fetch_from_github
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

  def star_github_large
    "https://ghbtns.com/github-btn.html?user=#{split(url)}&repo=#{name}&type=star&count=true&size=large"
  end

  def fork_github_large
    "https://ghbtns.com/github-btn.html?user=#{split(url)}&repo=#{name}&type=fork&count=true&size=large"
  end

  def read_file_read_me
    File.read("#{cloned_source_path}/README.md")
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

  def cloned_source_path
    "tmp/#{name}"
  end

  def self.routine_task
    Repo.all.each do |repo|
      # if Dir.exists?(repo.cloned_source_path)
      #   # TODO: fetch
      # else
        # repo.run_clone
        UserMailer.notify_missing_key_on_locale_for_owner(repo.user).deliver_now
        user_subscribed_id = self.subscribes.last.user_id
        user_subscribed = User.find(user_subscribed_id)
        UserMailer.notify_missing_key_on_locale_for_subscribe(user_subscribed).deliver_now
      # end
      # do next
      # 1. run compare
      # 2. if have missing keys, send email to owner & subscribers
      # 3. There is a link to Repo/show in the email.
      # 
      # 4. Repo/show: display missing keys
    end
  end

  def delete_folder_github
    FileUtils.rm_rf("#{cloned_source_path}")
  end
  def valid_url?
    url_regexp = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
    errors.add(:url, "Please input correct Url") unless self.url =~ url_regexp 
  end
  def self.search(search)
    search ? self.where('name ILIKE ?', "%#{search}%") : self
  end
end

