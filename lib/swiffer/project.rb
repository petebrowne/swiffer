module Swiffer
  class Project < Base
    def self.default_options
      super.merge(
        :document_class => '',
        :swf            => lambda { |p| File.join(p.output_path, "#{p.title}.swf") }
      )
    end
    
    def build
      options = super << "-output=#{swf} #{document_class}"
      
      exe :mxmlc, options.join(' ')
    end
    
    def run
      exe :open, swf
    end
  end
end
