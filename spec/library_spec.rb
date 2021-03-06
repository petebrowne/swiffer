require File.expand_path('../spec_helper', __FILE__)

describe 'Library' do
  let(:library) do
    library = Swiffer::Library.new
    library.title = 'MyLibrary'
    library
  end
  
  it 'should be a library' do
    library.should be_library
  end
  
  it "should default #swc to the output path, using the library's title" do
    library.swc.should == "#{library.output_path}/#{library.title}.swc"
  end
  
  describe '#build' do
    it 'should output to the #swc file' do
      mock(library).system %r{ -output=#{library.swc}}
      library.build
    end
    
    it 'should all classes found in the #src_path' do
      stub(Dir).glob('lib/*.swc') { [] }
      mock(Dir).glob('src/**/*.as') {
        [
          'src/org/swiffer/core/Base.as',
          'src/org/swiffer/core/Library.as',
          'src/org/swiffer/core/Project.as',
          'src/org/swiffer/Swiffer.as'
        ]
      }
      mock(library).system %r{ -include-classes=org\.swiffer\.core\.Base,org\.swiffer\.core\.Library,org\.swiffer\.core\.Project,org\.swiffer\.Swiffer}
      library.build
    end
  end
end
