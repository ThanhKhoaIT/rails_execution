class RailsExecution::AutoSuggestionsService

  def initialize
    @all_names = []
    @patterns = Array(RailsExecution.configuration.auto_suggestions)
  end

  def call
    load_folders!
    all_names.uniq
  end

  private

  attr_reader :patterns
  attr_reader :all_names

  def load_folders!
    patterns.each do |pattern|
      Dir[Rails.root.join(pattern, '**', '*.rb')].each do |file|
        load_file(file)
      end
    end
  end

  def load_file(file)
    modules = []
    File.readlines(file).each do |line|
      if match_data = line.match(/module\s+([\w:]+)|class\s+([\w:]+)/)
        modules << match_data.captures.compact.join('::')
      end
    end
    classname = modules.join('::')
    @all_names << classname
  end
end
