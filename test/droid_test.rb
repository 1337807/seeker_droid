require 'test_helper'
require 'seeker_droid/droid'

class SeekerDroid::DroidTest < Minitest::Test
  def setup
    @droid = SeekerDroid::Droid.new 100, Mocha::Mock.new(:fake_bot)
    @droid.logger.level = Logger::ERROR

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

  def test_droid_stops_the_current_action_given_a_new_command
    @droid.bot.stubs(:forward)
    @droid.bot.stubs(:backward)

    fake_thread = Mocha::Mock.new(:fake_thread_for_killing).tap { |t| t.expects(:kill) }
    @droid.current_action = fake_thread

    @droid.forward
    @droid.backward
  end

  def test_set_direction_adds_directions_to_the_list
    @droid.set_direction(:forward)

    assert_equal [:forward], @droid.directions
  end

  def test_droid_sets_last_action_alerted_to_true_on_red_alert
    @droid.red_alert
    assert @droid.last_action_alerted
  end

  def test_droid_sets_last_action_alerted_to_false_after_red_alert
    @droid.red_alert
    assert @droid.last_action_alerted

    @droid.bot.stubs(:forward)
    @droid.forward

    refute @droid.last_action_alerted
  end

  def test_droid_turns_right_and_goes_forward_on_red_alert_if_last_action_alerted
    @droid.bot.stubs(:forward)
    red_alert = sequence('red_alert')

    @droid.bot.expects(:right).in_sequence(red_alert)
    @droid.bot.expects(:forward).in_sequence(red_alert)

    @droid.forward
    @droid.last_action_alerted = true
    @droid.red_alert
  end

  def test_done_returns_true_if_current_action_is_dead
    current_action = Mocha::Mock.new(:fake_dead_thread)
    current_action.stubs(:alive?).returns(false)

    @droid.current_action = current_action

    assert @droid.done?
  end

  def test_done_returns_false_if_current_action_is_alive
    current_action = Mocha::Mock.new(:fake_dead_thread)
    current_action.stubs(:alive?).returns(true)

    @droid.current_action = current_action

    refute @droid.done?
  end

  def test_directions_are_logged
    @droid.bot.stubs(:forward)
    @droid.logger.expects(:debug).with("New action: forward")
    @droid.forward
  end

  def test_red_alert_logs
    @droid.logger.expects(:debug).with("Alert: ")
    @droid.red_alert
  end
end
