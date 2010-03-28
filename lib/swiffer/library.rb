module Swiffer
  class Library < Base
    def self.default_options
      super.merge(
        :swc => lambda { |l| File.join(l.output_path, "#{l.title}.swc") }
      )
    end
    
    def initialize(&block)
      super
      self.library = true
    end
  
    def build
      options = super
      
      source_files = Dir.glob File.join(src_path, '**/*.as')
      source_files.map! do |file|
        file.gsub("#{src_path}/", '').gsub(/\.as$/, '').gsub('/', '.')
      end
      
      options << "-include-classes=#{source_files.join(',')}" unless source_files.empty?
      options << "-output=#{swc}"
      
      exe :compc, options.join(' ')
    end
  end
end
