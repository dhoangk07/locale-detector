class Repo < ApplicationRecord
  def path
    return "tmp/#{name}/config/locales"
  end

  def run_compare
    Dir.foreach(path) do |file|
      CompareFile.compare('en.yml', file, self) if File.extname(file) == '.yml' && file != 'simple_form.en.yml' && file != 'devise.en.yml'
    end
  end

  def run_clone
    Rugged::Repository.clone_at(self.url, "tmp/#{self.name}")
  end
end

