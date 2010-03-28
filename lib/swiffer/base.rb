module Swiffer
  class Base
    def self.default_options
      @default_options ||= {
        :title              => '',
        :author             => '',
        :description        => '',
        :version            => '',
        :src_path           => 'src',
        :output_path        => 'bin',
        :docs_path          => 'docs',
        :source_paths       => lambda { |p| [ p.src_path ] },
        :library_paths      => [],
        :build_options      => '',
        :build_docs_options => '',
        :library            => false,
        :docs_title         => lambda { |p| "#{p.title} API Documentation" }
      }
    end
    
    def initialize(config_file = nil, &block)
      @options = self.class.default_options.dup
      
      self.instance_eval(&block) if block_given?
      
      if config_file && yaml = YAML.load_file(config_file)
        yaml.each do |key, value|
          @options[key.to_sym] = value
        end
      end
    end
    
    def library?
      !!library
    end
    
    def build
      options  = [ "-source-path=#{source_paths.join(',')}" ]
      options << "-library-path=#{library_paths.join(',')}" unless library_paths.empty?
      options << build_options unless build_options.empty?
      options
    end

    def build_docs
      options  = [ "-main-title='#{docs_title}' -doc-sources=#{src_path}" ]
      options << build_docs_options unless build_docs_options.empty?
      options << "-output=#{docs_path}"
      
      exe :asdoc, options.join(' ')
    end
    
  protected
  
    def exe(command, options = nil)
      command  = command.to_s
      command << '.exe' if RUBY_PLATFORM =~ /(mswin32|cygwin)/
      system [ command, options ].reject(&:nil?).join(' ')
    end
    
    def method_missing(method, *args, &block)
      if method.to_s.match /(\w+)=/
        @options[$1.to_sym] = args.first
      elsif args.length == 1
        @options[method.to_sym] = args.first
      else
        option = @options[method.to_sym]
        unless option.nil?
          option.is_a?(Proc) ? option.call(self) : option
        else
          super
        end
      end
    end
  end
end
