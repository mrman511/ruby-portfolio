require "minitest/reporters"

class FailureCollectorReporter < Minitest::Reporters::DefaultReporter
  def initialize
    super
    @failed_tests = []
  end

  def record(result)
    super
    if !result.passed?
      @failed_tests << "#{result.source_location} \n (#{result.failures}) \n\n"
    end
  end

  def report
    super
    if @failed_tests.any?
      puts "\n\n"
      @failed_tests.each do |fail|
        puts fail
      end
      puts "\n\n"
    end
  end
end
