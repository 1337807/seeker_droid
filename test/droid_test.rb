require 'test_helper'
require 'seeker_droid/droid'

class SeekerDroid::DroidTest < Minitest::Test
  def setup
    @droid = SeekerDroid::Droid.new Mocha::Mock.new(:fake_bot)

    def Thread.new(*args, &block)
      block.call
      Mocha::Mock.new(:fake_thread).tap { |mock| mock.stubs(:kill) }
    end
  end

  def test_droid_going_forward_backs_up_and_turns_right_on_red_alert
    @droid.bot.stubs(:forward)
    red_alert = sequence('red_alert')

    @droid.bot.expects(:backward).in_sequence(red_alert)
    @droid.bot.expects(:right).in_sequence(red_alert)

    @droid.forward
    @droid.red_alert
  end

  def test_droid_going_backward_goes_forward_and_turns_right_on_red_alert
    @droid.bot.stubs(:backward)
    red_alert = sequence('red_alert')

    @droid.bot.expects(:forward).in_sequence(red_alert)
    @droid.bot.expects(:right).in_sequence(red_alert)

    @droid.backward
    @droid.red_alert
  end

  def test_droid_going_right_goes_backward_and_turns_right_on_red_alert
    @droid.bot.stubs(:right)
    red_alert = sequence('red_alert')

    @droid.bot.expects(:backward).in_sequence(red_alert)
    @droid.bot.expects(:right).in_sequence(red_alert)

    @droid.right
    @droid.red_alert
  end

  def test_droid_going_left_goes_backward_and_turns_left_on_red_alert
    @droid.bot.stubs(:left)
    red_alert = sequence('red_alert')

    @droid.bot.expects(:backward).in_sequence(red_alert)
    @droid.bot.expects(:left).in_sequence(red_alert)

    @droid.left
    @droid.red_alert
  end
end
