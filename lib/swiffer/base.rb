require 'yaml'

module Swiffer
  class Base
    def self.default_options
      @default_options ||= {
        :src_path      => 'src',
        :output_path   => 'bin',
        :docs_path     => 'docs',
        :source_paths  => lambda { |p| [ p.src_path ] },
        :library_paths => [],
        :library       => false,
        :docs_title    => lambda { |p| "#{p.title} API Documentation" }
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
    
    def build(extra_options = nil)
      options  = [ "-source-path=#{source_paths.join(',')}" ]
      options << "-library-path=#{library_paths.join(',')}" if library_paths? and not library_paths.empty?
      options << build_options if build_options?
      options << extra_options unless extra_options.nil?
      options
    end

    def build_docs(extra_options = nil)
      options  = [ "-main-title='#{docs_title}' -doc-sources=#{src_path}" ]
      options << build_docs_options if build_docs_options?
      options << extra_options unless extra_options.nil?
      options << "-output=#{docs_path}"
      
      exe :asdoc, options.join(' ')
    end
    
  protected
  
    def exe(command, options = nil)
      command  = command.to_s
      command << '.exe' if RUBY_PLATFORM =~ /(mswin32|cygwin)/
      command << ' ' + options unless options.nil?
      system(command)
    end
    
    def method_missing(method, *args, &block)
      method_name = method.to_s
      
      case args.length
      when 1
        @options[method_name.chomp('=').to_sym] = args.first
      when 0
        if method_name.chomp!('?')
          !!@options[method_name.to_sym]
        else
          option = @options[method_name.to_sym]
          option.is_a?(Proc) ? option.call(self) : option
        end
      else
        super
      end
    end
  end
end
