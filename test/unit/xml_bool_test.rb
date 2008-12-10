require File.join(File.dirname(__FILE__), '..', 'test_helper')

class XmlBool
  include ROXML

  xml_reader :true_from_TRUE?
  xml_reader :false_from_FALSE?, :text => 'text_for_FALSE'
  xml_reader :true_from_one?, :attr => 'attr_for_one'
  xml_reader :false_from_zero?, :text => 'text_for_zero', :in => 'container'
  xml_reader :true_from_True?, :attr => 'attr_for_True', :in => 'container'
  xml_reader :false_from_False?, :text => 'false_from_cdata_False', :as => :cdata
  xml_reader :true_from_true?
  xml_reader :false_from_false?
  xml_reader :missing?
end

class XmlBoolRequired
  include ROXML

  xml_reader :required?, :required => true
end

class XmlBoolUnexpected
  include ROXML

  xml_reader :unexpected?
end

class XmlBoolUnexpectedWithBlock
  include ROXML

  xml_reader :unexpected? do |val|
    val
  end
end

BOOL_XML = %{
  <xml_bool attr_for_one="1">
    <true_from_TRUE>TRUE</true_from_TRUE>
    <text_for_FALSE>FALSE</text_for_FALSE>
    <container attr_for_True="True">
      <text_for_zero>0</text_for_zero>
    </container>
    <false_from_cdata_False><![CDATA[False]]></false_from_cdata_False>
    <true_from_true>true</true_from_true>
    <false_from_false>false</false_from_false>
    <present_and_required>true</present_and_required>
  </xml_bool>
}
PRESENT = %{
  <xml_bool_required>
    <required>true</required>
  </xml_bool_required>
}
ABSENT = %{
  <xml_bool_required>
  </xml_bool_required>
}
UNEXPECTED_VALUE_XML = %{
  <xml_bool_unexpected>
    <unexpected>Unexpected Value</unexpected>
  </xml_bool_unexpected>
}


class TestXMLBool < Test::Unit::TestCase
  def test_bool_results_for_various_inputs
    x = XmlBool.from_xml(BOOL_XML)
    assert_equal true, x.true_from_TRUE?
    assert_equal false, x.false_from_FALSE?
    assert_equal true, x.true_from_one?
    assert_equal false, x.false_from_zero?
    assert_equal true, x.true_from_True?
    assert_equal false, x.false_from_False?
    assert_equal true, x.true_from_true?
    assert_equal false, x.false_from_false?
  end

  def test_missing_results_in_nil
    x = XmlBool.from_xml(BOOL_XML)
    assert_equal nil, x.missing?
  end

  def test_unexpected_value_results_in_nil
    x = XmlBoolUnexpected.from_xml(UNEXPECTED_VALUE_XML)
    assert_equal nil, x.unexpected?
  end

  def test_block_recieves_unexpected_value_rather_than_nil
    x = XmlBoolUnexpectedWithBlock.from_xml(UNEXPECTED_VALUE_XML)
    assert_equal "Unexpected Value", x.unexpected?
  end

  def test_required_raises_on_missing
    assert_nothing_raised do
      XmlBoolRequired.from_xml(PRESENT)
    end

    assert_raises(ROXML::RequiredElementMissing) do
      XmlBoolRequired.from_xml(ABSENT)
    end
  end

  to_xml_test XmlBool => BOOL_XML
end