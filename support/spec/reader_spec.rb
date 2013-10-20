require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Reader" do
  describe "execution" do    
    it "should pipe the output to the engine" do
		reader = SASS::Reader::compile_file(FILEPATH, PROJECT)
		reader.should match(/^\nConverting(.*)\nDone$/), "expected success message, got #{reader.inspect}"
		file = FILEPATH.gsub(/.scss/, '.css')
		FileUtils.rm( file )
    end

  end

  describe "failure" do    
    it "should pipe the output to the engine" do
		file =  File.expand_path(File.join(File.dirname(__FILE__), "../fixtures", "invalid.scss"))
		reader = SASS::Reader::compile_file(file, PROJECT)
		reader.should match(/(.*)\nSass syntax error!\n(.*)/), "expected error message, got #{reader.inspect}"
    end

  end

  describe "filenames" do
    it "should require a filename" do
      lambda { SASS::Reader::compile_file }.should raise_error
    end
  end

end
