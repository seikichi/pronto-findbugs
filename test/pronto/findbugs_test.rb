require 'test_helper'

class FindbugsTest < Test::Unit::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::Pronto::Findbugs::VERSION
  end
end
