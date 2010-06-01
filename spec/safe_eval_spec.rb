require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Foo
  attr_accessor :bar
  include FromHash
end

describe "SafeEval" do
  fattr(:foo) { Foo.new(:bar => 1) }
  it 'smoke' do
    (2+2).should == 4
  end
  # it 'shouldnt let shellout' do
  #   SafeEval.with_level(4) { `rm -r -f /code/dfgdthryjtyhjtrr` }
  # end
  it 'safe shellout' do
    str = "`rm -r -f /code/dfgdthryjtyhjtrr`"
    lambda { 7.safe_instance_eval(str,:safe => 4) }.should raise_error(SecurityError)
  end
  it 'var change at 2' do
    foo.safe_instance_eval('self.bar = 2')
    foo.bar.should == 2
  end
  it 'var change at 4' do
    lambda { foo.safe_instance_eval('self.bar = 2', :safe => 4) }.should raise_error(SecurityError)
    foo.bar.should == 1
  end
  it 'with level' do
    SafeEval.with_level(4) do
      lambda { foo.safe_instance_eval('self.bar = 2') }.should raise_error(SecurityError)
      foo.bar.should == 1
    end
    foo.safe_instance_eval('self.bar = 2')
    foo.bar.should == 2
  end
end
