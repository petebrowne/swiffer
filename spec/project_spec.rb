require File.expand_path('../spec_helper', __FILE__)

describe 'A basic Project' do
  before do
    @project = Swiffer::Project.new
    @project.title = 'MyProject'
  end

  it 'should default #src_path to "src"' do
    @project.src_path.should == 'src'
  end

  it 'should default #output_path to "bin"' do
    @project.output_path.should == 'bin'
  end

  it 'should default #docs_path to "docs"' do
    @project.docs_path.should == 'docs'
  end

  it 'should include the #src_path in #source_paths' do
    @project.source_paths.should include(@project.src_path)
  end

  it 'should default #library_paths to an empty array' do
    @project.library_paths.should == []
  end
  
  it 'should not be a library' do
    @project.should_not be_library
  end
  
  it "should default #swf to the output path, using the project's title" do
    @project.swf.should == "#{@project.output_path}/#{@project.title}.swf"
  end

  it 'should throw an error when accessing #swc' do
    lambda { @project.swc }.should raise_error
  end

  it "should include the project's title in the #docs_title" do
    @project.docs_title.should include(@project.title)
  end
  
  describe 'running #build_docs' do
    it 'should run the asdoc command' do
      mock(@project).system %r{^asdoc(\.exe)?}
      @project.build_docs
    end
    
    it 'should include the #docs_title' do
      mock(@project).system %r{ -main-title='#{@project.docs_title}'}
      @project.build_docs
    end
    
    it 'should include the #src_path' do
      mock(@project).system %r{ -doc-sources=#{@project.src_path}}
      @project.build_docs
    end
    
    it 'should output to the #docs_path' do
      mock(@project).system %r{ -output=#{@project.docs_path}}
      @project.build_docs
    end
  
    it 'should include any extra options' do
      @project.build_docs_options '-some-option=true'
      mock(@project).system %r{ -some-option=true }
      @project.build_docs
    end
  end
  
  describe 'running #build' do
    before do
      @project.document_class 'MyProject.as'
    end
    
    it 'should run the mxmlc command' do
      mock(@project).system %r{^mxmlc(\.exe)?}
      @project.build
    end
    
    it 'should include the #src_path' do
      mock(@project).system %r{ -source-path=#{@project.src_path}}
      @project.build
    end
    
    it 'should output to the #swf file' do
      mock(@project).system %r{ -output=#{@project.swf}}
      @project.build
    end
    
    it 'should end with the #document_class' do
      mock(@project).system %r{ #{@project.document_class}$}
      @project.build
    end
  
    it 'should include any extra options' do
      @project.build_options '-some-option=true'
      mock(@project).system %r{ -some-option=true }
      @project.build
    end
    
    it 'should include all the #source_paths' do
      @project.source_paths = [ 'src', 'vendor/TweenLite/src', 'vendor/Papervision3D/src' ]
      mock(@project).system %r{ -source-path=#{@project.source_paths.join(',')}}
      @project.build
    end
  
    it 'should include all the #library_paths' do
      @project.library_paths = [ 'vendor/TweenLite/src', 'vendor/Papervision3D/src' ]
      mock(@project).system %r{ -library-path=#{@project.library_paths.join(',')}}
      @project.build
    end
  end
end

describe 'Configuring a Project' do
  describe 'with a block' do
    before do
      @project = Swiffer::Project.new do
        title            'MyProject'
        src_path         'lib'
        custom_attr      'My Attribute'
        library_paths << 'vendor/TweenLite/src'
      end
    end
  
    it 'should change the #title' do
      @project.title.should == 'MyProject'
    end
  
    it 'should change the #src_path' do
      @project.src_path.should == 'lib'
    end
  
    it 'should include the new library path' do
      @project.library_paths.should include('vendor/TweenLite/src')
    end
  
    it 'should set the custom attribute' do
      @project.custom_attr.should == 'My Attribute'
    end
  
    it 'should include the #src_path in the #source_paths' do
      @project.source_paths.should include(@project.src_path)
    end
  end
  
  describe 'with a config file' do
    before do
      mock(YAML).load_file('config.yml') {
        {
          :title        => 'MyProject',
          :source_paths => [ 'lib' ]
        }
      }
      @project = Swiffer::Project.new('config.yml')
    end
  
    it 'should change the #title' do
      @project.title.should == 'MyProject'
    end
    
    it 'should change the #source_paths' do
      @project.source_paths.should == [ 'lib' ]
    end
  end
end