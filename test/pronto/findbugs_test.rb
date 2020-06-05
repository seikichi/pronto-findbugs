require 'test_helper'

require 'fileutils'
require 'pathname'
require 'tmpdir'

class FindbugsTest < Test::Unit::TestCase
  DummyRepository = Struct.new('DummyRepository', :path) do
    def blame(_path, _lineno)
      nil
    end
  end

  test '#run returns empty array when patches are nil' do
    findbugs = Pronto::Findbugs.new(nil)

    assert_equal([], findbugs.run)
  end

  test '#run returns messages when violations are found' do
    Dir.mktmpdir do |dir|
      xml = <<-REPORT_XML
      <?xml version="1.0" encoding="UTF-8"?>
      <BugCollection>
        <Project>
          <SrcDir>#{dir}/src/main/java</SrcDir>
        </Project>
        <BugInstance type="ES_COMPARING_STRINGS_WITH_EQ" abbrev="ES" category="BAD_PRACTICE">
          <LongMessage>FOO</LongMessage>
          <SourceLine start="1" end="1" sourcepath="foo/bar/App.java"></SourceLine>
        </BugInstance>
        <BugInstance type="ES_COMPARING_STRINGS_WITH_EQ" abbrev="ES" category="BAD_PRACTICE">
          <LongMessage>BAR</LongMessage>
          <SourceLine start="42" end="42" sourcepath="foo/bar/App.java"></SourceLine>
        </BugInstance>
      </BugCollection>
      REPORT_XML

      ENV.store('PRONTO_FINDBUGS_REPORTS_DIR', dir)
      File.write(File.join(dir, 'main.xml'), xml)

      FileUtils.mkdir_p(File.join(dir, 'src/main/java/foo/bar/'))
      File.write(File.join(dir, 'src/main/java/foo/bar/App.java'), '// dummy')

      findbugs = Pronto::Findbugs.new(create_new_file_patches(dir, 'src/main/java/foo/bar/App.java'))
      messages = findbugs.run

      assert_equal(1, messages.size)
      assert_equal('src/main/java/foo/bar/App.java', messages[0].path)
      assert_equal('FOO', messages[0].msg)
    end
  end

  test '#run works against findbugs reports without messages' do
    Dir.mktmpdir do |dir|
      xml = <<-REPORT_XML
        <?xml version="1.0" encoding="UTF-8"?>
        <BugCollection>
          <Project>
            <SrcDir>#{dir}/src/main/java</SrcDir>
          </Project>
          <BugInstance type="ES_COMPARING_STRINGS_WITH_EQ" abbrev="ES" category="BAD_PRACTICE">
            <SourceLine start="1" end="1" sourcepath="foo/bar/App.java"></SourceLine>
          </BugInstance>
        </BugCollection>
      REPORT_XML

      ENV.store('PRONTO_FINDBUGS_REPORTS_DIR', dir)
      File.write(File.join(dir, 'main.xml'), xml)

      FileUtils.mkdir_p(File.join(dir, 'src/main/java/foo/bar/'))
      File.write(File.join(dir, 'src/main/java/foo/bar/App.java'), '// dummy')

      findbugs = Pronto::Findbugs.new(create_new_file_patches(dir, 'src/main/java/foo/bar/App.java'))
      messages = findbugs.run

      assert_equal(1, messages.size)
      assert_equal('src/main/java/foo/bar/App.java', messages[0].path)
      assert_equal(:warning, messages[0].level)
      assert_equal('type=ES_COMPARING_STRINGS_WITH_EQ category=BAD_PRACTICE', messages[0].msg)
    end
  end

  test '#run skips findbugs reports that does not contains SrcDir information' do
    xml = <<-REPORT_XML
    <?xml version="1.0" encoding="UTF-8"?>
    <BugCollection>
      <Project></Project>
      <BugInstance type="ES_COMPARING_STRINGS_WITH_EQ" abbrev="ES" category="BAD_PRACTICE">
        <SourceLine start="1" end="1" sourcepath="foo/bar/App.java"></SourceLine>
      </BugInstance>
    </BugCollection>
    REPORT_XML

    Dir.mktmpdir do |dir|
      ENV.store('PRONTO_FINDBUGS_REPORTS_DIR', dir)
      File.write(File.join(dir, 'main.xml'), xml)

      findbugs = Pronto::Findbugs.new(create_new_file_patches('/path/to', 'src/main/java/foo/bar/App.java'))
      messages = findbugs.run

      assert_equal(0, messages.size)
    end
  end

  private

  def create_new_file_patches(repo_path, new_file_path)
    repo = DummyRepository.new(Pathname.new(repo_path))
    patch = Rugged::Patch.from_strings(nil, "added\n", new_path: new_file_path)
    [Pronto::Git::Patch.new(patch, repo)]
  end
end
