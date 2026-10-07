# frozen_string_literal: true

require 'rails_helper'

# The checks i18n-tasks does not provide. Missing, unused and non-normalized keys are
# checked by the `i18n-tasks` steps of the `Tests` CI job.
RSpec.describe 'I18n locale files' do # rubocop:disable RSpec/DescribeClass
  def flatten_translations(hash, prefix = nil)
    hash.each_with_object({}) do |(key, value), flat|
      path = [prefix, key].compact.join('.')
      if value.is_a?(Hash)
        flat.merge!(flatten_translations(value, path))
      else
        flat[path] = value
      end
    end
  end

  def load_translations(files)
    backend = I18n::Backend::Simple.new
    backend.load_translations(*files)
    flatten_translations(backend.translations(do_init: false))
  end

  # Gems are installed under Rails.root in CI (vendor/bundle), so app files are told apart by
  # their directory rather than by Rails.root.
  let(:app_locales_dir) { Rails.root.join('config/locales').to_s }
  let(:locale_files) { I18n.load_path.map { |path| File.expand_path(path.to_s) }.uniq }
  let(:app_files) { locale_files.select { |path| path.start_with?("#{app_locales_dir}/") } }
  let(:gem_files) { locale_files - app_files }
  let(:app_translations_by_file) { app_files.index_with { |file| load_translations([file]) } }

  it 'does not repeat a translation a gem already provides with the same value' do
    gem_translations = load_translations(gem_files)

    duplicates = app_translations_by_file.flat_map do |file, translations|
      translations.select { |key, value| gem_translations.key?(key) && gem_translations[key] == value }
                  .map { |key, _value| "#{key} (#{File.basename(file)})" }
    end

    expect(duplicates).to be_empty, "Already provided by a gem with the same value, delete them:\n#{duplicates.join("\n")}"
  end

  it 'does not define a key in more than one app locale file' do
    files_by_key = Hash.new { |hash, key| hash[key] = [] }
    app_translations_by_file.each do |file, translations|
      translations.each_key { |key| files_by_key[key] << File.basename(file) }
    end

    duplicates = files_by_key.select { |_key, files| files.size > 1 }
                             .map { |key, files| "#{key} (#{files.join(', ')})" }

    expect(duplicates).to be_empty, "Defined in several files of config/locales:\n#{duplicates.join("\n")}"
  end
end
