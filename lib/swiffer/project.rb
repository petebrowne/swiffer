module Swiffer
  class Project < Base
    def self.default_options
      super.merge(
        :system_chrome => 'standard',
        :visible       => true,
        :transparent   => false,
        :minimizable   => true,
        :maximizable   => true,
        :resizable     => true,
        :swf           => lambda { |p| File.join(p.output_path, "#{p.title}.swf") },
        :launch_xml    => lambda { |p| File.join(p.output_path, "#{p.title}-launch.xml") }
      )
    end
    
    def build(extra_options = '')
      options = super << "-output=#{swf} #{document_class}"
      exe :mxmlc, options.join(' ')
    end
    
    def launch
      File.open(launch_xml, 'w') do |file|
        template = Tilt::ERBTemplate.new File.expand_path('../templates/launch.xml.erb', __FILE__)
        file.write template.render(nil, { :project => self })
      end
      exe :adl, "#{launch_xml} ."
    end
  end
end
