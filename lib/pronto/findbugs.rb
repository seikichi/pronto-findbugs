require 'pronto'
require 'rexml/document'

module Pronto
  class Findbugs < Runner
    def run
      return [] unless @patches

      @patches
        .select(&method(:valid_patch?))
        .flat_map(&method(:inspect))
        .compact
    end

    private

    Offence = Struct.new(:path, :line, :message)

    def findbugs_reports_dir
      ENV['PRONTO_FINDBUGS_REPORTS_DIR'] || (raise 'Please set `PRONTO_FINDBUGS_REPORTS_DIR` to use pronto-findbugs')
    end

    def valid_patch?(patch)
      patch.additions > 0
    end

    def inspect(patch)
      offences = findbugs_offences.select { |offence| offence.path == patch.new_file_full_path.to_s }

      offences.flat_map do |offence|
        patch.added_lines
             .select { |line| line.new_lineno == offence.line }
             .map { |line| new_message(offence, line) }
      end
    end

    def findbugs_offences
      @findbugs_offences ||=
        begin
          pattern = File.join(findbugs_reports_dir, '**', '*.xml')
          Dir.glob(pattern).flat_map(&method(:read_findbugs_report))
        end
    end

    def read_findbugs_report(path)
      doc = REXML::Document.new(File.read(path))
      src_dirs = REXML::XPath.match(doc, '/BugCollection/Project/SrcDir/text()')
      return [] if src_dirs.empty?

      src = src_dirs.first.to_s
      REXML::XPath.match(doc, '/BugCollection/BugInstance').map do |bug|
        Offence.new(path_from(bug, src), line_from(bug), message_from(bug))
      end
    end

    def path_from(bug_node, root)
      source_line = REXML::XPath.first(bug_node, 'SourceLine')
      path = source_line.attribute('sourcepath').to_s
      File.join(root, path)
    end

    def line_from(bug_node)
      source_line = REXML::XPath.first(bug_node, 'SourceLine')
      source_line.attribute('start').to_s.to_i
    end

    def message_from(bug_node)
      long_message = REXML::XPath.first(bug_node, 'LongMessage')
      return long_message.text if long_message

      bug_type = bug_node.attribute('type').to_s
      bug_category = bug_node.attribute('category').to_s
      "type=#{bug_type} category=#{bug_category}"
    end

    def new_message(offence, line)
      path = line.patch.delta.new_file[:path]
      Message.new(path, line, :warning, offence.message, nil, self.class)
    end
  end
end
